import Foundation
import SwiftData

@Model
final class ReferenceItem {

    var title: String
    var creator: String
    var platform: String
    var url: String

    init(
        title: String,
        creator: String,
        platform: String,
        url: String
    ) {
        self.title = title
        self.creator = creator
        self.platform = platform
        self.url = url
    }
}
