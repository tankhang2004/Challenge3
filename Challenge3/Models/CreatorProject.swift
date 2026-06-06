// CreatorProject.swift
import Foundation
import SwiftData

@Model
final class CreatorProject {

    var title: String
    var outline: String
    var category: String = ""
    var createdAt: Date
    var thumbnailFilename: String?
    @Relationship(deleteRule: .cascade)
    var scripts: [ScriptItem] = []

    @Relationship(deleteRule: .cascade)
    var captions: [CaptionItem] = []

    @Relationship(deleteRule: .cascade)
    var videos: [VideoItem] = []

    @Relationship(deleteRule: .cascade)
    var images: [ImageItem] = []
    
    @Relationship(deleteRule: .cascade)
    var references: [ReferenceItem] = []
    
    @Relationship(deleteRule: .cascade)
    var music: MusicItem? = nil

    var postDate: Date?

    init(
        title: String,
        outline: String,
        createdAt: Date = .now,
        thumbnailFilename: String? = nil,
        
    ) {
        self.title = title
        self.outline = outline
        self.createdAt = createdAt
        self.thumbnailFilename = thumbnailFilename
    }
}
