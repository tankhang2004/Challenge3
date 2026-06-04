
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

    // MARK: - Local edit state (mirrors the project fields)

    @State private var title: String
    @State private var outline: String
    @State private var script: String
    @State private var caption: String

    // MARK: - When to Post State

    @State private var displayedMonth: Date
    @State private var selectedDate: Date?
    @State private var postHour: Int
    @State private var postMinute: Int
    @State private var isAM: Bool
    @State private var showTimePicker: Bool = false

    // MARK: - References State

    @State private var showAddReferenceSheet: Bool = false
    @State private var previewReference: ReferencePreviewPayload?

    // MARK: - Footage State

    @State private var footagePickerItems: [PhotosPickerItem] = []
    @State private var footageImages: Array<UIImage> = []
    @State private var footageVideoURLs: [URL] = []         // ← new


    // MARK: - UI State

    @State private var musicExpanded: Bool = false
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var isSaving: Bool = false
    @State private var showDeleteConfirm: Bool = false

    @State private var selectedSong: SongSelection? = nil
    
    
    // MARK: - Error state for title, outline, and caption
    
    @State private var titleHasError: Bool = false
    @State private var outlineHasError: Bool = false
    @State private var captionHasError: Bool = false
    
    // MARK: - Init — seed local state from the project

    init(project: CreatorProject) {
        self.project = project

        _title   = State(initialValue: project.title)
        _outline   = State(initialValue: project.outline)
        _script  = State(initialValue: project.scripts.first?.content ?? "")
        _caption = State(initialValue: project.captions.first?.content ?? "")
        // Seed music
        _selectedSong = State(
            initialValue: project.music.map { SongSelection(from: $0) }
        )
        
        let postDate = project.postDate ?? project.createdAt
        _displayedMonth = State(initialValue: Calendar.current.startOfMonth(for: postDate))
        _selectedDate   = State(initialValue: project.postDate)

        // Decompose postDate into hour / minute / AM-PM
        let cal        = Calendar.current
        let rawHour    = project.postDate.map { cal.component(.hour, from: $0) } ?? 12
        let rawMinute  = project.postDate.map { cal.component(.minute, from: $0) } ?? 0
        _isAM          = State(initialValue: rawHour < 12)
        _postHour      = State(initialValue: rawHour % 12 == 0 ? 12 : rawHour % 12)
        _postMinute    = State(initialValue: rawMinute)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    titleSection
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
        .alert("Missing Info", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
//        .confirmationDialog(
//            "Delete \"\(project.title)\"?",
//            isPresented: $showDeleteConfirm,
//            titleVisibility: .visible
//        ) {
//            Button("Delete", role: .destructive) { deleteProject() }
//            Button("Cancel", role: .cancel) {}
//        }
        .sheet(isPresented: $showAddReferenceSheet) {
            addReferenceSheet
        }
        .sheet(item: $previewReference) { payload in
            ReferencePreviewSheetView(payload: payload)
        }
        .onAppear {loadExistingFootage() }
    }

    private func loadExistingFootage() {
        // Load images
        footageImages = project.images.compactMap { item in
            SharedContentManager.shared.loadImage(filename: item.filename)
        }

        // Load videos from documents directory
        let docsURL = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        )[0]
        footageVideoURLs = project.videos.compactMap { item in
            let url = docsURL.appendingPathComponent(item.filePath)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }
        
//        if let musicItem = project.music {
//            selectedSong = SongSelection(from: musicItem)
//        }
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
            label: "Project Title",
            placeholder: "Give your project a name...",
            text: $title,
            editorMinHeight: 48,
            hasError: titleHasError,
            errorMessage: "Project title can't be empty"
        )
        .onChange(of: title) { titleHasError = false }
    }

    // MARK: - Outline Section
    private var outlineSection: some View {
        ProjectTextFieldView(
            label: "Outline",
            placeholder: "E.g.: This content talks about my daily life, with the main focus being my student life at ADA, showcasing my learning journey and interaction with fellow learners.",
            text: $outline,
            hasError: outlineHasError,
            errorMessage: "Outline can't be empty"
        )
        .onChange(of: outline) { outlineHasError = false }
    }

    // MARK: - Script Section
    private var scriptSection: some View {
        ProjectTextFieldView(
            label: "Script",
            placeholder: "Write your script here...",
            text: $script,
            editorMinHeight: 80
        )
    }

    // MARK: - Caption Section
    private var captionSection: some View {
        ProjectTextFieldView(
            label: "Caption",
            placeholder: "Write your caption here...",
            text: $caption,
            editorMinHeight: 90,
            hasError: captionHasError,
            errorMessage: "Caption exceeds 2200 characters"
        )
        .onChange(of: caption) {
            captionHasError = caption.count > 2200
        }
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
        ZStack{
            Color.brandOrange
                .frame(width: 340, height: 35)
                .blur(radius: 300)
            Button {
                showDeleteConfirm = true
            } label: {
                HStack {
                    Spacer()
                    Label("Delete Project", systemImage: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.vertical, 14)
                
            }
            .glassEffect()
            .tint(.orange)
                    .confirmationDialog(
                        "Delete \"\(project.title)\"?",
                        isPresented: $showDeleteConfirm,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) { deleteProject() }
                        Button("Cancel", role: .cancel) {}
                    }
//                    .buttonStyle(.glassProminent)
            //        .tint(.orange)
            
        }
    }


    // MARK: - Save Logic
    private func saveChanges() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            titleHasError = true
            validationMessage = "Please enter a project title."
            showValidationAlert = true
            return
        }
        guard !outline.trimmingCharacters(in: .whitespaces).isEmpty else {
            outlineHasError = true
            validationMessage = "Please enter a outline."
            showValidationAlert = true
            return
        }
        guard caption.count <= 2200 else {
            captionHasError = true
            validationMessage = "Caption exceeds the 2200 character limit."
            showValidationAlert = true
            return
        }

        isSaving = true

        // Update top-level fields
        project.title = title.trimmingCharacters(in: .whitespaces)
        project.outline = outline.trimmingCharacters(in: .whitespaces)

        // Update postDate
        project.postDate = selectedDate.map { day in
            var components = Calendar.current.dateComponents([.year, .month, .day], from: day)
            components.hour   = isAM ? postHour % 12 : (postHour % 12) + 12
            components.minute = postMinute
            return Calendar.current.date(from: components) ?? day
        }

        // Update or create script
        let trimmedScript = script.trimmingCharacters(in: .whitespaces)
        if let existing = project.scripts.first {
            existing.content = trimmedScript
        } else if !trimmedScript.isEmpty {
            project.scripts.append(ScriptItem(content: trimmedScript))
        }

        // Update or create caption
        let trimmedCaption = caption.trimmingCharacters(in: .whitespaces)
        if let existing = project.captions.first {
            existing.content = trimmedCaption
        } else if !trimmedCaption.isEmpty {
            project.captions.append(CaptionItem(content: trimmedCaption, platform: "tiktok"))
        }
        
        // Save selected music
        project.music = selectedSong?.toMusicItem()

        // Update images — delete old files, save current ones
        for imageItem in project.images {
            SharedContentManager.shared.deleteImage(filename: imageItem.filename)
        }
        project.images.removeAll()
        for image in footageImages {
            if let filename = SharedContentManager.shared.saveImage(image) {
                project.images.append(ImageItem(filename: filename))
            }
        }

        // Update videos — delete old files, save current ones
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
        var thumbnailFilename: String?
        if let firstImage = footageImages.first {

            thumbnailFilename =
                SharedContentManager.shared.saveImage(firstImage)
        }
        else if let firstVideoURL = footageVideoURLs.first,
                let thumbnail =
                    VideoThumbnailGenerator.thumbnail(
                        from: firstVideoURL
                    )
        {
            thumbnailFilename =
                SharedContentManager.shared.saveImage(thumbnail)
        }
        project.thumbnailFilename = thumbnailFilename
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            isSaving = false
            validationMessage = "Failed to save: \(error.localizedDescription)"
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
