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

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreatorProject.createdAt, order: .reverse) private var projects: [CreatorProject]

    @State private var selectedProject: CreatorProject?
    @State private var isCreatingNew: Bool = false
    @State private var newProjectTitle: String = ""
    @State private var isSaved = false
    @State private var savedProjectTitle: String = ""

    // Apakah tombol Save aktif
    private var canSave: Bool {
        selectedProject != nil || isCreatingNew
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !isSaved {
                    VStack(alignment: .leading, spacing: 16) {

                        // Preview konten yang di-share
                        previewBannerView
                            .padding(.horizontal)
                            .padding(.top)

                        Text("Save to project:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.horizontal)

                        // ── Opsi: Buat project baru ──
                        VStack(alignment: .leading, spacing: 0) {
                            Button {
                                isCreatingNew = true
                                selectedProject = nil
                            } label: {
                                HStack {
                                    Image(
                                        systemName: isCreatingNew
                                            ? "checkmark.circle.fill"
                                            : "plus.circle"
                                    )
                                    .foregroundColor(isCreatingNew ? Color.brandBlue : .gray)

                                    Text("Create New Project")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                            }
                            .buttonStyle(.plain)

                            // Field nama project (opsional)
                            if isCreatingNew {
                                TextField("Project name (optional)", text: $newProjectTitle)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 10)
                            }

                            Divider()
                        }

                        // ── Daftar project yang sudah ada ──
                        if projects.isEmpty {
                            VStack(spacing: 8) {
                                Text("No existing projects found.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.top, 4)
                            }
                        } else {
                            List(projects) { project in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(
                                            project.title.isEmpty
                                                ? "Untitled Project"
                                                : project.title
                                        )
                                        .font(.body)
                                        .fontWeight(.medium)

                                        if !project.outline.isEmpty {
                                            Text(project.outline)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                    if selectedProject?.id == project.id && !isCreatingNew {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.brandBlue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedProject = project
                                    isCreatingNew = false
                                }
                            }
                            .listStyle(.plain)
                        }

                        // ── Tombol Simpan ──
                        Button(action: saveReferenceToProject) {
                            Text("Save Reference")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(canSave ? Color.brandBlue : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(!canSave)
                        .padding()
                    }

                } else {
                    // ── Tampilan sukses ──
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.green)
                        Text("Saved to \(savedProjectTitle.isEmpty ? "New Project" : savedProjectTitle)")
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

    // MARK: - Dynamic Preview Banner
    @ViewBuilder
    private var previewBannerView: some View {
        HStack(spacing: 12) {
            if let firstImage = rawImages.first {
                Image(uiImage: firstImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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

    // MARK: - Save Logic

    private func saveReferenceToProject() {
        let targetProject: CreatorProject

        if isCreatingNew {
            // Buat project baru
            let trimmedTitle = newProjectTitle.trimmingCharacters(in: .whitespaces)
            let newProject = CreatorProject(
                title: trimmedTitle,
                outline: "",
                createdAt: .now
            )
            modelContext.insert(newProject)
            targetProject = newProject
            savedProjectTitle = trimmedTitle.isEmpty ? "New Project" : trimmedTitle
        } else {
            guard let project = selectedProject else { return }
            targetProject = project
            savedProjectTitle = project.title
        }

        let platformString = extractPlatform(from: rawURL)

        if !rawImages.isEmpty {
            for image in rawImages {
                guard let filename = SharedContentManager.shared.saveImage(image) else { continue }
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
                .trimmingCharacters(in: .whitespacesAndNewlines)
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

        do {
            try modelContext.save()
            withAnimation { isSaved = true }
        } catch {
            print("❌ ShareRootView save error: \(error)")
        }
    }

    private func extractPlatform(from urlString: String?) -> String {
        guard let urlString = urlString?.lowercased() else { return "General Reference" }
        if urlString.contains("instagram.com") { return "Instagram" }
        if urlString.contains("tiktok.com")    { return "TikTok" }
        if urlString.contains("youtube.com") || urlString.contains("youtu.be") { return "YouTube" }
        return "Web Resource"
    }
}
