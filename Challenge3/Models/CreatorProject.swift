import Foundation
import SwiftData

@Model
final class CreatorProject {

    var title: String
    var topic: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var scripts: [ScriptItem] = []

    @Relationship(deleteRule: .cascade)
    var captions: [CaptionItem] = []

    @Relationship(deleteRule: .cascade)
    var videos: [VideoItem] = []

    @Relationship(deleteRule: .cascade)
    var references: [ReferenceItem] = []

    var postDate: Date?

    init(
        title: String,
        topic: String,
        createdAt: Date = .now
    ) {
        self.title = title
        self.topic = topic
        self.createdAt = createdAt
    }
}
