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
                    // 🔥 important: prevent layout explosion
//                      view.sizeToFit()
                    // 🔥 important: resets internal layout
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
                Color(hex: "F6F9FE").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        importedSection
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Vlog A Day in My Life")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "3FA9F7"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "3FA9F7"))
                                .frame(width: 36, height: 36)
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .onAppear {
            sharedContents =
                SharedContentManager.shared.load()
        }
    }

    var topicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topic")
                .font(.system(size: 17, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "3FA9F7"), lineWidth: 1.5)
                    )

                TextEditor(text: $topic)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 72)
            }
            .frame(minHeight: 88)
        }
    }

    var referencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("References")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "3FA9F7"))
                            .frame(width: 34, height: 34)
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {

                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .top) {
                            Image("Reference1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 130)
                                .clipped()

                            Text("A Day in my Life as Student")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(width: 160, alignment: .center)
                                .background(Color.black.opacity(0.3))
                        }
                        .frame(width: 160, height: 130)

                        HStack(spacing: 6) {
                            Image("Instagram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .cornerRadius(6)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("@bibi")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("Instagram.com")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                    .frame(width: 160)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .top) {
                            Image("Reference2")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 130)
                                .clipped()

                            Text("A Day in my Life as International")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(width: 160, alignment: .center)
                                .background(Color.black.opacity(0.3))
                        }
                        .frame(width: 160, height: 130)

                        HStack(spacing: 6) {
                            Image("Tiktok")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .cornerRadius(6)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("@asaylife")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("tiktok.com")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                    .frame(width: 160)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)

                    VStack(alignment: .leading, spacing: 0) {
                        ZStack(alignment: .top) {
                            Image("Reference3")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 130)
                                .clipped()

                            Text("a day my life")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .frame(width: 160, alignment: .center)
                                .background(Color.black.opacity(0.3))
                        }
                        .frame(width: 160, height: 130)

                        HStack(spacing: 6) {
                            Image("Instagram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .cornerRadius(6)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("@linta")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("Instagram.com")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                    }
                    .frame(width: 160)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                }
                .padding(.vertical, 4)
            }
        }
    }

    var scriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Script")
                .font(.system(size: 17, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "3FA9F7"), lineWidth: 1.5)
                    )

                TextEditor(text: $script)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
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
                .font(.system(size: 17, weight: .bold))

            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.28))
                        Circle()
                            .fill(Color.white.opacity(0.88))
                            .frame(width: 36, height: 36)
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "E67740"))
                            .offset(x: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .cornerRadius(8)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.28))
                        Text("A Day\nIn My Life")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Circle()
                            .fill(Color.white.opacity(0.88))
                            .frame(width: 36, height: 36)
                        Image(systemName: "play.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "E67740"))
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
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "E67740"))
                            .offset(x: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .cornerRadius(8)
                }

                Button(action: {}) {
                    Text("+ Add More")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "E67740"))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "3FA9F7"), lineWidth: 1.5)
            )
        }
    }

    var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caption")
                .font(.system(size: 17, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "3FA9F7"), lineWidth: 1.5)
                    )

                TextEditor(text: $caption)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
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
                .font(.system(size: 17, weight: .bold))

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
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                    Text("By Lio ADA")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: { withAnimation { musicExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(musicExpanded ? 180 : 0))
                }
            }
            .padding(12)
            .background(Color(hex: "FFE7DC"))
            .cornerRadius(14)
        }
    }

    var whenToPostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to Post")
                .font(.system(size: 17, weight: .bold))

            VStack(spacing: 10) {
                HStack {
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("April 2025")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.black)
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "3FA9F7"))
                        }
                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "3FA9F7"))
                        }
                    }
                }

                HStack(spacing: 0) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
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
                                            .fill(Color(hex: "3FA9F7"))
                                            .frame(width: 34, height: 34)
                                    }
                                    Text("\(day)")
                                        .font(.system(size: 14))
                                        .foregroundColor(
                                            selectedDay == day ? .white :
                                            day == 21 ? Color(hex: "3FA9F7") : .black
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
            .background(Color.white)
            .cornerRadius(14)

            HStack {
                Text("Time")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)

                Spacer()

                HStack(spacing: 10) {
                    Text("3:00")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )

                    HStack(spacing: 0) {
                        Button(action: { isAM = true }) {
                            Text("AM")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isAM ? .white : .black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(isAM ? Color(hex: "3FA9F7") : Color.clear)
                                .cornerRadius(isAM ? 10 : 0)
                        }
                        Button(action: { isAM = false }) {
                            Text("PM")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(!isAM ? .white : .black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(!isAM ? Color(hex: "3FA9F7") : Color.clear)
                                .cornerRadius(!isAM ? 10 : 0)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    )
                    .cornerRadius(10)
                }
            }
            .padding(16)
            .background(Color.white)
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
                                        .foregroundColor(.blue)
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                }
                            }
                        }

                    case .image:

                        if let filename = item.imageFilename,
                           let image =
                            SharedContentManager.shared
                                .loadImage(filename: filename)
                        {

                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        }
                    }
                }
                .padding()
                .background(Color.white)
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
