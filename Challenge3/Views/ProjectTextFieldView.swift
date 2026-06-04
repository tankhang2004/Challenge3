//  ProjectTextFieldView.swift
//  Challenge3

import SwiftUI

struct ProjectTextFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var font: Font = .subheadline
    var editorMinHeight: CGFloat = 72
    var subtitle: String? = nil
    var hasError: Bool = false
    var errorMessage: String? = nil

// MARK: - Computed Stroke Color

    private var strokeColor: Color {
        if hasError {
            return Color(red: 251/255, green: 131/255, blue: 131/255)
        } else if !text.isEmpty {
            return Color.brandBlue
        } else {
            return Color.gray.opacity(0.3)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(strokeColor, lineWidth: 1.5)
                    )
                    .animation(.easeInOut(duration: 0.2), value: hasError)
                    .animation(.easeInOut(duration: 0.2), value: text.isEmpty)

                if text.isEmpty {
                    Text(placeholder)
                        .font(font)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                }

                TextEditor(text: $text)
                    .font(font)
                    .foregroundColor(.primary)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: editorMinHeight)
            }
            .frame(minHeight: editorMinHeight + 16)

            if hasError, let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color(red: 251/255, green: 131/255, blue: 131/255))
            }
        }
    }
}
