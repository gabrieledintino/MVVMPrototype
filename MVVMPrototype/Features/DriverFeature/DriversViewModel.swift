//
//  DriversViewModel.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import Foundation

@Observable class DriversViewModel {
    var drivers: [Driver] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?
    
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
            drivers = try await NetworkClient.shared.fetchDrivers()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
