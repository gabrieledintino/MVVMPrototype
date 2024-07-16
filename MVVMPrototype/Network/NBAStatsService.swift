//
//  NBAStatsService.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import Foundation

import Foundation

public class NBAStatsService {
    private let baseURL = "https://api.balldontlie.io/v1"
    private let urlSession: URLSession
    private let apiKey: String
    
    init(apiKey: String, urlSession: URLSession = .shared) {
        self.apiKey = apiKey
        self.urlSession = urlSession
    }
    
    private func createRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("2bc99545-99f4-4cb8-ae67-a34a50d9904e", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func searchPlayers(term: String) async throws -> [PlayerInfo] {
        let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/players?search=\(encodedTerm)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, _) = try await urlSession.data(for: request)
        print(data)
        print("XXX")
        do {
            let response = try JSONDecoder().decode(PlayerSearchResponse.self, from: data)
            print(response)
            print("YYY")
            print(response)
            return response.data
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    func fetchPlayerStats(playerId: Int) async throws -> PlayerStats {
        let urlString = "\(baseURL)/players/\(playerId)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, _) = try await urlSession.data(for: request)
        let response = try JSONDecoder().decode(PlayerStatsResponse.self, from: data)
        
        guard let stats = response.data.first else {
            throw NSError(domain: "NBAStatsService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No stats available for this player"])
        }
        
        return stats
        /*let player = try await fetchPlayerDetails(playerId: playerId)
        
        return PlayerStats(
            player: player,
            points: stats.pts,
            assists: stats.ast,
            rebounds: stats.reb
        )*/
    }
    
    private func fetchPlayerDetails(playerId: Int) async throws -> PlayerInfo {
        let urlString = "\(baseURL)/players/\(playerId)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let request = createRequest(url: url)
        let (data, _) = try await urlSession.data(for: request)
        let player = try JSONDecoder().decode(PlayerInfo.self, from: data)
        
        return player
    }
}
