import SwiftUI

struct ShareRootView: View {

    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Hello from Share Extension")
                .font(.title)

            Button("Done") {
                onDone()
            }
        }
        .padding()
    }
}
