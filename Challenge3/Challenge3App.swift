//
//  Challenge3App.swift
//  Challenge3
//
//  Created by Johnny Khang on 26/05/26.
//

import SwiftUI
import SwiftData

@main
struct Challenge3App: App {
    @AppStorage("hasSeenStartup") private var hasSeenStartup = false
    let sharedContainer: ModelContainer

    init() {
        let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.Lumio"
        )

        let storeURL: URL
        if let groupURL {
            storeURL = groupURL.appendingPathComponent("LumioData.sqlite")
        } else {
            let appSupportURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first ?? FileManager.default.temporaryDirectory

            storeURL = appSupportURL.appendingPathComponent("LumioData.sqlite")
            print("⚠️ App Group unavailable, using local store at:\n\(storeURL.path)")
        }

        let config = ModelConfiguration(url: storeURL)

        // Temporary debug — delete after diagnosis
        let storeExists = FileManager.default.fileExists(atPath: storeURL.path)
        print("🗄️ Store exists: \(storeExists)")
        
        do {
            sharedContainer = try ModelContainer(
                for: CreatorProject.self,
                     ReferenceItem.self,
                     ScriptItem.self,
                     CaptionItem.self,
                     VideoItem.self,
                    ImageItem.self,
                    MusicItem.self,
                migrationPlan: LumioMigrationPlan.self,
                configurations: config
            )
        } catch let error as NSError{
            // Now you can see the REAL underlying error
            print("❌ Domain: \(error.domain)")
            print("❌ Code: \(error.code)")
            print("❌ Description: \(error.localizedDescription)")
            print("❌ UserInfo: \(error.userInfo)")
//            fatalError("Failed to create ModelContainer: \(error)")
            fatalError("Failed to create ModelContainer: \(error)")
        }
        let debugSchema = Schema(
            LumioSchemaV1.models,
            version: Schema.Version(1, 0, 0)
        )
        for entity in debugSchema.entities {
            print("🔑 \(entity.name ?? "?"): \(entity.uniquenessConstraints)")
        }
    }

    var body: some Scene {
        WindowGroup {
//            HomePageScreen()
            if hasSeenStartup {
                HomePageScreen()
            } else {
                StartupView()
            }
        }
        .modelContainer(sharedContainer)
    }
}
