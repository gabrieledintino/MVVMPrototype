//
//  PlayerSearchViewModel.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

@MainActor
class PlayerSearchViewModel: ObservableObject {
    @Published var searchTerm = ""
    @Published var searchResults: [PlayerInfo] = []
    @Published var isSearching = false
    @Published var error: Error?
    
    private let nbaStatsService: NBAStatsService
    
    init(nbaStatsService: NBAStatsService) {
        self.nbaStatsService = nbaStatsService
    }
    
    func searchPlayers() async {
        guard !searchTerm.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        error = nil
        
        do {
            searchResults = try await nbaStatsService.searchPlayers(term: searchTerm)
        } catch {
            self.error = error
        }
        
        isSearching = false
    }
}
