//
//  ShareRootView.swift
//  LumioShareExtension
//

import SwiftUI
import SwiftData

struct ShareRootView: View {
    let rawText: String?
    let rawURL: String?
    let rawImages: [UIImage]
    let onDone: () -> Void
    
    // Read live projects from the shared App Group database
    @Query(sort: \CreatorProject.createdAt, order: .reverse) private var projects: [CreatorProject]
    @State private var selectedProject: CreatorProject?
    @State private var isSaved = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !isSaved {
                    VStack(alignment: .leading, spacing: 16) {
                        // Shared content preview banner
                        previewBannerView
                            .padding(.horizontal)
                            .padding(.top)
                        
                        Text("Select a Project to add this Reference:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Interactive List Selection
                        if projects.isEmpty {
                            VStack(spacing: 8) {
                                Spacer()
                                Image(systemName: "folder.badge.questionmark")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("No Active Projects Found")
                                    .font(.headline)
                                Text("Open Lumio to create a project first.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(projects) { project in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(project.title.isEmpty ? "Untitled Project" : project.title)
                                            .font(.body)
                                            .fontWeight(.medium)
                                        Text(project.outline)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    if selectedProject?.id == project.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.brandBlue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedProject = project
                                }
                            }
                            .listStyle(.plain)
                        }
                        
                        // Confirm Save Button Area
                        Button(action: saveReferenceToProject) {
                            Text("Save Reference")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(selectedProject == nil ? Color.gray : Color.brandBlue)
                                .cornerRadius(12)
                        }
                        .disabled(selectedProject == nil)
                        .padding()
                    }
                } else {
                    // Success View
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.green)
                        Text("Saved to \(selectedProject?.title ?? "Lumio")")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button("Done") {
                            onDone()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.brandBlue)
                    }
                    .padding()
                }
            }
            .navigationTitle("Save to Lumio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDone()
                    }
                }
            }
        }
    }
    
    // MARK: - Dynamic Preview Builder
    @ViewBuilder
    private var previewBannerView: some View {
        HStack(spacing: 12) {
            if let firstImage = rawImages.first {

                Image(uiImage: firstImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )
                    .overlay(alignment: .bottomTrailing) {

                        if rawImages.count > 1 {

                            Text("+\(rawImages.count - 1)")
                                .font(.caption2)
                                .padding(4)
                                .background(.black.opacity(0.7))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }

            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    Image(systemName: rawURL != nil ? "link" : "doc.text")
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    rawURL != nil
                        ? "Shared URL Link"
                        : rawImages.count > 1
                            ? "\(rawImages.count) Images"
                            : !rawImages.isEmpty
                                ? "Shared Image"
                                : "Shared Text Snip"
                )
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                Text(rawText ?? rawURL ?? "Media File Attachment")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.cardSurface)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - Save Processing Execution
//    private func saveReferenceToProject() {
//        guard let targetProject = selectedProject else { return }
//        
//        let platformString = extractPlatform(from: rawURL)
//        let fallbackTitle = rawText?.trimmingCharacters(in: .whitespacesAndNewlines).prefix(40) ?? "Shared Media Reference"
//        
//        // Assemble your target ReferenceItem model structural layout schema
//        let newReference = ReferenceItem(
//            title: rawURL ?? String(fallbackTitle),
//            platform: platformString
//        )
//        
//        // Append inside the target project model context
//        targetProject.references.append(newReference)
//        
//        // Context persistence layer commit sequence triggered automatically by SwiftData or manually:
//        if let context = targetProject.modelContext {
//            try? context.save()
//        }
//        
//        withAnimation {
//            isSaved = true
//        }
//    }
    private func saveReferenceToProject() {
        guard let targetProject = selectedProject else { return }

        let platformString = extractPlatform(from: rawURL)

        if !rawImages.isEmpty {

            for image in rawImages {

                guard let filename =
                    SharedContentManager.shared.saveImage(image)
                else { continue }

                let newReference = ReferenceItem(
                    title: "Shared Image",
                    creator: "Shared via Extension",
                    platform: platformString,
                    url: "",
                    imageFilename: filename,
                    fullText: nil
                )

                targetProject.references.append(newReference)
            }

        } else {

            let fallbackTitle =
                rawText?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .prefix(40)
                ?? "Shared Reference"

            let newReference = ReferenceItem(
                title: rawURL ?? String(fallbackTitle),
                creator: "Shared via Extension",
                platform: platformString,
                url: rawURL ?? "",
                imageFilename: nil,
                fullText: rawText
            )

            targetProject.references.append(newReference)
        }

        if let context = targetProject.modelContext {
            do {
                try context.save()

                withAnimation {
                    isSaved = true
                }

            } catch {
                print(error)
            }
        }
    }
    
    private func extractPlatform(from urlString: String?) -> String {
        guard let urlString = urlString?.lowercased() else { return "General Reference" }
        if urlString.contains("instagram.com") { return "Instagram" }
        if urlString.contains("tiktok.com") { return "TikTok" }
        if urlString.contains("youtube.com") || urlString.contains("youtu.be") { return "YouTube" }
        return "Web Resource"
    }
}
//import SwiftUI
//
//struct ShareRootView: View {
//
//    let onDone: () -> Void
//
//    var body: some View {
//
//        VStack(spacing: 20) {
//
//            Image(systemName: "checkmark.circle.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.green)
//
//            Text("Saved to Lumio")
//                .font(.title2)
//
//            Button("Done") {
//                onDone()
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//    }
//}


