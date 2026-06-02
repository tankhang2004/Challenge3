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
                .background(Color(.systemFill))
                .cornerRadius(12)

            HStack(spacing: 12) {

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemFill))
                        .foregroundStyle(.primary)
                        .cornerRadius(12)
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
                        .background(isNextDisabled ? Color.brandBlue.opacity(0.35) : Color.brandBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
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
