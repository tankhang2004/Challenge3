import Foundation
import SwiftData

@Model
final class ReferenceItem {

    var title: String
    var creator: String
    var platform: String
    var url: String
    var imageFilename: String?
    var fullText: String?

    init(
        title: String,
        creator: String,
        platform: String,
        url: String,
        imageFilename: String? = nil,
        fullText: String? = nil
    ) {
        self.title = title
        self.creator = creator
        self.platform = platform
        self.url = url
        self.imageFilename = imageFilename
        self.fullText = fullText
    }
}
