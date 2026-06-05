//  ProjectTextFieldView.swift
//  Challenge3

import SwiftUI

struct ProjectTextFieldView: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var font: Font = .subheadline
    var editorMinHeight: CGFloat = 72
    var limit: Int? = nil   // karakter maksimum, nil = tidak ada batas

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.headline)
                Spacer()
                if let limit {
                    Text("\(text.count)/\(limit)")
                        .font(.caption)
                        .foregroundStyle(text.count >= limit ? Color.red : Color.secondary)
                }
            }

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
        .onChange(of: text) { _, newValue in
            if let limit, newValue.count > limit {
                text = String(newValue.prefix(limit))
            }
        }
    }
}
