//  ProjectMusicSectionView.swift
//  Challenge3

import SwiftUI
import MusicKit

struct ProjectMusicSectionView: View {
    @Binding var selectedSong: SongSelection?
    @State private var showPicker: Bool = false
    @Environment(\.openURL) private var openURL
    private let musicPlayer = MusicPlayerManager.shared   // ← add

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Music Selection")
                .font(.headline)

            HStack(spacing: 12) {
                // Artwork
                Group {
                    if let artworkURL = selectedSong?.artworkURL {
                        AsyncImage(url: artworkURL) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            artworkPlaceholder
                        }
                    } else {
                        artworkPlaceholder
                    }
                }
                .frame(width: 54, height: 54)
                .cornerRadius(8)
                .clipped()

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(selectedSong?.title ?? "No music selected")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selectedSong == nil ? .gray : .primary)
                        .lineLimit(1)
                    Text(selectedSong?.artistName ?? "Tap + to choose music")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 10) {
                    // MARK: Play/Stop — only when song selected
                    if let song = selectedSong {
                        Button {
                            Task {
                                await musicPlayer.togglePlayback(for: song.id)
                            }
                        } label: {
                            Image(systemName:
                                musicPlayer.isPlaying && musicPlayer.currentSongID == song.id
                                    ? "stop.circle.fill"
                                    : "play.circle.fill"
                            )
                            .font(.system(size: 28))
                            .foregroundColor(Color.brandBlue)
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: Clear
                    if selectedSong != nil {
                        Button {
                            musicPlayer.stop()
                            withAnimation { selectedSong = nil }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }

                    // MARK: Browse
                    Button {
                        Task { await requestAndShowPicker() }
                    } label: {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.brandBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(Color.brandBlue.opacity(0.05))
            .cornerRadius(14)
        }
        .sheet(isPresented: $showPicker) {
            MusicPickerView(selectedSong: $selectedSong)
        }
        .task {
            _ = MusicAuthorization.currentStatus
        }
        .onDisappear {
            musicPlayer.stop()
        }
    }

    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.15))
            .overlay(
                Image(systemName: "music.note")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
            )
    }

    private func requestAndShowPicker() async {
        switch MusicAuthorization.currentStatus {
        case .authorized:
            showPicker = true
        case .notDetermined:
            let status = await MusicAuthorization.request()
            if status == .authorized { showPicker = true }
        default:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
        }
    }
}


// MARK: - Song Selection Model (in-memory, not SwiftData)

struct SongSelection {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String?
    let artworkURL: URL?

    init(from song: Song) {
        id          = song.id.rawValue
        title       = song.title
        artistName  = song.artistName
        albumTitle  = song.albumTitle
        artworkURL  = song.artwork?.url(width: 200, height: 200)
    }

    /// Reconstruct from persisted MusicItem
    init(from item: MusicItem) {
        id          = item.songID
        title       = item.title
        artistName  = item.artistName
        albumTitle  = item.albumTitle
        artworkURL  = item.artworkURL.flatMap { URL(string: $0) }
    }

    /// Convert to persistable MusicItem
    func toMusicItem() -> MusicItem {
        MusicItem(
            songID:      id,
            title:       title,
            artistName:  artistName,
            albumTitle:  albumTitle,
            artworkURL:  artworkURL?.absoluteString
        )
    }
}

// MARK: - Music Picker View

struct MusicPickerView: View {
    @Binding var selectedSong: SongSelection?
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var songs: MusicItemCollection<Song> = []
    @State private var isSearching: Bool = false
    @State private var searchTask: Task<Void, Never>? = nil
    
    private let musicPlayer = MusicPlayerManager.shared   // ← add


    var body: some View {
        NavigationStack {
            Group {
                if songs.isEmpty && searchText.isEmpty {
                    emptyPrompt
                } else if songs.isEmpty && !searchText.isEmpty && !isSearching {
                    noResults
                } else {
                    songList
                }
            }
            .navigationTitle("Choose Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .searchable(text: $searchText, prompt: "Search songs, artists…")
            .onChange(of: searchText) { _, query in
                searchTask?.cancel()
                guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
                    songs = []
                    return
                }
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(300)) // debounce
                    guard !Task.isCancelled else { return }
                    await search(query: query)
                }
            }
        }
    }

    private var emptyPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.4))
            Text("Search for a song")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResults: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.4))
            Text("No results for \"\(searchText)\"")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var songList: some View {
        List(songs, id: \.id) { song in
            HStack(spacing: 12) {
                // Artwork
                Group {
                    if let url = song.artwork?.url(width: 100, height: 100) {
                        AsyncImage(url: url) { img in
                            img.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 48, height: 48)
                .cornerRadius(6)
                .clipped()

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(song.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(song.artistName)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()

                // MARK: Preview button
                Button {
                    Task {
                        if musicPlayer.isPlaying && musicPlayer.currentSongID == song.id.rawValue {
                            musicPlayer.stop()
                        } else {
                            await musicPlayer.preview(song)
                        }
                    }
                } label: {
                    Image(systemName:
                        musicPlayer.isPlaying && musicPlayer.currentSongID == song.id.rawValue
                            ? "stop.circle.fill"
                            : "play.circle"
                    )
                    .font(.system(size: 26))
                    .foregroundColor(Color.brandBlue)
                }
                .buttonStyle(.plain)

                // MARK: Select button
                Button {
                    musicPlayer.stop()
                    selectedSong = SongSelection(from: song)
                    dismiss()
                } label: {
                    Image(systemName:
                        selectedSong?.id == song.id.rawValue
                            ? "checkmark.circle.fill"
                            : "plus.circle"
                    )
                    .font(.system(size: 26))
                    .foregroundColor(
                        selectedSong?.id == song.id.rawValue
                            ? .green
                            : Color.brandBlue.opacity(0.7)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
        .listStyle(.plain)
        .overlay {
            if isSearching { ProgressView() }
        }
        .onDisappear {
            musicPlayer.stop()
        }
    }

    private func search(query: String) async {
        isSearching = true
        defer { isSearching = false }

        var request = MusicCatalogSearchRequest(
            term: query,
            types: [Song.self]
        )
        request.limit = 25

        do {
            let response = try await request.response()
            await MainActor.run {
                songs = response.songs
            }
        } catch {
            print("❌ Music search failed: \(error)")
        }
    }
}
