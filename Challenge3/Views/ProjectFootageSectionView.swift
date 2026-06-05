//  FootageSectionView.swift
//  Challenge3

import SwiftUI
import PhotosUI
import AVKit

struct FootageSectionView: View {
    @Binding var footageImages: [UIImage]
    @Binding var footagePickerItems: [PhotosPickerItem]
    @Binding var footageVideoURLs: [URL]

    @State private var activeVideoURL: URL? = nil
    @State private var activeImage: UIImage? = nil
    
    var subtitle: String? = nil

    private var strokeColor: Color {
        let totalCount = footageImages.count + footageVideoURLs.count
        return totalCount > 0 ? Color.brandBlue : Color.gray.opacity(0.3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Footage")
                .font(.headline)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {

                if footageImages.isEmpty && footageVideoURLs.isEmpty {

                    // MARK: Empty state — tall block with photo logo
                    PhotosPicker(
                        selection: $footagePickerItems,
                        maxSelectionCount: 10,
                        matching: .any(of: [.images, .videos])
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.cardSurface)
                            VStack(spacing: 6) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color.accentColor.opacity(0.5))
                                Text("Tap + to add footage")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    }
                    .onChange(of: footagePickerItems) { _, newItems in
                        loadFootage(from: newItems)
                    }

                } else {

                    // MARK: Thumbnails + add more slot
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {

                            // Image thumbnails
                            ForEach(footageImages.indices, id: \.self) { i in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: footageImages[i])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipped()
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            activeImage = footageImages[i]
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

                            // Video thumbnails
                            ForEach(footageVideoURLs.indices, id: \.self) { i in
                                ZStack(alignment: .topTrailing) {
                                    VideoThumbnailView(url: footageVideoURLs[i])
                                        .scaledToFit()
                                        .frame(width: 90, height: 90)
                                        .cornerRadius(8)
                                        .clipped()
                                        .onTapGesture {
                                            activeVideoURL = footageVideoURLs[i]
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

                            // Add more slot
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
                    .stroke(
                        strokeColor,
                        style: StrokeStyle(lineWidth: 1.5, dash: [6])
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: footageImages.isEmpty && footageVideoURLs.isEmpty)
        }
        .fullScreenCover(item: $activeVideoURL) { url in
            VideoPlayerView(url: url)
        }
        .fullScreenCover(item: $activeImage) { image in
            ImageViewerView(image: image)
        }
    }

    // MARK: - Load footage

    private func loadFootage(from items: [PhotosPickerItem]) {
        Task {
            var images: [UIImage] = []
            var videoURLs: [URL] = []

            for item in items {
                if item.supportedContentTypes.contains(where: { $0.conforms(to: .image) }) {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        images.append(image)
                    }
                } else if item.supportedContentTypes.contains(where: {
                    $0.conforms(to: .movie) || $0.conforms(to: .video)
                }) {
                    if let url = try? await loadVideoURL(from: item) {
                        videoURLs.append(url)
                    }
                }
            }

            await MainActor.run {
                footageImages    = images
                footageVideoURLs = videoURLs
            }
        }
    }

    private func loadVideoURL(from item: PhotosPickerItem) async throws -> URL? {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return nil }
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
