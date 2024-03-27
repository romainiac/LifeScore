//
//  MainView.swift
//  LifeScore
//
//  Created by Roman Yefimets on 3/20/24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            ScoreView()
                .tabItem {
                    Label("", systemImage: "s.square")
                }
            ContentView()
                .tabItem {
                    Label("", systemImage: "list.dash")
                }

        }
    }
}

#Preview {
    MainView()
        .modelContainer(for: LifeEvent.self, inMemory: true)

}
