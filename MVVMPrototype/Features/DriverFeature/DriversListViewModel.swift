//
//  DriversViewModel.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import Foundation

@Observable class DriversListViewModel {
    var drivers: [Driver] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?
    
    private let networkClient: NetworkClientProtocol
        
    init(networkClient: NetworkClientProtocol = NetworkClient.shared) {
        self.networkClient = networkClient
    }
    
    var filteredDrivers: [Driver] {
        if searchText.isEmpty {
            return drivers
        } else {
            return drivers.filter { $0.fullName.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func fetchDrivers() async {
        isLoading = true
        errorMessage = nil
        
        do {
            drivers = try await networkClient.fetchDrivers()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
