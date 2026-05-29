import SwiftUI

struct ShareRootView: View {

    let onDone: () -> Void

    var body: some View {

        VStack(spacing: 20) {

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("Saved to Lumio")
                .font(.title2)

            Button("Done") {
                onDone()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

//import SwiftUI
//
//struct ShareRootView: View {
//
//    let onDone: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            Text("Hello from Share Extension")
//                .font(.title)
//
//            Button("Done") {
//                onDone()
//            }
//        }
//        .padding()
//    }
//}
