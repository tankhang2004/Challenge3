import SwiftUI

struct ReferencesSection: View {

    @State private var vm = ReferencesViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(vm.items, id: \.id) { item in
                        ReferenceCard(item: item)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .onAppear {
            vm.refresh()
        }
    }

    private var header: some View {
        HStack {
            Text("References")
                .font(.headline)

            Spacer()

            Button(action: { vm.refresh() }) {
                ZStack {
                    Circle()
                        .fill(Color("3FA9F7"))
                        .frame(width: 34, height: 34)
                    Image(systemName: "plus")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
            }
            .accessibilityLabel("Refresh references")
        }
    }
}

struct ReferenceCard: View {

    let item: SharedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            preview
            footer
        }
        .frame(width: 160)
        .background(Color.cardSurface)
        .cornerRadius(12)
        .shadow(color: Color(.label).opacity(0.1), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private var preview: some View {
        switch item.type {
        case .image:
            if let filename = item.imageFilename,
               let image = SharedContentManager.shared.loadImage(filename: filename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 130)
                    .clipped()
            }

        case .url:
            if let urlString = item.url,
               let url = URL(string: urlString) {
                URLPreviewView(url: url)
                    .frame(width: 160, height: 130)
                    .clipped()
            }

        case .text:
            Text(item.text ?? "")
                .font(.caption)
                .foregroundStyle(.primary)
                .padding()
                .frame(width: 160, height: 130)
                .background(Color(.systemFill))
        }
    }

    private var footer: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    private var icon: String {
        switch item.type {
        case .url:   return "link"
        case .image: return "photo"
        case .text:  return "doc.text"
        }
    }

    private var title: String {
        switch item.type {
        case .url:   return URL(string: item.url ?? "")?.host ?? "Link"
        case .image: return "Image"
        case .text:  return "Note"
        }
    }

    private var subtitle: String {
        switch item.type {
        case .url:   return item.url ?? ""
        case .image: return "Saved Image"
        case .text:  return ""
        }
    }
}
