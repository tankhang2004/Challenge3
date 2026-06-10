//  CategoryPickerSectionView.swift
//  Challenge3

import SwiftUI

// AppStorage key shared across all screens
let kCategoriesStorageKey = "lumioCategories"
let kCategoriesDefault    = "Education,Lifestyle,Entertainment,Business,Tech"

// Helper: String comma-separated ↔ Set<String>
func categoriesFromString(_ str: String) -> Set<String> {
    Set(str.split(separator: ",").map(String.init).filter { !$0.isEmpty })
}
func categoriesToString(_ set: Set<String>) -> String {
    set.sorted().joined(separator: ",")
}

struct CategoryPickerSectionView: View {
    @Binding var selectedCategories: Set<String>
    let categories: [String]
    let onAddCategory: () -> Void
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Category")
                    .font(.headline)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            if selectedCategories.contains(cat) {
                                selectedCategories.remove(cat)
                            } else {
                                selectedCategories.insert(cat)
                            }
                        } label: {
                            Text(cat)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategories.contains(cat)
                                        ? Color.brandOrange
                                        : Color(.systemFill)
                                )
                                .foregroundStyle(
                                    selectedCategories.contains(cat) ? Color.white : Color.primary
                                )
                                .clipShape(Capsule())
                        }
                    }

                    // Button to add a new category
                    Button(action: onAddCategory) {
                        Image(systemName: "plus")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(.systemFill))
                            .foregroundStyle(Color.primary)
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
