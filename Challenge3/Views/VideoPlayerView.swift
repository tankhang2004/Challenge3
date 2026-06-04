// MARK: - Video Player View
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            AVPlayerControllerRepresented(url: url)
                .ignoresSafeArea()

//            Button {
//                dismiss()
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 28))
//                    .foregroundStyle(.white)
//                    .shadow(color: .black.opacity(0.4), radius: 4)
//                    .padding(16)
//            }
        }
    }
}

private struct AVPlayerControllerRepresented: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.player?.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
