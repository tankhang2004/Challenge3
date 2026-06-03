//  AddProjectScreen.swift
//  Challenge3

import SwiftUI
import SwiftData
import PhotosUI

struct AddProjectScreen: View {
    

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State

    @State private var title: String = ""
    @State private var topic: String = ""
    @State private var script: String = ""
    @State private var caption: String = ""

    // MARK: - When to Post State

    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: .now)
    @State private var selectedDate: Date? = nil
    @State private var postHour: Int = 12
    @State private var postMinute: Int = 0
    @State private var isAM: Bool = true
    @State private var showTimePicker: Bool = false

    // MARK: - References State

    @State private var referenceURL: String = ""
    @State private var showAddReferenceSheet: Bool = false
    @State private var pendingReferences: Array<ReferenceItem> = []
    @State private var previewReference: ReferencePreviewPayload?

    // MARK: - Footage State

    @State private var footagePickerItems: [PhotosPickerItem] = []
    @State private var footageImages: Array<UIImage> = []
    @State private var showFootagePicker: Bool = false

    // MARK: - Validation / Save

    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var isSaving: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack {
            Color("F6F9FE").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    topicSection
                    referencesSection
                    scriptSection
                    footageSection
                    captionSection
                    whenToPostSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .alert("Missing Info", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
        .sheet(isPresented: $showAddReferenceSheet) {
            addReferenceSheet
        }
        .sheet(item: $previewReference) { payload in
            ReferencePreviewSheetView(payload: payload)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Project")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Color("3FA9F7"))
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                saveProject()
            } label: {
                ZStack {
//                    Circle()
//                        .fill(isSaving ? Color.gray : Color(hex: "3FA9F7"))
//                        .frame(width: 36, height: 36)
                    if isSaving {
                        ProgressView()
                            .tint(.blue)
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
//            .buttonStyle(.plain)                    // ✅ kills liquid glass container entirely
//            .buttonBorderShape(.circle)             // ✅ forces hit area to circle
            .disabled(isSaving)
        }
    }

    // MARK: - Title Section (new — needed for HomePageView card title)

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Project Title")
                .font(.system(size: 17, weight: .bold))
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("3FA9F7"), lineWidth: 1.5)
                    )

                if title.isEmpty {
                    Text("Give your project a name...")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

                TextEditor(text: $title)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 48)
            }
            .frame(minHeight: 60)
        }
    }

    // MARK: - Topic Section

    private var topicSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Topic")
                .font(.system(size: 17, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("3FA9F7"), lineWidth: 1.5)
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

    // MARK: - References Section

    private var referencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("References")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Button {
                    showAddReferenceSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color("3FA9F7"))
                            .frame(width: 34, height: 34)
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            if pendingReferences.isEmpty {
                // Empty placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color("3FA9F7").opacity(0.4),
                                    style: StrokeStyle(lineWidth: 1.5, dash: [6])
                                )
                        )

                    VStack(spacing: 6) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 26))
                            .foregroundColor(Color("3FA9F7").opacity(0.5))
                        Text("Tap + to add references")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 100)
                .onTapGesture { showAddReferenceSheet = true }

            } else {
                // Horizontal scroll of added references
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(pendingReferences.indices, id: \.self) { i in
                            referenceCard(pendingReferences[i], index: i)
                        }

                        // Inline add-more button
                        Button {
                            showAddReferenceSheet = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color("3FA9F7").opacity(0.4),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [6])
                                            )
                                    )
                                Image(systemName: "plus")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color("3FA9F7").opacity(0.5))
                            }
                            .frame(width: 100, height: 100)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func referenceCard(_ ref: ReferenceItem, index: Int) -> some View {
        let previewURL = referenceURL(from: ref.url)

        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                referencePreview(for: ref, url: previewURL)

                VStack(alignment: .leading, spacing: 6) {
                    Text(ref.title.isEmpty ? "Reference" : ref.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    if !ref.creator.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(ref.creator)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "link")
                        Text(ref.platform.isEmpty ? "Link" : ref.platform)
                    }
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color("3FA9F7"))

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
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color("3FA9F7").opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture {
                previewReference = ReferencePreviewPayload(reference: ref)
            }

            // Delete button
            Button {
                withAnimation {
                    var refs: Array<ReferenceItem> = pendingReferences
                    refs.remove(at: index)
                    pendingReferences = refs
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red.opacity(0.85))
                    .background(Color.white.clipShape(Circle()))
            }
            .offset(x: 6, y: -6)
        }
    }

    @ViewBuilder
    private func referencePreview(for ref: ReferenceItem, url: URL?) -> some View {
        ZStack(alignment: .topTrailing) {
            let isTextOnlyReference = ref.imageFilename == nil && url == nil && !ref.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

            Group {
                if let imageFilename = ref.imageFilename,
                   let image = SharedContentManager.shared.loadImage(filename: imageFilename) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let url {
                    URLPreviewView(url: url)
                } else if isTextOnlyReference {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "doc.text")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color("3FA9F7"))
                            Spacer()
                        }

                        Text(ref.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .lineLimit(4)

                        Spacer()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(
                        LinearGradient(
                            colors: [Color("3FA9F7").opacity(0.18), Color("3FA9F7").opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("3FA9F7").opacity(0.24),
                                    Color("3FA9F7").opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "link")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color("3FA9F7"))
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

            Text(ref.platform.isEmpty ? "Link" : ref.platform)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color("3FA9F7"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.92))
                .clipShape(Capsule())
                .padding(10)
        }
    }

    private func referenceURL(from rawURL: String) -> URL? {
        let trimmed = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }

        return URL(string: "https://\(trimmed)")
    }

    // MARK: - Add Reference Sheet

    private var addReferenceSheet: some View {
        AddReferenceSheetView { newRef in
            pendingReferences.append(newRef)
            showAddReferenceSheet = false
        } onCancel: {
            showAddReferenceSheet = false
        }
    }

    // MARK: - Script Section

    private var scriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Script")
                .font(.system(size: 17, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("3FA9F7"), lineWidth: 1.5)
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

    // MARK: - Footage Section

    private var footageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Footage")
                .font(.system(size: 17, weight: .bold))

            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        // Existing picked images
                        ForEach(footageImages.indices, id: \.self) { i in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: footageImages[i])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipped()
                                    .cornerRadius(8)

                                Button {
                                    footageImages.remove(at: i)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.red.opacity(0.8))
                                        .background(Color.white.clipShape(Circle()))
                                }
                                .offset(x: 6, y: -6)
                            }
                        }

                        // Add slot (always visible)
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
                            loadFootageImages(from: newItems)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if !footageImages.isEmpty {
                    Text("\(footageImages.count) item\(footageImages.count == 1 ? "" : "s") selected")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("3FA9F7"), lineWidth: 1.5)
            )
        }
    }

    // MARK: - Caption Section

    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caption")
                .font(.system(size: 17, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("3FA9F7"), lineWidth: 1.5)
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

    // MARK: - When to Post Section

    private var whenToPostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("When to Post")
                .font(.system(size: 17, weight: .bold))

            // Calendar card
            VStack(spacing: 10) {
                // Month navigation
                HStack {
                    Button {
                        displayedMonth = Calendar.current.date(
                            byAdding: .month, value: -1, to: displayedMonth
                        ) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("3FA9F7"))
                    }

                    Spacer()

                    Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    Button {
                        displayedMonth = Calendar.current.date(
                            byAdding: .month, value: 1, to: displayedMonth
                        ) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color("3FA9F7"))
                    }
                }

                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(["SUN","MON","TUE","WED","THU","FRI","SAT"], id: \.self) { d in
                        Text(d)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }

                // Day grid — real calendar, not hardcoded
                let days = calendarDays(for: displayedMonth)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7),
                    spacing: 2
                ) {
                    ForEach(days.indices, id: \.self) { i in
                        if let day = days[i] {
                            let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate ?? .distantPast)
                            let isToday = Calendar.current.isDateInToday(day)

                            Button {
                                selectedDate = day
                            } label: {
                                ZStack {
                                    if isSelected {
                                        Circle()
                                            .fill(Color("3FA9F7"))
                                            .frame(width: 34, height: 34)
                                    } else if isToday {
                                        Circle()
                                            .stroke(Color("3FA9F7"), lineWidth: 1.5)
                                            .frame(width: 34, height: 34)
                                    }
                                    Text("\(Calendar.current.component(.day, from: day))")
                                        .font(.system(size: 14))
                                        .foregroundColor(isSelected ? .white : isToday ? Color("3FA9F7") : .black)
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

            // Time picker row
            HStack {
                Text("Time")
                    .font(.system(size: 15, weight: .semibold))

                Spacer()

                // Tappable time display
                Button {
                    withAnimation { showTimePicker.toggle() }
                } label: {
                    Text(formattedTime)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                }

                // AM / PM toggle
                AMPMToggle(isAM: $isAM)

            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(14)

            // Inline hour/minute picker (shown on tap)
            if showTimePicker {
                HStack(spacing: 0) {
                    Picker("Hour", selection: $postHour) {
                        ForEach(1...12, id: \.self) { h in
                            Text(String(format: "%02d", h)).tag(h)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Text(":")
                        .font(.title2.bold())

                    Picker("Minute", selection: $postMinute) {
                        ForEach([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55], id: \.self) { m in
                            Text(String(format: "%02d", m)).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 140)
                .background(Color.white)
                .cornerRadius(14)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Save Logic

    private func saveProject() {
        // Validate required fields
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter a project title."
            showValidationAlert = true
            return
        }
        guard !topic.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = "Please enter a topic."
            showValidationAlert = true
            return
        }

        isSaving = true

        // Build postDate by combining selectedDate + hour/minute
        let postDate: Date? = selectedDate.map { day in
            var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
            components.hour = isAM ? postHour % 12 : (postHour % 12) + 12
            components.minute = postMinute
            return Calendar.current.date(from: components) ?? day
        }

        // Create the SwiftData object
        let project = CreatorProject(
            title: title.trimmingCharacters(in: .whitespaces),
            topic: topic.trimmingCharacters(in: .whitespaces),
            createdAt: .now
        )
        project.postDate = postDate

        // Attach script
        if !script.trimmingCharacters(in: .whitespaces).isEmpty {
            let scriptItem = ScriptItem(content: script)
            project.scripts.append(scriptItem)
        }

        // Attach caption
        if !caption.trimmingCharacters(in: .whitespaces).isEmpty {
            let captionItem = CaptionItem(content: caption, platform: "tiktok")
            project.captions.append(captionItem)
        }

        // Attach references
        for ref in pendingReferences {
            project.references.append(ref)
        }

        // Insert and save
        modelContext.insert(project)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            isSaving = false
            validationMessage = "Failed to save: \(error.localizedDescription)"
            showValidationAlert = true
        }
        print("📍 APP GROUP URL:", FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.Lumio"
        ) as Any)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        String(format: "%02d:%02d", postHour, postMinute)
    }

    /// Returns an array of optional Dates for the calendar grid.
    /// Nils represent padding cells before the first day of the month.
    private func calendarDays(for monthStart: Date) -> [Date?] {
        let calendar = Calendar.current
        guard
            let range = calendar.range(of: .day, in: .month, for: monthStart),
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart))
        else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) - 1 // 0 = Sunday
        let padding: [Date?] = Array(repeating: nil, count: weekdayOfFirst)

        let days: [Date?] = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }

        return padding + days
    }

    private func loadFootageImages(from items: [PhotosPickerItem]) {
        Task {
            var loaded: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loaded.append(image)
                }
            }
            await MainActor.run {
                footageImages = loaded
            }
        }
    }
}

// MARK: - Add Reference Sheet

struct AddReferenceSheetView: View {
    @State private var refTitle: String = ""
    @State private var refCreator: String = ""
    @State private var refPlatform: String = "Instagram"
    @State private var refURL: String = ""

    let platforms = ["Instagram", "TikTok", "YouTube", "Twitter/X", "Other"]
    let onAdd: (ReferenceItem) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Reference Details") {
                    TextField("Title", text: $refTitle)
                    TextField("Creator / @handle", text: $refCreator)
                    Picker("Platform", selection: $refPlatform) {
                        ForEach(platforms, id: \.self) { Text($0) }
                    }
                    TextField("URL (optional)", text: $refURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Reference")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let ref = ReferenceItem(
                            title: refTitle,
                            creator: refCreator,
                            platform: refPlatform,
                            url: refURL
                        )
                        onAdd(ref)
                    }
                    .disabled(refTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Calendar Extension

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AddProjectScreen()
    }
    .modelContainer(for: [CreatorProject.self, ReferenceItem.self], inMemory: true)
}
