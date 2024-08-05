//
//  DriverDetailViewModel.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import Foundation

@Observable class DriverDetailViewModel {
    var races: [Race] = []
    var isLoading = false
    var errorMessage: String?
    var isFavorite: Bool = false
    
    private let driver: Driver
    private let defaults: UserDefaults
    private let favoritesKey = "FavoriteDrivers"
    
    private let networkClient: NetworkClientProtocol
    
    var formattedDateOfBirth: String? {
            // Create a date formatter to parse the date string
            let isoDateFormatter = DateFormatter()
            isoDateFormatter.dateFormat = "yyyy-MM-dd"

            // Parse the date string into a Date object
            guard let date = isoDateFormatter.date(from: driver.dateOfBirth) else {
                return nil
            }

            // Create a date formatter to format the Date object according to the user's locale
            let userLocaleFormatter = DateFormatter()
            userLocaleFormatter.dateStyle = .medium
            userLocaleFormatter.locale = Locale.current

            // Format the Date object into the user's locale format
            let formattedDate = userLocaleFormatter.string(from: date)
            return formattedDate
        }
    
    init(driver: Driver, networkClient: NetworkClientProtocol = NetworkClient.shared, userDefaults: UserDefaults = UserDefaults.standard) {
        self.networkClient = networkClient
        self.driver = driver
        self.defaults = userDefaults
        self.isFavorite = getFavoriteStatus()
    }
    
    func fetchRaceResults() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkClient.fetchRaceResults(forDriver: driver.driverID)
            races = response
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    fileprivate func getCurrentFavorites() -> [String] {
        return defaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    func toggleFavorite() {
        var favorites = getCurrentFavorites()
        
        if favorites.contains(driver.driverID) {
            favorites.removeAll { $0 == driver.driverID }
        } else {
            favorites.append(driver.driverID)
        }
        
        defaults.set(favorites, forKey: favoritesKey)
        isFavorite.toggle()
    }
    
    private func getFavoriteStatus() -> Bool {
        let favorites = getCurrentFavorites()
        return favorites.contains(driver.driverID)
    }
}
