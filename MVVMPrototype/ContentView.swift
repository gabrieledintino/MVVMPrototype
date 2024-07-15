//
//  ContentView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import SwiftUI

struct ContentView: View {
    let nbaStatsService: NBAStatsService
        
        var body: some View {
            TabView {
                PlayerSearchView(viewModel: PlayerSearchViewModel(nbaStatsService: nbaStatsService))
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                
                Text("Stats Overview")
                    .tabItem {
                        Label("Stats", systemImage: "chart.bar")
                    }
            }
        }
}

#Preview {
    ContentView(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e"))
}
