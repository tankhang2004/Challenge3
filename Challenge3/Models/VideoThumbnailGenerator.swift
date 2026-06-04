import UIKit
import AVFoundation

enum VideoThumbnailGenerator {

    static func thumbnail(from url: URL) -> UIImage? {

        let asset = AVURLAsset(url: url)

        let generator = AVAssetImageGenerator(asset: asset)

        generator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 0, preferredTimescale: 60)

        guard let cgImage =
            try? generator.copyCGImage(
                at: time,
                actualTime: nil
            )
        else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
