//
//  PlayerSearchView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import SwiftUI

struct PlayerSearchView: View {
    @StateObject var viewModel: PlayerSearchViewModel
    @State private var selectedPlayer: Player?
    
    var body: some View {
        NavigationStack {
            List {
                TextField("Search players", text: $viewModel.searchTerm)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: viewModel.searchTerm) { _ in
                        Task {
                            await viewModel.searchPlayers()
                        }
                    }
                
                if viewModel.isSearching {
                    ProgressView()
                } else {
                    ForEach(viewModel.searchResults) { player in
                        NavigationLink(value: player) {
                            VStack(alignment: .leading) {
                                Text(player.name)
                                Text(player.team)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Player Search")
            .navigationDestination(for: Player.self) { player in
                PlayerStatsView(viewModel: PlayerStatsViewModel(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e")), playerId: player.id)
            }
        }
    }
}
#Preview {
    PlayerSearchView(viewModel: PlayerSearchViewModel(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e")))
}
