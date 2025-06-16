//
//  ContentView.swift
//  TestProject3(App)
//
//  Created by Evelyn Wijaya on 07/06/25.
//

import SwiftUI

class GameData: ObservableObject {
    @Published var highestLevel: Int = UserDefaults.standard.savedHighestLevel
}

struct ContentView: View {
    @StateObject private var gameData = GameData()
    
    var body: some View {
        HomeView()
            .environmentObject(gameData)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameData())
}
