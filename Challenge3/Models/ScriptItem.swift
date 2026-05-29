import Foundation
import SwiftData

@Model
final class ScriptItem {

    var content: String
    var createdAt: Date

    init(
        content: String,
        createdAt: Date = .now
    ) {
        self.content = content
        self.createdAt = createdAt
    }
}
