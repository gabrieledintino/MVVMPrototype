//
//  APIManager.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import Foundation

import Foundation

enum APIError: Error, Equatable {
    case decodingError
    case networkError
}

actor NetworkClient: NetworkClientProtocol {
    static let shared = NetworkClient()
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    private let baseURL = "https://ergast.com/api/f1"
    
    func fetchDrivers() async throws -> [Driver] {
        let urlString = "\(baseURL)/2024/drivers.json"
        let response: DriversListYearResponse = try await performRequest(with: urlString)
        return response.mrData.driverTable.drivers
    }
    
    func fetchRaceResults(forDriver driverId: String) async throws -> [Race] {
        let urlString = "\(baseURL)/2024/drivers/\(driverId)/results.json"
        let response: RaceResultResponse = try await performRequest(with: urlString)
        return response.mrData.raceTable.races
    }
    
    private func performRequest<T: Decodable>(with urlString: String) async throws -> T {
        let url = URL(string: urlString)!
        
        do {
            let (data, _) = try await urlSession.data(from: url)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            //print(decodedData)
            return decodedData
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .valueNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .keyNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .dataCorrupted(let key):
                print("error \(key), and ERROR: \(error.localizedDescription)")
            default:
                print("ERROR: \(error.localizedDescription)")
            }
            throw APIError.decodingError
        } catch {
            print(error.localizedDescription)
            throw APIError.networkError
        }
    }
}
