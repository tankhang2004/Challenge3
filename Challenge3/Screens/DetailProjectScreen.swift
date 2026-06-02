import SwiftUI
import LinkPresentation

struct URLPreviewView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> LPLinkView {
        let view = LPLinkView()
        view.contentMode = .scaleAspectFit

        let provider = LPMetadataProvider()

        provider.startFetchingMetadata(for: url) { metadata, error in
            if let metadata = metadata {
                DispatchQueue.main.async {
                    view.metadata = metadata
                    view.invalidateIntrinsicContentSize()
                    view.setNeedsLayout()
                    view.layoutIfNeeded()
                }
            }
        }

        return view
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {}
}

struct DetailProjectScreen: View {
    @State private var sharedContents: [SharedContent] = []
    @State var topic = "A Day in My life as Apple Developer Academy Cohort"
    @State var script = "Hook: Bali punya hidden gems yang bahkan locals aja sering skip...\nMain: Nomor 10, Warung Bu Oka di Ubud..."
    @State var caption = "Hidden street food Bali yang wajib kamu coba! 🍜 Drop lokasi favorit kamu di komen 👇 #BaliFood #StreetFood #HiddenGem"
    @State var selectedDay: Int? = 1
    @State var isAM = true
    @State var musicExpanded = false

    let aprilGrid: [Int?] = [
        nil, nil, 1, 2, 3, 4, 5,
        6, 7, 8, 9, 10, 11, 12,
        13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26,
        27, 28, 29, 30, nil, nil, nil
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color.pageBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        topicSection
                        referencesSection
                        scriptSection
                        footageSection
                        captionSection
                        musicSection
                        whenToPostSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            sharedContents = SharedContentManager.shared.load()
        }
    }

    var topicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topic")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brandBlue, lineWidth: 1.5)
                    )

                TextEditor(text: $topic)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 72)
            }
            .frame(minHeight: 88)
        }
    }

    var referencesSection: some View {
        ReferencesSection()
    }

    var scriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Script")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brandBlue, lineWidth: 1.5)
                    )

                TextEditor(text: $script)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 80)
            }
            .frame(minHeight: 96)
        }
    }

    var footageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Footage")
                .font(.headline)

            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.28))
                        Circle()
                            .fill(Color.white.opacity(0.88))
                            .frame(width: 36, height: 36)
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .foregroundStyle(Color.brandOrange)
                            .offset(x: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .cornerRadius(8)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.28))
                        Text("A Day\nIn My Life")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        Circle()
                            .fill(Color.white.opacity(0.88))
                            .frame(width: 36, height: 36)
                        Image(systemName: "play.fill")
                            .font(.caption)
                            .foregroundStyle(Color.brandOrange)
                            .offset(x: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .cornerRadius(8)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.28))
                        Circle()
                            .fill(Color.white.opacity(0.88))
                            .frame(width: 36, height: 36)
                        Image(systemName: "play.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.brandOrange)
                            .offset(x: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .cornerRadius(8)
                }

                Button(action: {}) {
                    Text("+ Add More")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.brandOrange)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(Color.cardSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandBlue, lineWidth: 1.5)
            )
        }
    }

    var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caption")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brandBlue, lineWidth: 1.5)
                    )

                TextEditor(text: $caption)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 90)
            }
            .frame(minHeight: 106)
        }
    }

    var musicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Music Selection")
                .font(.headline)

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "A0785A").opacity(0.6))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image("MusicSelection")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .cornerRadius(5)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("Aesthetic Lofi Chill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("By Lio ADA")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { withAnimation { musicExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(musicExpanded ? 180 : 0))
                }
                .accessibilityLabel("Toggle music details")
            }
            .padding(12)
            .background(Color.musicSectionBackground)
            .cornerRadius(14)
        }
    }

    var whenToPostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to Post")
                .font(.headline)

            VStack(spacing: 10) {
                HStack {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("April 2025")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.right")
                                .font(.caption2.bold())
                                .foregroundStyle(.primary)
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline)
                                .foregroundStyle(Color.brandBlue)
                        }
                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                                .font(.subheadline)
                                .foregroundStyle(Color.brandBlue)
                        }
                    }
                }

                HStack(spacing: 0) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                    spacing: 2
                ) {
                    ForEach(0..<aprilGrid.count, id: \.self) { i in
                        if let day = aprilGrid[i] {
                            Button(action: { selectedDay = day }) {
                                ZStack {
                                    if selectedDay == day {
                                        Circle()
                                            .fill(Color.brandBlue)
                                            .frame(width: 34, height: 34)
                                    }
                                    Text("\(day)")
                                        .font(.subheadline)
                                        .foregroundStyle(
                                            selectedDay == day ? Color.white
                                            : day == 21 ? Color.brandBlue
                                            : Color.primary
                                        )
                                }
                                .frame(height: 36)
                            }
                        } else {
                            Color.clear.frame(height: 36)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.cardSurface)
            .cornerRadius(14)

            HStack {
                Text("Time")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 10) {
                    Text("3:00")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.cardSurface)
                                .shadow(color: Color(.label).opacity(0.08), radius: 3, x: 0, y: 1)
                        )

                    HStack(spacing: 0) {
                        Button(action: { isAM = true }) {
                            Text("AM")
                                .font(.footnote.bold())
                                .foregroundStyle(isAM ? Color.white : Color.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(isAM ? Color.brandBlue : Color.clear)
                                .cornerRadius(isAM ? 10 : 0)
                        }
                        Button(action: { isAM = false }) {
                            Text("PM")
                                .font(.footnote.bold())
                                .foregroundStyle(!isAM ? Color.white : Color.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(!isAM ? Color.brandBlue : Color.clear)
                                .cornerRadius(!isAM ? 10 : 0)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.cardSurface)
                            .shadow(color: Color(.label).opacity(0.08), radius: 3, x: 0, y: 1)
                    )
                    .cornerRadius(10)
                }
            }
            .padding(16)
            .background(Color.cardSurface)
            .cornerRadius(14)
        }
    }

    var importedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Imported")
                .font(.title2.bold())

            ForEach(sharedContents, id: \.id) { item in
                VStack(alignment: .leading) {
                    switch item.type {
                    case .text:
                        Text(item.text ?? "")

                    case .url:
                        VStack(alignment: .leading, spacing: 10) {
                            if let urlString = item.url,
                               let url = URL(string: urlString) {
                                URLPreviewView(url: url)
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))

                                Link(destination: url) {
                                    Text(urlString)
                                        .font(.caption)
                                        .foregroundStyle(.tint)
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                }
                            }
                        }

                    case .image:
                        if let filename = item.imageFilename,
                           let image = SharedContentManager.shared.loadImage(filename: filename) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        }
                    }
                }
                .padding()
                .background(Color.cardSurface)
                .cornerRadius(12)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

#Preview {
    DetailProjectScreen()
}
