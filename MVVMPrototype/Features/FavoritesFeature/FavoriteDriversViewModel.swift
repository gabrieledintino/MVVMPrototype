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
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        defaults = userDefaults
    }
    
    func loadFavoriteDrivers() async {
        isLoading = true
        errorMessage = nil
        
        let favoriteIDs = defaults.stringArray(forKey: favoritesKey) ?? []
        
        do {
            let allDrivers = try await NetworkClient.shared.fetchDrivers()
            favoriteDrivers = allDrivers.filter { favoriteIDs.contains($0.driverID) }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func removeFavorite(_ driver: Driver) {
        var favorites = defaults.stringArray(forKey: favoritesKey) ?? []
        favorites.removeAll { $0 == driver.driverID }
        defaults.set(favorites, forKey: favoritesKey)
        favoriteDrivers.removeAll { $0.driverID == driver.driverID }
    }
    
    func removeFavorites(at offsets: IndexSet) {
        var favorites = defaults.stringArray(forKey: favoritesKey) ?? []
        
        for index in offsets.reversed() {
            let driver = favoriteDrivers[index]
            favorites.removeAll { $0 == driver.driverID }
        }
        
        defaults.set(favorites, forKey: favoritesKey)
        favoriteDrivers.remove(atOffsets: offsets)
    }
}
