//
//  PlayerStatsViewModel.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

@MainActor
class PlayerStatsViewModel: ObservableObject {
    @Published var playerStats: PlayerStats?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let nbaStatsService: NBAStatsService
    
    init(nbaStatsService: NBAStatsService) {
        self.nbaStatsService = nbaStatsService
    }
    
    func fetchPlayerStats(for playerId: Int) async {
        isLoading = true
        error = nil
        
        do {
            playerStats = try await nbaStatsService.fetchPlayerStats(playerId: playerId)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
