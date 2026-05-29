//
//  Challenge3App.swift
//  Challenge3
//
//  Created by Johnny Khang on 26/05/26.
//

import SwiftUI

@main
struct Challenge3App: App {
    var body: some Scene {
        WindowGroup {
//            HomePageView()
            TabView {
                HomePageView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }

                DetailProjectScreen()
                    .tabItem {
                        Label("Projects", systemImage: "folder")
                    }

            }
        }
    }
}
