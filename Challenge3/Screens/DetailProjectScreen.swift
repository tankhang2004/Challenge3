//  DetailProjectScreen.swift
//  Challenge3

import SwiftUI
import SwiftData
import PhotosUI

struct DetailProjectScreen: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - SwiftData object

    @Bindable var project: CreatorProject

    // MARK: - Local edit state

    @State private var title: String
    @State private var outline: String     // stored and displayed as "Outline" in the UI
    @State private var script: String
    @State private var caption: String

    // MARK: - Category State
    @AppStorage(kCategoriesStorageKey) private var categoriesRaw: String = ""
    @State private var selectedCategories: Set<String>
    @State private var showAddCategoryAlert: Bool = false
    @State private var newCategoryInput: String = ""

    private var defaultCategories: [String] {
        kCategoriesDefault.split(separator: ",").map(String.init)
    }

    private var userCategories: [String] {
        categoriesRaw.isEmpty ? [] : categoriesRaw.split(separator: ",").map(String.init).filter { !$0.isEmpty }
    }

    private var categoryList: [String] {
        defaultCategories + userCategories
    }

    // MARK: - When to Post State

    @State private var displayedMonth: Date
    @State private var selectedDate: Date?
    @State private var postHour: Int
    @State private var postMinute: Int
    @State private var isAM: Bool? = nil
    @State private var showTimePicker: Bool = false

    // MARK: - References State

    @State private var showAddReferenceSheet: Bool = false
    @State private var previewReference: ReferencePreviewPayload?

    // MARK: - Footage State

    @State private var footagePickerItems: [PhotosPickerItem] = []
    @State private var footageImages: Array<UIImage> = []
    @State private var footageVideoURLs: [URL] = []

    // MARK: - UI State

    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var isSaving: Bool = false
    @State private var showDeleteConfirm: Bool = false

    @State private var selectedSong: SongSelection? = nil

    // MARK: - Init

    init(project: CreatorProject) {
        self.project = project

        _title              = State(initialValue: project.title)
        _outline            = State(initialValue: project.outline)
        _script             = State(initialValue: project.scripts.first?.content ?? "")
        _caption            = State(initialValue: project.captions.first?.content ?? "")
        _selectedCategories = State(initialValue: categoriesFromString(project.category))
        _selectedSong       = State(initialValue: project.music.map { SongSelection(from: $0) })

        let postDate    = project.postDate ?? project.createdAt
        _displayedMonth = State(initialValue: Calendar.current.startOfMonth(for: postDate))
        _selectedDate   = State(initialValue: project.postDate)

        let cal       = Calendar.current
        let rawHour   = project.postDate.map { cal.component(.hour,   from: $0) } ?? 12
        let rawMinute = project.postDate.map { cal.component(.minute, from: $0) } ?? 0
        _isAM         = State(initialValue: Optional(rawHour < 12))
        _postHour     = State(initialValue: rawHour % 12 == 0 ? 12 : rawHour % 12)
        _postMinute   = State(initialValue: rawMinute)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
                    categorySection
                    outlineSection
                    referencesSection
                    scriptSection
                    footageSection
                    captionSection
                    musicSection
                    whenToPostSection
                    deleteSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .alert(String(localized: "Missing Info"), isPresented: $showValidationAlert) {
            Button(String(localized: "Got it"), role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
        .alert(String(localized: "New Category"), isPresented: $showAddCategoryAlert) {
            TextField(String(localized: "e.g. Finance, Health…"), text: $newCategoryInput)
            Button(String(localized: "Add")) {
                let name = newCategoryInput.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty && !categoryList.contains(name) {
                    var updated = userCategories
                    updated.append(name)
                    categoriesRaw = updated.joined(separator: ",")
                    selectedCategories.insert(name)
                }
                newCategoryInput = ""
            }
            Button(String(localized: "Cancel"), role: .cancel) { newCategoryInput = "" }
        } message: {
            Text(String(localized: "Enter a name for the new category."))
        }
        .sheet(isPresented: $showAddReferenceSheet) {
            addReferenceSheet
        }
        .sheet(item: $previewReference) { payload in
            ReferencePreviewSheetView(payload: payload)
        }
        .onAppear { loadExistingFootage() }
    }

    private func loadExistingFootage() {
        footageImages = project.images.compactMap { item in
            SharedContentManager.shared.loadImage(filename: item.filename)
        }
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        footageVideoURLs = project.videos.compactMap { item in
            let url = docsURL.appendingPathComponent(item.filePath)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.brandBlue)
            }
            .buttonStyle(.plain)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                saveChanges()
            } label: {
                if isSaving {
                    ProgressView()
                        .tint(.blue)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        ProjectTextFieldView(
            label: String(localized: "Project Title"),
            placeholder: String(localized: "Give your project a name…"),
            text: $title,
            editorMinHeight: 48,
            limit: 80
        )
    }

    // MARK: - Category Section
    private var categorySection: some View {
        CategoryPickerSectionView(
            selectedCategories: $selectedCategories,
            categories: categoryList,
            onAddCategory: { showAddCategoryAlert = true },
        )
    }

    // MARK: - Outline Section
    private var outlineSection: some View {
        ProjectTextFieldView(
            label: String(localized: "Outline"),
            placeholder: String(localized: "E.g.: This content talks about my daily life, with the main focus being my student life at ADA."),
            text: $outline,
            limit: 1000,
            errorMessage: String(localized: "Outline can't be empty")
        )
    }

    // MARK: - Script Section
    private var scriptSection: some View {
        ProjectTextFieldView(
            label: String(localized: "Script"),
            placeholder: String(localized: "E.g. Hook: Wanna find out how an ADA student spend their day? Watch till the end! \nMain: G'morning, this is how I start my day..."),
            text: $script,
            editorMinHeight: 80,
            limit: 5000,
        )
    }

    // MARK: - Caption Section
    private var captionSection: some View {
        ProjectTextFieldView(
            label: String(localized: "Caption"),
            placeholder: String(localized: "E.g.: A day in my life as an ADA student! Come with me on this journey! #fyp #foryoupage"),
            text: $caption,
            editorMinHeight: 90,
            limit: 2200,
            errorMessage: String(localized: "Caption has exceeded the 2200 character limit")
        )
    }

    // MARK: - References Section

    private var referencesSection: some View {
        ProjectReferenceSectionView(
            references: project.references,
            onAdd: { showAddReferenceSheet = true },
            onDelete: { index in
                withAnimation {
                    var refs = project.references
                    refs.remove(at: index)
                    project.references = refs
                }
            },
            onTap: { ref in
                previewReference = ReferencePreviewPayload(reference: ref)
            }
        )
    }

    private var addReferenceSheet: some View {
        AddReferenceSheetView { newRef in
            project.references.append(newRef)
            showAddReferenceSheet = false
        } onCancel: {
            showAddReferenceSheet = false
        }
    }

    // MARK: - Footage Section

    private var footageSection: some View {
        FootageSectionView(
            footageImages: $footageImages,
            footagePickerItems: $footagePickerItems,
            footageVideoURLs: $footageVideoURLs
        )
    }

    // MARK: - Music Section

    private var musicSection: some View {
        ProjectMusicSectionView(selectedSong: $selectedSong)
    }

    // MARK: - When to Post Section

    private var whenToPostSection: some View {
        ProjectWhenToPostSectionView(
            displayedMonth: $displayedMonth,
            selectedDate: $selectedDate,
            postHour: $postHour,
            postMinute: $postMinute,
            isAM: $isAM,
            showTimePicker: $showTimePicker
        )
    }

    // MARK: - Delete Section

    private var deleteSection: some View {
        ZStack {
            Color.brandOrange
                .frame(width: 340, height: 35)
                .blur(radius: 300)
            Button {
                showDeleteConfirm = true
            } label: {
                HStack {
                    Spacer()
                    Label(String(localized: "Delete Project"), systemImage: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.vertical, 14)
            }
            .modify {
                if #available(iOS 26.0, *) {
                    $0.glassEffect()
                } else {
                    $0.background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .tint(.orange)
            .confirmationDialog(
                String(localized: "Delete \"\(project.title)\"?"),
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button(String(localized: "Delete"), role: .destructive) { deleteProject() }
                Button(String(localized: "Cancel"), role: .cancel) {}
            }
        }
    }

    // MARK: - Save Logic

    private func saveChanges() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = String(localized: "Please give your project a title before saving.")
            showValidationAlert = true
            return
        }

        isSaving = true

        project.title    = title.trimmingCharacters(in: .whitespaces)
        project.outline  = outline.trimmingCharacters(in: .whitespaces)
        project.category = categoriesToString(selectedCategories)

        project.postDate = selectedDate.map { day in
            var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
            components.hour   = (isAM == true) ? postHour % 12 : (postHour % 12) + 12
            components.minute = postMinute
            return Calendar.current.date(from: components) ?? day
        }

        let trimmedScript = script.trimmingCharacters(in: .whitespaces)
        if let existing = project.scripts.first {
            existing.content = trimmedScript
        } else if !trimmedScript.isEmpty {
            project.scripts.append(ScriptItem(content: trimmedScript))
        }

        let trimmedCaption = caption.trimmingCharacters(in: .whitespaces)
        if let existing = project.captions.first {
            existing.content = trimmedCaption
        } else if !trimmedCaption.isEmpty {
            project.captions.append(CaptionItem(content: trimmedCaption, platform: "tiktok"))
        }

        project.music = selectedSong?.toMusicItem()

        for imageItem in project.images {
            SharedContentManager.shared.deleteImage(filename: imageItem.filename)
        }
        project.images.removeAll()
        for image in footageImages {
            if let filename = SharedContentManager.shared.saveImage(image) {
                project.images.append(ImageItem(filename: filename))
            }
        }

        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for videoItem in project.videos {
            let oldURL = docsURL.appendingPathComponent(videoItem.filePath)
            try? FileManager.default.removeItem(at: oldURL)
        }
        project.videos.removeAll()
        for videoURL in footageVideoURLs {
            let filename = "\(UUID().uuidString).mov"
            let destURL = docsURL.appendingPathComponent(filename)
            if (try? FileManager.default.copyItem(at: videoURL, to: destURL)) != nil {
                project.videos.append(VideoItem(filePath: filename))
            }
        }

        if let firstImage = footageImages.first {
            project.thumbnailFilename = SharedContentManager.shared.saveImage(firstImage)
        } else if let firstVideoURL = footageVideoURLs.first,
                  let thumbnail = VideoThumbnailGenerator.thumbnail(from: firstVideoURL) {
            project.thumbnailFilename = SharedContentManager.shared.saveImage(thumbnail)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            isSaving = false
            validationMessage = String(localized: "Something went wrong while saving. Please try again.")
            showValidationAlert = true
        }
    }

    // MARK: - Delete Logic

    private func deleteProject() {
        modelContext.delete(project)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: CreatorProject.self, ReferenceItem.self,
        configurations: config
    )
    let sample = CreatorProject(title: "Vlog A Day in My Life", outline: "A Day at ADA", createdAt: .now)
    container.mainContext.insert(sample)

    return NavigationStack {
        DetailProjectScreen(project: sample)
    }
    .modelContainer(container)
}
