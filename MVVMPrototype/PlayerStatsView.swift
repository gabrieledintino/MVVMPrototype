//
//  PlayerStatView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import SwiftUI

struct PlayerStatsView: View {
    @StateObject var viewModel: PlayerStatsViewModel
    let playerId: Int
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let stats = viewModel.playerStats {
                Text("TBD")
                    .font(.title)
                Text("TBD")
                    .font(.subheadline)
                
                HStack {
                    StatView(title: "Points", value: stats.pts)
                    StatView(title: "Assists", value: stats.ast)
                    StatView(title: "Rebounds", value: stats.reb)
                }
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            }
        }
        .navigationTitle("Player Stats")
        .task {
            await viewModel.fetchPlayerStats(for: playerId)
        }
    }
}

struct StatView: View {
    let title: String
    let value: Double
    
    var body: some View {
        VStack {
            Text(title)
            Text(String(format: "%.1f", value))
                .font(.headline)
        }
    }
}

#Preview {
    PlayerStatsView(viewModel: PlayerStatsViewModel(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e")), playerId: 237)
}
