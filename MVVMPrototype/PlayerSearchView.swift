//
//  PlayerSearchView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import SwiftUI

struct PlayerSearchView: View {
    @StateObject var viewModel: PlayerSearchViewModel
    @State private var selectedPlayer: PlayerSearchResponse?
    
    var body: some View {
        NavigationStack {
            VStack {
                List {  
                    TextField("Search players", text: $viewModel.searchTerm)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            Task {
                                await viewModel.searchPlayers()
                            }
                        }
                        /*.onChange(of: viewModel.searchTerm) {
                            Task {
                                await viewModel.searchPlayers()
                            }
                        }*/
                    
                    if viewModel.isSearching {
                        ProgressView()
                    } else {
                        ForEach(viewModel.searchResults, id: \.self) { player in
                            NavigationLink(value: player) {
                                VStack(alignment: .leading) {
                                    Text((player.firstName ?? "FIRST") + " " + (player.lastName ?? "LAST"))
                                    Text((player.team?.fullName ?? "TEAM"))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Player Search \(viewModel.searchResults.count)")
                .navigationDestination(for: PlayerInfo.self) { player in
                    PlayerStatsView(viewModel: PlayerStatsViewModel(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e")), playerId: player.id)
            }
            }
        }
    }
}
#Preview {
    PlayerSearchView(viewModel: PlayerSearchViewModel(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e")))
}
