import SwiftUI

struct AddProjectScreen: View {

    // Nama project yang bisa diedit langsung di nav bar
    @State private var editableName: String
    @State var topic = ""
    @State var script = ""
    @State var caption = ""
    @State var selectedDay: Int? = nil
    @State var isAM = true
    @State var musicExpanded = false
    @Environment(\.dismiss) var dismiss

    init(projectName: String = "") {
        _editableName = State(initialValue: projectName)
    }

    let aprilGrid: [Int?] = [
        nil, nil, 1, 2, 3, 4, 5,
        6, 7, 8, 9, 10, 11, 12,
        13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26,
        27, 28, 29, 30, nil, nil, nil
    ]

    var body: some View {
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Tombol kembali
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(Color.brandBlue)
                }
            }
            // Nama project di tengah — bisa langsung diedit
            ToolbarItem(placement: .principal) {
                TextField("Project Name", text: $editableName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.brandBlue)
                    .frame(maxWidth: 220)
            }
            // Tombol simpan
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(Color.brandBlue)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Save project")
            }
        }
    }

    var topicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outline")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brandBlue, lineWidth: 1.5)
                    )

                if topic.isEmpty {
                    Text("Enter your project topic...")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("References")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color.brandBlue)
                            .frame(width: 34, height: 34)
                        Image(systemName: "plus")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                    }
                }
                .accessibilityLabel("Add reference")
            }

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brandBlue.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )

                VStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                        .font(.title)
                        .foregroundStyle(Color.brandBlue.opacity(0.5))
                    Text("Tap + to add references")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 100)
        }
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

                if script.isEmpty {
                    Text("Write your script here...")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

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
                    ForEach(0..<3, id: \.self) { _ in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemFill))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.separator), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                )
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                    }
                }

                Button(action: {}) {
                    Text("+ Add More")
                        .font(.subheadline)
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

                if caption.isEmpty {
                    Text("Write your caption here...")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

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
                    .fill(Color(.systemFill))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundStyle(.secondary)
                            .font(.headline)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("No music selected")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    Text("Tap to choose music")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Button(action: { withAnimation { musicExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(musicExpanded ? 180 : 0))
                }
                .accessibilityLabel("Toggle music selector")
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
                                .font(.caption.bold())
                                .foregroundStyle(.primary)
                        }
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.brandBlue)
                        }
                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.brandBlue)
                        }
                    }
                }

                HStack(spacing: 0) {
                    ForEach(["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"], id: \.self) { day in
                        Text(day)
                            .font(.caption2.bold())
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
                                        .foregroundStyle(selectedDay == day ? Color.white : Color.primary)
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
                    Text("12:00")
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
                                .font(.subheadline.bold())
                                .foregroundStyle(isAM ? Color.white : Color.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(isAM ? Color.brandBlue : Color.clear)
                                .cornerRadius(isAM ? 10 : 0)
                        }
                        Button(action: { isAM = false }) {
                            Text("PM")
                                .font(.subheadline.bold())
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
}

#Preview {
    AddProjectScreen()
}
