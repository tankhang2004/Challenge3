//
//  Challenge3App.swift
//  Challenge3

import SwiftUI
import SwiftData

@main
struct Challenge3App: App {
    @AppStorage("hasSeenStartup") private var hasSeenStartup = false
    let sharedContainer: ModelContainer

    init() {
        sharedContainer = Self.makeContainer()
    }

    // MARK: - Container Setup

    private static func makeContainer() -> ModelContainer {
        let storeURL = resolveStoreURL()

        // Try with migration plan first
        if let container = tryMakeContainer(storeURL: storeURL, withMigration: true) {
            return container
        }

        // Migration failed — delete old store and recreate fresh (data is lost but app can launch)
        print("⚠️ Migration failed — resetting store to recover.")
        deleteStore(at: storeURL)

        if let container = tryMakeContainer(storeURL: storeURL, withMigration: false) {
            return container
        }

        // Last resort: in-memory store
        print("⚠️ Persistent store unavailable — falling back to in-memory.")
        let memConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(
            for: CreatorProject.self, ReferenceItem.self, ScriptItem.self,
                 CaptionItem.self, VideoItem.self, ImageItem.self, MusicItem.self,
            configurations: memConfig
        )
    }

    private static func resolveStoreURL() -> URL {
        if let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.Lumio"
        ) {
            return groupURL.appendingPathComponent("LumioData.sqlite")
        }

        // App Group unavailable — fall back to Application Support
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        return appSupport.appendingPathComponent("LumioData.sqlite")
    }

    private static func tryMakeContainer(storeURL: URL, withMigration: Bool) -> ModelContainer? {
        let config = ModelConfiguration(url: storeURL)
        do {
            if withMigration {
                return try ModelContainer(
                    for: CreatorProject.self, ReferenceItem.self, ScriptItem.self,
                         CaptionItem.self, VideoItem.self, ImageItem.self, MusicItem.self,
                    migrationPlan: LumioMigrationPlan.self,
                    configurations: config
                )
            } else {
                return try ModelContainer(
                    for: CreatorProject.self, ReferenceItem.self, ScriptItem.self,
                         CaptionItem.self, VideoItem.self, ImageItem.self, MusicItem.self,
                    configurations: config
                )
            }
        } catch {
            print("❌ ModelContainer error: \(error)")
            return nil
        }
    }

    private static func deleteStore(at url: URL) {
        let fm = FileManager.default
        let base = url.deletingPathExtension()
        for ext in ["sqlite", "sqlite-shm", "sqlite-wal"] {
            try? fm.removeItem(at: base.appendingPathExtension(ext))
        }
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            if hasSeenStartup {
                HomePageScreen()
            } else {
                StartupView()
            }
        }
        .modelContainer(sharedContainer)
    }
}
