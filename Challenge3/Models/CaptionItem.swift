import Foundation
import SwiftData

@Model
final class CaptionItem {

    var content: String
    var platform: String

    init(
        content: String,
        platform: String
    ) {
        self.content = content
        self.platform = platform
    }
}
