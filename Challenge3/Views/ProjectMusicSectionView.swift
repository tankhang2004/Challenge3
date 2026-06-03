//  MusicSectionView.swift
//  Challenge3

import SwiftUI

struct ProjectMusicSectionView: View {
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Music Selection")
                .font(.headline)

            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("No music selected")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Tap to choose music")
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray.opacity(0.7))
                }

                Spacer()

                Button {
                    withAnimation { isExpanded.toggle() }
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color.brandBlue.opacity(0.05))
            .cornerRadius(14)
        }
    }
}
