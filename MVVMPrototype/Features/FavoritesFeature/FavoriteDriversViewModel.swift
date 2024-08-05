//
//  FavoriteDriversViewModel.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 19/07/24.
//

import Foundation

@Observable class FavoriteDriversViewModel {
    var favoriteDrivers: [Driver] = []
    var isLoading = false
    var errorMessage: String?
    
    private let defaults: UserDefaults// = UserDefaults.standard
    private let favoritesKey = "FavoriteDrivers"
    
    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol = NetworkClient.shared, userDefaults: UserDefaults = UserDefaults.standard) {
        self.networkClient = networkClient
        defaults = userDefaults
    }
    
    func loadFavoriteDrivers() async {
        isLoading = true
        errorMessage = nil
        
        let favoriteIDs = getFavoritesIDs()
        
        do {
            let allDrivers = try await networkClient.fetchDrivers()
            favoriteDrivers = allDrivers.filter { favoriteIDs.contains($0.driverID) }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func removeFavorite(_ driver: Driver) {
        var favorites = getFavoritesIDs()
        favorites.removeAll { $0 == driver.driverID }
        defaults.set(favorites, forKey: favoritesKey)
        favoriteDrivers.removeAll { $0.driverID == driver.driverID }
    }
    
    fileprivate func getFavoritesIDs() -> [String] {
        return defaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    func removeFavorites(at offsets: IndexSet) {
        var favorites = getFavoritesIDs()
        
        for index in offsets.reversed() {
            let driver = favoriteDrivers[index]
            favorites.removeAll { $0 == driver.driverID }
        }
        
        defaults.set(favorites, forKey: favoritesKey)
        favoriteDrivers.remove(atOffsets: offsets)
    }
}
