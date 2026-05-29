import Foundation
import SwiftData

@Model
final class VideoItem {

    var filePath: String
    var thumbnailPath: String?
    var duration: Double

    init(
        filePath: String,
        thumbnailPath: String? = nil,
        duration: Double = 0
    ) {
        self.filePath = filePath
        self.thumbnailPath = thumbnailPath
        self.duration = duration
    }
}
