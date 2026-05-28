import SwiftUI

struct AddProjectScreen: View {

    @State var topic = ""
    @State var script = ""
    @State var caption = ""
    @State var selectedDay: Int? = nil
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
                            Text("Add Project")
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

                if topic.isEmpty {
                    Text("Enter your project topic...")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

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

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "3FA9F7").opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )

                VStack(spacing: 6) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "3FA9F7").opacity(0.5))
                    Text("Tap + to add references")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 100)
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

                if script.isEmpty {
                    Text("Write your script here...")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

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
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            )
                        Image(systemName: "plus")
                            .font(.system(size: 22))
                            .foregroundColor(Color.gray.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            )
                        Image(systemName: "plus")
                            .font(.system(size: 22))
                            .foregroundColor(Color.gray.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            )
                        Image(systemName: "plus")
                            .font(.system(size: 22))
                            .foregroundColor(Color.gray.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
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

                if caption.isEmpty {
                    Text("Write your caption here...")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

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
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("No music selected")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Tap to choose music")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray.opacity(0.7))
                }

                Spacer()

                Button(action: { withAnimation { musicExpanded.toggle() } }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray)
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
                                        .foregroundColor(selectedDay == day ? .white : .black)
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
                    Text("12:00")
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
}

#Preview {
    AddProjectScreen()
}
