//
//  StemsListView.swift
//  The Final Journal AI
//
//  #4 — Viewer for separated stems: list each stem with play/pause + share.
//

import SwiftUI
import SwiftData
import AVFoundation
import UIKit

struct StemsListView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVAudioPlayer?
    @State private var nowPlaying: String?

    private var stems: [String] {
        return []
        /*
        if let paths = item.stemPaths as? [String] {
            return paths
        }
        if let anyArray = item.stemPaths as? [Any] {
            return anyArray.compactMap { $0 as? String }
        }
        return []
        */
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(stems, id: \.self) { path in
                    HStack(spacing: 12) {
                        Image(systemName: "waveform")
                            .foregroundStyle(Momentum.accent)
                        Text(displayName(path))
                            .font(.body.weight(.medium))
                            .foregroundStyle(Momentum.contentPrimary)
                        Spacer()
                        Button {
                            toggle(path)
                        } label: {
                            Image(systemName: (nowPlaying == path) ? "pause.circle.fill" : "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Momentum.accent)
                        }
                        .buttonStyle(.plain)
                        Button {
                            share(path)
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Momentum.contentSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Stems")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { player?.stop(); dismiss() }
                }
            }
        }
    }

    /// "American Wedding_vocals.wav" → "Vocals"
    private func displayName(_ path: String) -> String {
        let file = (path as NSString).lastPathComponent
        if let underscore = file.lastIndex(of: "_") {
            let stem = (String(file[file.index(after: underscore)...]) as NSString).deletingPathExtension
            return stem.isEmpty ? file : stem.capitalized
        }
        return (file as NSString).deletingPathExtension
    }

    private func toggle(_ path: String) {
        if nowPlaying == path {
            player?.stop()
            nowPlaying = nil
            return
        }
        player?.stop()
        guard FileManager.default.fileExists(atPath: path) else { return }
        do {
            let p = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            p.play()
            player = p
            nowPlaying = path
        } catch {
            nowPlaying = nil
        }
    }

    private func share(_ path: String) {
        let url = URL(fileURLWithPath: path)
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }
}

