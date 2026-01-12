---
name: Audio Import and Transcription - iOS 26 Notes Parity
overview: Complete pixel-perfect parity with iOS 26 Notes app for audio import, inline display, transcription, and detail sheet. Includes waveform visualization, scrubbing, and exact styling match.
todos:
  - id: add_summary_field
    content: Add audioSummary field to Item model in Item.swift
    status: completed
  - id: create_transcription_service
    content: Create AudioTranscriptionService.swift with Speech framework integration and word-level timestamp extraction
    status: completed
  - id: create_transcription_segment_model
    content: Create TranscriptionSegment struct model for storing timestamped words
    status: completed
  - id: create_summary_service
    content: Create AudioSummaryService.swift with OpenAI API integration
    status: completed
    dependencies:
      - add_summary_field
  - id: create_waveform_component
    content: Create WaveformView component with audio analysis and scrubbing support
    status: completed
  - id: create_inline_audio_card
    content: Create compact inline audio card matching iOS Notes exact styling (light gray rounded box)
    status: completed
    dependencies:
      - create_waveform_component
  - id: add_file_importers
    content: Add fileImporter modifiers to NoteEditorView for audio and text files
    status: completed
  - id: update_paperclip_menu
    content: Update paperclip menu button to trigger file import actions
    status: completed
    dependencies:
      - add_file_importers
  - id: create_timestamped_transcript_view
    content: Create TimestampedTranscriptView with tap-to-seek and real-time word highlighting
    status: completed
    dependencies:
      - create_transcription_segment_model
  - id: create_audio_detail_sheet
    content: Create AudioDetailSheet with exact iOS 26 Notes layout (title, date edited, summary, waveform player, interactive transcript)
    status: completed
    dependencies:
      - add_summary_field
      - create_waveform_component
      - create_timestamped_transcript_view
  - id: add_inline_transcript
    content: Add inline transcript display below audio card in note editor
    status: completed
    dependencies:
      - create_inline_audio_card
  - id: make_card_tappable
    content: Make inline audio card tappable to open AudioDetailSheet
    status: completed
    dependencies:
      - create_audio_detail_sheet
      - create_inline_audio_card
  - id: integrate_transcription_flow
    content: Integrate automatic transcription with word-level timestamp extraction when audio is imported
    status: completed
    dependencies:
      - create_transcription_service
      - create_transcription_segment_model
      - add_file_importers
  - id: integrate_summary_flow
    content: Integrate automatic summary generation after transcription
    status: completed
    dependencies:
      - create_summary_service
      - integrate_transcription_flow
  - id: add_permissions
    content: Add speech recognition permission to Info.plist
    status: completed
---

