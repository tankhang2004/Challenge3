// LumioMigrationPlan.swift

import SwiftData
import Foundation

// MARK: - Migration Plan

enum LumioMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [
            LumioSchemaV1.self,
            LumioSchemaV2.self,
            LumioSchemaV3.self,
        ]
    }

    static var stages: [MigrationStage] {
        [
            StageV1toV2,
            StageV2toV3,
        ]
    }

    static let StageV1toV2 = MigrationStage.lightweight(
        fromVersion: LumioSchemaV1.self,
        toVersion:   LumioSchemaV2.self
    )

    static let StageV2toV3 = MigrationStage.lightweight(
        fromVersion: LumioSchemaV2.self,
        toVersion:   LumioSchemaV3.self
    )
}

// MARK: - V1 (frozen baseline)

enum LumioSchemaV1: VersionedSchema {

    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            CreatorProject.self,
            ReferenceItem.self,
            ScriptItem.self,
            CaptionItem.self,
            VideoItem.self,
            ImageItem.self,
            MusicItem.self,
        ]
    }

    @Model final class CreatorProject {
        var title: String = ""
        var outline: String = ""
        var category: String = ""
        var createdAt: Date = Date()
        var thumbnailFilename: String?
        var postDate: Date?
        var isPinned: Bool = false
        var isFavorite: Bool = false
        var isArchived: Bool = false
        @Relationship(deleteRule: .cascade) var scripts: [ScriptItem] = []
        @Relationship(deleteRule: .cascade) var captions: [CaptionItem] = []
        @Relationship(deleteRule: .cascade) var videos: [VideoItem] = []
        @Relationship(deleteRule: .cascade) var images: [ImageItem] = []
        @Relationship(deleteRule: .cascade) var references: [ReferenceItem] = []
        @Relationship(deleteRule: .cascade) var music: MusicItem? = nil
        init() {}
    }

    @Model final class ReferenceItem {
        var title: String = ""
        var creator: String = ""
        var platform: String = ""
        var url: String = ""
        var imageFilename: String?
        var fullText: String?
        init() {}
    }

    @Model final class ScriptItem {
        var content: String = ""
        var createdAt: Date = Date()
        init() {}
    }

    @Model final class CaptionItem {
        var content: String = ""
        var platform: String = ""
        init() {}
    }

    @Model final class VideoItem {
        var filePath: String = ""
        var thumbnailPath: String?
        var duration: Double = 0
        init() {}
    }

    @Model final class ImageItem {
        var filename: String = ""
        var createdAt: Date = Date()
        init() {}
    }

    @Model final class MusicItem {
        var songID: String = ""
        var title: String = ""
        var artistName: String = ""
        var albumTitle: String?
        var artworkURL: String?
        init() {}
    }
}

// MARK: - V2 (frozen — adds viewCount, no updatedAt)

enum LumioSchemaV2: VersionedSchema {

    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            CreatorProject.self,
            ReferenceItem.self,
            ScriptItem.self,
            CaptionItem.self,
            VideoItem.self,
            ImageItem.self,
            MusicItem.self,
        ]
    }

    @Model final class CreatorProject {
        var title: String = ""
        var outline: String = ""
        var category: String = ""
        var createdAt: Date = Date()
        var thumbnailFilename: String?
        var postDate: Date?
        var isPinned: Bool = false
        var isFavorite: Bool = false
        var isArchived: Bool = false
        var viewCount: Int = 0
        // no updatedAt — this is the V2 snapshot
        @Relationship(deleteRule: .cascade) var scripts: [ScriptItem] = []
        @Relationship(deleteRule: .cascade) var captions: [CaptionItem] = []
        @Relationship(deleteRule: .cascade) var videos: [VideoItem] = []
        @Relationship(deleteRule: .cascade) var images: [ImageItem] = []
        @Relationship(deleteRule: .cascade) var references: [ReferenceItem] = []
        @Relationship(deleteRule: .cascade) var music: MusicItem? = nil
        init() {}
    }

    @Model final class ReferenceItem {
        var title: String = ""
        var creator: String = ""
        var platform: String = ""
        var url: String = ""
        var imageFilename: String?
        var fullText: String?
        init() {}
    }

    @Model final class ScriptItem {
        var content: String = ""
        var createdAt: Date = Date()
        init() {}
    }

    @Model final class CaptionItem {
        var content: String = ""
        var platform: String = ""
        init() {}
    }

    @Model final class VideoItem {
        var filePath: String = ""
        var thumbnailPath: String?
        var duration: Double = 0
        init() {}
    }

    @Model final class ImageItem {
        var filename: String = ""
        var createdAt: Date = Date()
        init() {}
    }

    @Model final class MusicItem {
        var songID: String = ""
        var title: String = ""
        var artistName: String = ""
        var albumTitle: String?
        var artworkURL: String?
        init() {}
    }
}

// MARK: - V3 (current — adds updatedAt to CreatorProject)

enum LumioSchemaV3: VersionedSchema {

    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            CreatorProject.self,
            ReferenceItem.self,
            ScriptItem.self,
            CaptionItem.self,
            VideoItem.self,
            ImageItem.self,
            MusicItem.self,
        ]
    }
}
