//  FootageSectionView.swift
//  Challenge3

import SwiftUI
import PhotosUI
import AVKit

struct FootageSectionView: View {
    @Binding var footageImages: [UIImage]
    @Binding var footagePickerItems: [PhotosPickerItem]
    @Binding var footageVideoURLs: [URL]         // ← new: loaded video file URLs
    
    @State private var activeVideoURL: URL? = nil
    @State private var activeImage: UIImage? = nil      // ← new

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Footage")
                .font(.headline)

            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {

                        // MARK: Image thumbnails
                        ForEach(footageImages.indices, id: \.self) { i in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: footageImages[i])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipped()
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        activeImage = footageImages[i]       // ← tap to view
                                    }

                                Button {
                                    var imgs = footageImages
                                    imgs.remove(at: i)
                                    footageImages = imgs
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.red.opacity(0.8))
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .buttonStyle(.plain)
                                .offset(x: 6, y: -6)
                            }
                        }

                        // MARK: Video thumbnails
                        ForEach(footageVideoURLs.indices, id: \.self) { i in
                            ZStack(alignment: .topTrailing) {
                                VideoThumbnailView(url: footageVideoURLs[i])
                                    //without scaledToFit(), it will affect nearby region, clicking nearby region (in this case: left) will accidentally click it
                                    .scaledToFit()
//                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .cornerRadius(8)
                                    .clipped()
                                    .onTapGesture {
                                        activeVideoURL = footageVideoURLs[i]  // ← tap to play
                                    }

                                Button {
                                    var vids = footageVideoURLs
                                    vids.remove(at: i)
                                    footageVideoURLs = vids
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.red.opacity(0.8))
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .buttonStyle(.plain)
                                .offset(x: 6, y: -6)
                            }
                        }

                        // MARK: Add slot
                        PhotosPicker(
                            selection: $footagePickerItems,
                            maxSelectionCount: 10,
                            matching: .any(of: [.images, .videos])
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                Color.gray.opacity(0.3),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [5])
                                            )
                                    )
                                Image(systemName: "plus")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.gray.opacity(0.4))
                            }
                            .frame(width: 90, height: 90)
                        }
                        .onChange(of: footagePickerItems) { _, newItems in
                            loadFootage(from: newItems)
                        }
                    }
                    .padding(.vertical, 4)
                }

                let totalCount = footageImages.count + footageVideoURLs.count
                if totalCount > 0 {
                    Text("\(totalCount) item\(totalCount == 1 ? "" : "s") selected")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(12)
            .background(Color.cardSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandBlue, lineWidth: 1.5)
            )
        }
        .fullScreenCover(item: $activeVideoURL) { url in
            VideoPlayerView(url: url)
        }
        .fullScreenCover(item: $activeImage) { image in
            ImageViewerView(image: image)
        }
    }

    // MARK: - Load footage (images + videos separately)

    private func loadFootage(from items: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            var videoURLs: [URL] = []

            for item in items {
                // Try as image first
                if item.supportedContentTypes.contains(where: {
                    $0.conforms(to: .image)
                }) {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
                // Try as movie
                else if item.supportedContentTypes.contains(where: {
                    $0.conforms(to: .movie) || $0.conforms(to: .video)
                }) {
                    if let url = try? await loadVideoURL(from: item) {
                        videoURLs.append(url)
                    }
                }
            }

            await MainActor.run {
                footageImages   = images
                footageVideoURLs = videoURLs
            }
        }
    }

    private func loadVideoURL(from item: PhotosPickerItem) async throws -> URL? {
        // Load raw data and write to temp directory so AVPlayer can read it
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).mov")
        try data.write(to: tempURL)
        return tempURL
    }
}

// MARK: - Video Thumbnail

struct VideoThumbnailView: View {
    let url: URL
    @State private var thumbnail: UIImage? = nil

    var body: some View {
        ZStack {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.black.opacity(0.2)
            }

            Image(systemName: "play.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 4)
        }
        .onAppear { generateThumbnail() }
    }

    private func generateThumbnail() {
        Task.detached(priority: .background) {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 0, preferredTimescale: 60)
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                let image = UIImage(cgImage: cgImage)
                await MainActor.run { thumbnail = image }
            }
        }
    }
}
