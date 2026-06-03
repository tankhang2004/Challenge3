//  ProjectTextFieldView.swift
//  Challenge3

import SwiftUI

struct ProjectTextFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var font: Font = .subheadline
    var editorMinHeight: CGFloat = 72

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.brandBlue, lineWidth: 1.5)
                    )

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
        }
    }
}
