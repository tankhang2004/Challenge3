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

    let sharedContainer: ModelContainer

    init() {
        let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.richard.challenge3"
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

        sharedContainer = try! ModelContainer(
            for: CreatorProject.self,
                 ReferenceItem.self,
                 ScriptItem.self,
                 CaptionItem.self,
                 VideoItem.self,
            configurations: config
        )
    }

    var body: some Scene {
        WindowGroup {
//            HomePageScreen()
            StartupView()
        }
        .modelContainer(sharedContainer)
    }
}
