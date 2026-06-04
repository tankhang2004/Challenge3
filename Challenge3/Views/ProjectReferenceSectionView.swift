//  ProjectReferenceSectionView.swift
//  Challenge3

import SwiftUI

struct ProjectReferenceSectionView: View {
    let references: [ReferenceItem]
    let onAdd: () -> Void
    let onDelete: (Int) -> Void
    let onTap: (ReferenceItem) -> Void

    private var strokeColor: Color {
        references.isEmpty ? Color.gray.opacity(0.3) : Color.brandBlue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: Header
            HStack {
                Text("References")
                    .font(.headline)
                Spacer()
                Button { onAdd() } label: {
                    ZStack {
                        Circle()
                            .fill(Color.brandBlue)
                            .frame(width: 34, height: 34)
                        Image(systemName: "plus")
                            .font(.subheadline.bold())
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }

            // MARK: Container
            VStack {
                if references.isEmpty {

                    // Empty state — single dashed box just like the old footage add slot
                    Button { onAdd() } label: {
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
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)

                } else {

                    // Reference Cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(references.indices, id: \.self) { i in
                                ReferenceCardView(
                                    reference: references[i],
                                    onDelete: { onDelete(i) },
                                    onTap: { onTap(references[i]) }
                                )
                            }

                            // Add more button
                            Button { onAdd() } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.cardSurface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    Color.brandBlue.opacity(0.4),
                                                    style: StrokeStyle(lineWidth: 1.5, dash: [6])
                                                )
                                        )
                                    Image(systemName: "plus")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color.brandBlue.opacity(0.5))
                                }
                                .frame(width: 100, height: 100)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(12)
            .background(Color.cardSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: references.isEmpty)
        }
    }
}

// MARK: - Reference Card

struct ReferenceCardView: View {
    let reference: ReferenceItem
    let onDelete: () -> Void
    let onTap: () -> Void

    var body: some View {
        let previewURL = resolvedURL(from: reference.url)

        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                ReferencePreviewView(reference: reference, url: previewURL)

                VStack(alignment: .leading, spacing: 6) {
                    Text(reference.title.isEmpty ? "Reference" : reference.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    if !reference.creator.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(reference.creator)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "link")
                        Text(reference.platform.isEmpty ? "Link" : reference.platform)
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.brandBlue)

                    if let previewURL {
                        Text(previewURL.host ?? previewURL.absoluteString)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                .padding(12)
            }
            .frame(width: 176, height: 226, alignment: .topLeading)
            .background(Color.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.brandBlue.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture { onTap() }

            // Delete button
            Button { onDelete() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red.opacity(0.85))
                    .background(Color.white.clipShape(Circle()))
            }
            .buttonStyle(.plain)
            .offset(x: 6, y: -6)
        }
    }

    private func resolvedURL(from rawURL: String) -> URL? {
        let trimmed = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil { return url }
        return URL(string: "https://\(trimmed)")
    }
}

// MARK: - Reference Preview

struct ReferencePreviewView: View {
    let reference: ReferenceItem
    let url: URL?

    var body: some View {
        let isTextOnly = reference.imageFilename == nil
            && url == nil
            && !reference.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        ZStack(alignment: .topTrailing) {
            Group {
                if let filename = reference.imageFilename,
                   let image = SharedContentManager.shared.loadImage(filename: filename) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()

                } else if let url {
                    URLPreviewView(url: url)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()

                } else if isTextOnly {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.brandBlue)
                            Spacer()
                        }
                        Text(reference.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(4)
                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(
                        LinearGradient(
                            colors: [Color.brandBlue.opacity(0.18), Color.brandBlue.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.brandBlue.opacity(0.24), Color.brandBlue.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color.brandBlue)
                                Text("No preview")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 112)
            .clipped()

            // Platform badge
            Text(reference.platform.isEmpty ? "Link" : reference.platform)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color.brandBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .padding(10)
        }
    }
}
