//  MusicPlayerManager.swift
//  Challenge3

import MusicKit
import SwiftUI
import AVFAudio
import AVFoundation


@Observable
final class MusicPlayerManager {
    static let shared = MusicPlayerManager()

    private let player = ApplicationMusicPlayer.shared
    private var previewAVPlayer: AVPlayer? = nil

    var isPlaying: Bool = false
    var currentSongID: String? = nil
    var isPreviewMode: Bool = false       // ← track which mode is active

    private init() {}

    // MARK: - Full Playback (Apple Music subscription)

    func play(_ song: Song) async {
        stopPreviewPlayer()               // stop any active preview first
        do {
            player.queue = [song]
            try await player.play()
            await MainActor.run {
                currentSongID = song.id.rawValue
                isPlaying = true
                isPreviewMode = false
            }
        } catch {
            print("❌ Playback failed: \(error)")
        }
    }

    func playSongID(_ id: String) async {
        var request = MusicCatalogResourceRequest<Song>(
            matching: \.id,
            equalTo: MusicItemID(id)
        )
        request.limit = 1
        do {
            let response = try await request.response()
            if let song = response.items.first {
                await play(song)
            }
        } catch {
            print("❌ Failed to fetch song: \(error)")
        }
    }

    // MARK: - Preview Playback (30-sec clip, no subscription needed)

    func preview(_ song: Song) async {
        guard let previewURL = song.previewAssets?.first?.url else {
            // No preview asset — fall back to full playback
            await play(song)
            return
        }
        stopFullPlayer()                  // stop full player if running
        await MainActor.run {
            previewAVPlayer?.pause()
            previewAVPlayer = nil

            let newPlayer = AVPlayer(url: previewURL)
            previewAVPlayer = newPlayer
            newPlayer.play()

            currentSongID = song.id.rawValue
            isPlaying = true
            isPreviewMode = true
        }

        // Auto-stop when preview clip ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: previewAVPlayer?.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.previewAVPlayer = nil
            self?.isPlaying = false
            self?.currentSongID = nil
        }
    }

    // MARK: - Toggle

    func togglePlayback(for songID: String) async {
        if isPlaying && currentSongID == songID {
            stopAll()
        } else {
            await playSongID(songID)
        }
    }

    func togglePreview(for song: Song) async {
        if isPlaying && currentSongID == song.id.rawValue && isPreviewMode {
            stopAll()
        } else {
            await preview(song)
        }
    }

    // MARK: - Stop

    func stopAll() {
        stopFullPlayer()
        stopPreviewPlayer()
        isPlaying = false
        currentSongID = nil
        isPreviewMode = false
    }

    // Keep old name so existing call sites don't break
    func stop() { stopAll() }

    private func stopFullPlayer() {
        player.stop()
    }

    private func stopPreviewPlayer() {
        previewAVPlayer?.pause()
        previewAVPlayer = nil
    }
}
