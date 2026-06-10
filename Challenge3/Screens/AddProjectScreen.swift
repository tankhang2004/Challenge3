//  AddProjectScreen.swift
//  Challenge3

import SwiftUI
import SwiftData
import PhotosUI

public struct AddProjectScreen: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form State
    @State private var title: String
    @State private var outline: String   = ""
    @State private var script: String  = ""
    @State private var caption: String = ""

    // MARK: - Category State
    @AppStorage(kCategoriesStorageKey) private var categoriesRaw: String = ""
    @State private var selectedCategories: Set<String> = []
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

    // MARK: - Init
    public init(initialTitle: String = "") {
        _title = State(initialValue: initialTitle)
    }

    // MARK: - When to Post State

    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: .now)
    @State private var selectedDate: Date? = nil
    @State private var postHour: Int = 12
    @State private var postMinute: Int = 0
    @State private var isAM: Bool? = nil
    @State private var showTimePicker: Bool = false

    // MARK: - References State

    @State private var referenceURL: String = ""
    @State private var showAddReferenceSheet: Bool = false
    @State private var pendingReferences: Array<ReferenceItem> = []
    @State private var previewReference: ReferencePreviewPayload?

    // MARK: - Footage State

    @State private var footagePickerItems: [PhotosPickerItem] = []
    @State private var footageImages: Array<UIImage> = []
    @State private var footageVideoURLs: [URL] = []

    @State private var showFootagePicker: Bool = false

    // MARK: - Validation / Save

    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var isSaving: Bool = false

    @State private var selectedSong: SongSelection? = nil

    // MARK: - Error state for title, outline, and caption

    @State private var titleHasError: Bool = false
    @State private var outlineHasError: Bool = false
    @State private var captionHasError: Bool = false

    // MARK: - Body

    public var body: some View {
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
                    .foregroundColor(Color.accentColor)
            }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                saveProject()
            } label: {
                if isSaving {
                    ProgressView()
                        .tint(.blue)
                        .scaleEffect(0.7)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
            .disabled(isSaving)
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        ProjectTextFieldView(
            label: String(localized: "Project Title"),
            placeholder: String(localized: "e.g. Day in My Life Vlog"),
            text: $title,
            editorMinHeight: 48,
            limit: 80,
            hasError: titleHasError,
            errorMessage: String(localized: "Title can't be empty")
        )
        .onChange(of: title) { titleHasError = false }
    }

    // MARK: - Category Section
    private var categorySection: some View {
        CategoryPickerSectionView(
            selectedCategories: $selectedCategories,
            categories: categoryList,
            onAddCategory: { showAddCategoryAlert = true },
            subtitle: String(localized: "Pick a category that fits your content.")
        )
    }

    // MARK: - Outline Section
    private var outlineSection: some View {
        ProjectTextFieldView(
            label: String(localized: "Outline"),
            placeholder: String(localized: "E.g.: This content talks about my daily life, with the main focus being my student life at ADA."),
            text: $outline,
            limit: 1000,
            subtitle: String(localized: "Write a general outline of your content."),
            hasError: outlineHasError,
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
            subtitle: String(localized: "Write down your script.")
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
            subtitle: String(localized: "Write a caption for your video."),
            hasError: captionHasError,
            errorMessage: String(localized: "Caption has exceeded the 2200 character limit")
        )
    }

    // MARK: - References Section

    private var referencesSection: some View {
        ProjectReferenceSectionView(
            references: pendingReferences,
            onAdd: { showAddReferenceSheet = true },
            onDelete: { index in
                withAnimation {
                    var refs = pendingReferences
                    refs.remove(at: index)
                    pendingReferences = refs
                }
            },
            onTap: { ref in
                previewReference = ReferencePreviewPayload(reference: ref)
            },
            subtitle: String(localized: "Add links to videos that you might use as a reference.")
        )
    }

    private var addReferenceSheet: some View {
        AddReferenceSheetView { newRef in
            pendingReferences.append(newRef)
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
            footageVideoURLs: $footageVideoURLs,
            subtitle: String(localized: "Add photos and videos that you will use for the content.")
        )
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

    private var musicSection: some View {
        ProjectMusicSectionView(selectedSong: $selectedSong)
    }

    // MARK: - Save Logic

    private func saveProject() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            validationMessage = String(localized: "Please give your project a title before saving.")
            showValidationAlert = true
            return
        }

        isSaving = true

        // Compute postDate from the selected date and time
        let postDate: Date? = selectedDate.map { day in
            var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
            components.hour   = (isAM == true) ? postHour % 12 : (postHour % 12) + 12
            components.minute = postMinute
            return Calendar.current.date(from: components) ?? day
        }

        let project = CreatorProject(
            title: title.trimmingCharacters(in: .whitespaces),
            outline: outline.trimmingCharacters(in: .whitespaces),
            createdAt: .now
        )
        project.category = categoriesToString(selectedCategories)
        project.postDate = postDate

        if !script.trimmingCharacters(in: .whitespaces).isEmpty {
            project.scripts.append(ScriptItem(content: script))
        }

        if !caption.trimmingCharacters(in: .whitespaces).isEmpty {
            project.captions.append(CaptionItem(content: caption, platform: "tiktok"))
        }

        for ref in pendingReferences {
            project.references.append(ref)
        }

        project.music = selectedSong?.toMusicItem()

        for image in footageImages {
            if let filename = SharedContentManager.shared.saveImage(image) {
                project.images.append(ImageItem(filename: filename))
            }
        }

        for videoURL in footageVideoURLs {
            let filename = "\(UUID().uuidString).mov"
            let destURL = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            )[0].appendingPathComponent(filename)
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

        modelContext.insert(project)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            isSaving = false
            validationMessage = String(localized: "Something went wrong while saving. Please try again.")
            showValidationAlert = true
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

    // URL is optional; if provided it must start with http:// or https://
    private var isURLValid: Bool {
        let trimmed = refURL.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }
        return trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
    }

    private var canAdd: Bool {
        !refTitle.trimmingCharacters(in: .whitespaces).isEmpty && isURLValid
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Reference Details")) {
                    TextField(String(localized: "Title"), text: $refTitle)
                        .onChange(of: refTitle) { _, v in
                            if v.count > 100 { refTitle = String(v.prefix(100)) }
                        }

                    TextField(String(localized: "Creator / @handle"), text: $refCreator)
                        .onChange(of: refCreator) { _, v in
                            if v.count > 80 { refCreator = String(v.prefix(80)) }
                        }

                    Picker(String(localized: "Platform"), selection: $refPlatform) {
                        ForEach(platforms, id: \.self) { Text($0) }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        TextField(String(localized: "URL (optional)"), text: $refURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)

                        if !isURLValid {
                            Text(String(localized: "Please enter a valid URL starting with https://"))
                                .font(.caption)
                                .foregroundStyle(Color.red)
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Add Reference"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel"), action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        let ref = ReferenceItem(
                            title: refTitle.trimmingCharacters(in: .whitespaces),
                            creator: refCreator.trimmingCharacters(in: .whitespaces),
                            platform: refPlatform,
                            url: refURL.trimmingCharacters(in: .whitespaces)
                        )
                        onAdd(ref)
                    }
                    .disabled(!canAdd)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AddProjectScreen()
    }
    .modelContainer(for: [CreatorProject.self, ReferenceItem.self], inMemory: true)
}
