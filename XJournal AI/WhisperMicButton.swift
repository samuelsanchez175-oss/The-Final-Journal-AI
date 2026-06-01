//
//  WhisperMicButton.swift
//  XJournal AI
//
//  Inline mic button for the note editor.
//  Hold to record → release to transcribe via Whisper → pipe into RapSuggestionAPI.
//
//  INTEGRATION: Drop <WhisperMicButton(onTranscription:)> anywhere in NoteEditorView's
//  toolbar or keyboard island. The callback delivers the transcribed text so the caller
//  can append it to the entry body or pass it to the rap generation pipeline.
//
//  Relies on the existing AudioTranscriptionService for the Whisper API call.
//  Requires NSMicrophoneUsageDescription in Info.plist.
//

import SwiftUI
import AVFoundation
import Combine

// MARK: - Recorder State

enum WhisperMicState: Equatable {
    case idle
    case recording
    case transcribing
    case error(String)
}

// MARK: - Recorder Engine

@MainActor
final class WhisperMicRecorder: NSObject, ObservableObject {

    @Published var micState: WhisperMicState = .idle
    @Published var lastTranscription: String = ""

    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private let transcriptionService = AudioTranscriptionService()

    // ── Start recording ──────────────────────────────────────────
    func startRecording() {
        guard micState == .idle else { return }

        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                Task { @MainActor in
                    self.micState = .error("Microphone access denied. Enable in Settings.")
                }
                return
            }
            Task { @MainActor in
                self.beginCapture(session: session)
            }
        }
    }

    private func beginCapture(session: AVAudioSession) {
        do {
            try session.setCategory(.record, mode: .default)
            try session.setActive(true)

            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("whisper_freestyle_\(UUID().uuidString).m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ]

            audioRecorder = try AVAudioRecorder(url: tmpURL, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            recordingURL = tmpURL
            micState = .recording
        } catch {
            micState = .error("Could not start recording: \(error.localizedDescription)")
        }
    }

    // ── Stop + transcribe ────────────────────────────────────────
    func stopAndTranscribe() async {
        guard micState == .recording,
              let recorder = audioRecorder,
              let url = recordingURL else { return }

        recorder.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
        micState = .transcribing

        do {
            let result = try await transcriptionService.transcribe(audioURL: url)
            lastTranscription = result.fullText
            micState = .idle
            // Clean up temp file
            try? FileManager.default.removeItem(at: url)
        } catch {
            micState = .error("Transcription failed: \(error.localizedDescription)")
        }
    }

    func reset() { micState = .idle }
}

// MARK: - WhisperMicButton View

struct WhisperMicButton: View {
    /// Called with the transcribed text when Whisper returns.
    var onTranscription: (String) -> Void

    /// Optional: also pipe directly into rap generation
    var onGenerateFromFlow: ((String) -> Void)? = nil

    @StateObject private var recorder = WhisperMicRecorder()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            micButton
            statusLabel
        }
        .onChange(of: recorder.lastTranscription) { _, newValue in
            guard !newValue.isEmpty else { return }
            onTranscription(newValue)
        }
    }

    // ── Mic button ───────────────────────────────────────────────
    private var micButton: some View {
        Button {
            // tap behavior: toggle for accessibility (hold gesture below handles primary UX)
        } label: {
            ZStack {
                Circle()
                    .fill(buttonBackground)
                    .frame(width: 44, height: 44)
                    .scaleEffect(recorder.micState == .recording ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: recorder.micState == .recording)

                if recorder.micState == .transcribing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.75)
                } else {
                    Image(systemName: micIcon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(iconColor)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if recorder.micState == .idle {
                        recorder.startRecording()
                    }
                }
                .onEnded { _ in
                    if recorder.micState == .recording {
                        Task { await recorder.stopAndTranscribe() }
                    }
                }
        )
        .disabled(recorder.micState == .transcribing)
        .accessibilityLabel(accessibilityLabel)
    }

    // ── Status label ─────────────────────────────────────────────
    @ViewBuilder
    private var statusLabel: some View {
        switch recorder.micState {
        case .recording:
            Text("Recording…")
                .font(.caption2)
                .foregroundStyle(.red)
                .transition(.opacity)
        case .transcribing:
            Text("Transcribing…")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .transition(.opacity)
        case .error(let msg):
            Text(msg)
                .font(.caption2)
                .foregroundStyle(.red)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 120)
                .onTapGesture { recorder.reset() }
                .transition(.opacity)
        case .idle:
            EmptyView()
        }
    }

    // ── Helpers ──────────────────────────────────────────────────
    private var micIcon: String {
        switch recorder.micState {
        case .recording:   return "waveform"
        case .error:       return "mic.slash"
        default:           return "mic"
        }
    }

    private var buttonBackground: Color {
        switch recorder.micState {
        case .recording:   return .red
        case .transcribing: return .blue.opacity(0.8)
        case .error:       return .orange
        case .idle:        return colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.08)
        }
    }

    private var iconColor: Color {
        switch recorder.micState {
        case .idle: return colorScheme == .dark ? .white : .primary
        default:    return .white
        }
    }

    private var accessibilityLabel: String {
        switch recorder.micState {
        case .idle:         return "Hold to record freestyle"
        case .recording:    return "Recording — release to transcribe"
        case .transcribing: return "Transcribing audio"
        case .error:        return "Recording error — tap to reset"
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    WhisperMicButton { text in
        print("Transcribed: \(text)")
    }
    .padding()
}
#endif
