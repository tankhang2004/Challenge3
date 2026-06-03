import SwiftUI

struct ReferencePreviewPayload: Identifiable {
    let id = UUID()
    let title: String
    let creator: String
    let platform: String
    let url: String
    let imageFilename: String?
    let fullText: String?

    init(reference: ReferenceItem) {
        title = reference.title
        creator = reference.creator
        platform = reference.platform
        url = reference.url
        imageFilename = reference.imageFilename
        fullText = reference.fullText
    }
}

struct ReferencePreviewSheetView: View {
    let payload: ReferencePreviewPayload

    @State private var showExportSheet: Bool = false

    private var isTextOnlyReference: Bool {
        payload.imageFilename == nil && previewURL == nil && !textPreview.isEmpty
    }

    private var textPreview: String {
        let fullText = payload.fullText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let fullText, !fullText.isEmpty {
            return fullText
        }

        return payload.title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var previewURL: URL? {
        let trimmed = payload.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }

        return URL(string: "https://\(trimmed)")
    }

    private var displayTitle: String {
        payload.title.isEmpty ? "Reference Preview" : payload.title
    }

    private var displayCreator: String {
        payload.creator.isEmpty ? "Shared Reference" : payload.creator
    }

    private var previewImage: UIImage? {
        guard let imageFilename = payload.imageFilename else { return nil }
        return SharedContentManager.shared.loadImage(filename: imageFilename)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    previewCard

                    VStack(alignment: .leading, spacing: 8) {
                        Text(displayTitle)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)

                        Text(displayCreator)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)

                        if !payload.platform.isEmpty {
                            Text(payload.platform)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color("3FA9F7"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color("3FA9F7").opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let previewURL {
                        Link(destination: previewURL) {
                            HStack(spacing: 8) {
                                Image(systemName: "safari")
                                Text("Open Link")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("3FA9F7"))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    if previewImage != nil {
                        Button {
                            showExportSheet = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.circle")
                                Text("Download Image")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("3FA9F7"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("3FA9F7").opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExportSheet) {
                if let image = previewImage {
                    ActivityView(items: [image])
                }
            }
        }
    }

    @ViewBuilder
    private var previewCard: some View {
        GeometryReader { proxy in
            let availableWidth = proxy.size.width
            let contentHeight = min(max(proxy.size.height * 0.58, 320), 440)

            Group {
                if let image = previewImage {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: availableWidth, height: contentHeight, alignment: .center)
                    }
                    .frame(width: availableWidth, height: contentHeight)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                        Group {
                            if let previewURL {
                                URLPreviewView(url: previewURL)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                            } else if isTextOnlyReference {
                                ScrollView(showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack {
                                            Image(systemName: "doc.text")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(Color("3FA9F7"))
                                            Spacer()
                                        }

                                        Text(textPreview)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)

                                        HStack(spacing: 8) {
                                            Image(systemName: "text.quote")
                                                .foregroundColor(Color("3FA9F7"))
                                            Text("Full text preview")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(Color("3FA9F7"))
                                        }
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                }
                                .background(
                                    LinearGradient(
                                        colors: [Color("3FA9F7").opacity(0.18), Color("3FA9F7").opacity(0.06)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 36, weight: .semibold))
                                        .foregroundColor(Color("3FA9F7"))
                                    Text("No preview available")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [Color("3FA9F7").opacity(0.16), Color("3FA9F7").opacity(0.06)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
            }
            .frame(width: availableWidth, height: contentHeight)
        }
        .frame(height: 560)
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
