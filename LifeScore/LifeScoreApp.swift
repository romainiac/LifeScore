//
//  LifeScoreApp.swift
//  LifeScore
//
//  Created by Roman Yefimets on 3/20/24.
//

import SwiftUI
import SwiftData

@main
struct LifeScoreApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LifeEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
