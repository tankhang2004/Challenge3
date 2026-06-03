import SwiftUI

struct AddNewProjectView: View {

    @State private var projectName = ""
    @Environment(\.dismiss) var dismiss

    // Dipanggil saat user klik Next, membawa nama yang diisi
    let onNext: (String) -> Void

    var isNextDisabled: Bool {
        projectName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Text("Project's Name")
                .font(.title2.bold())

            Text("Input your project's name")
                .font(.body)
                .foregroundStyle(.secondary)

            TextField("Project's Name", text: $projectName)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)

            HStack(spacing: 12) {

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                        .glassEffect(.regular, in: .capsule)
                        .foregroundStyle(Color(.secondaryBlue))
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                }

                Button {
                    let name = projectName.trimmingCharacters(in: .whitespaces)
                    onNext(name)
                    dismiss()       // tutup sheet → trigger onDismiss di HomePageView
                } label: {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
                        .glassEffect(.regular.tint(Color("BrandBlue").opacity(isNextDisabled ? 0.35 : 0.85)),in: .capsule)
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
                }
                .disabled(isNextDisabled)
            }
        }
        .padding(28)
    }
}

#Preview {
    AddNewProjectView { name in
        print("Next tapped:", name)
    }
}
