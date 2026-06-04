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
    @State private var topic: String = ""
    @State private var script: String = ""
    @State private var caption: String = ""

    // MARK: - Init
    public init(initialTitle: String = "") {
        _title = State(initialValue: initialTitle)
    }

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
    @State private var footageVideoURLs: [URL] = []          // ← new

    @State private var showFootagePicker: Bool = false

    // MARK: - Validation / Save

    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var isSaving: Bool = false

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

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
//                    Text("Add Project")
//                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(Color.accentColor)
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
                            .foregroundColor(.accentColor)
                    }
                }
            }
//            .buttonStyle(.plain)                    // ✅ kills liquid glass container entirely
//            .buttonBorderShape(.circle)             // ✅ forces hit area to circle
            .disabled(isSaving)
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        ProjectTextFieldView(
            label: "Project Title",
            placeholder: "Give your project a name...",
            text: $title,
            editorMinHeight: 48
        )
    }

    // MARK: - Topic Section
    private var topicSection: some View {
        ProjectTextFieldView(
            label: "Topic",
            placeholder: "Enter your project topic...",
            text: $topic
        )
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
            editorMinHeight: 90
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
            }
        )
    }
//
//    // MARK: - Add Reference Sheet
//
    private var addReferenceSheet: some View {
        AddReferenceSheetView { newRef in
            pendingReferences.append(newRef)
            showAddReferenceSheet = false
        } onCancel: {
            showAddReferenceSheet = false
        }
    }
//
    
    // MARK: - Footage Section

    private var footageSection: some View {
        FootageSectionView(
            footageImages: $footageImages,
            footagePickerItems: $footagePickerItems,
            footageVideoURLs: $footageVideoURLs             // ← new
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
        
        // Attach images
        for image in footageImages {
            if let filename = SharedContentManager.shared.saveImage(image) {
                let item = ImageItem(filename: filename)
                project.images.append(item)
            }
        }

        // Attach videos
        for videoURL in footageVideoURLs {
            let filename = "\(UUID().uuidString).mov"
            let destURL = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            )[0].appendingPathComponent(filename)

            if (try? FileManager.default.copyItem(at: videoURL, to: destURL)) != nil {
                let item = VideoItem(filePath: filename)
                project.videos.append(item)
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
            forSecurityApplicationGroupIdentifier: "group.com.richard.challenge3"
        ) as Any)
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



// MARK: - Preview

#Preview {
    NavigationStack {
        AddProjectScreen()
    }
    .modelContainer(for: [CreatorProject.self, ReferenceItem.self], inMemory: true)
}
