//
//  ShareGalleryScreen.swift
//  Challenge3
//
//  Created by Agung Ananda on 02/06/26.
//

import SwiftUI

struct ShareGalleryScreen: View {
    let linkTitle: String
    let linkSource: String
    let linkURL: URL?

    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var selectedProject: String = "Create new project"
    @State private var selectedFolder: String = "References"
    @State private var noteText: String = ""

    let projectOptions = ["A Day in My Life", "Lebaran Idul Adha"]
    let folderOptions = ["References", "Assets"]
    @State private var isCreatingNew: Bool = true
    @State private var newprojectName: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {

                // Save to section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Save to")
                        .font(.headline)

                    Menu {
                        Button ("Create New Project"){
                            selectedProject = "Create new project"
                            isCreatingNew = true
                        }
                        Divider()
                        ForEach(projectOptions, id: \.self) { option in
                            Button(option) { selectedProject = option
                                isCreatingNew = false}
                        }
                    } label: {
                        HStack {
                            Text(selectedProject)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                    }
                }
                
                if isCreatingNew {
                    TextField("Project name", text: $newprojectName)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue,lineWidth: 1.5)
                        )
                }

                // Folder section
                HStack(alignment: .center) {
                    Text("Save attachment in")
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Menu {
                        ForEach(folderOptions, id: \.self) { option in
                            Button(option) { selectedFolder = option }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedFolder)
                                .foregroundStyle(.primary)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                    }
                }

                // Note + link preview card
                VStack(alignment: .leading, spacing: 0) {
                    TextField("Add text to your project", text: $noteText, axis: .vertical)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 12)

                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.white.opacity(0.6))
                            )
                    }
                    .padding(14)
                    .background(Color(red: 0.22, green: 0.35, blue: 0.62))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.blue, lineWidth: 1.5)
                )

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onCancel) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle")
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Lumio")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save", action: onSave)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

#Preview {
    ShareGalleryScreen(
        linkTitle: "A Day in my Life as Student",
        linkSource: "Instagram.com",
        linkURL: nil,
        onSave: { print("saved") },
        onCancel: { print("cancelled") }
    )
}
