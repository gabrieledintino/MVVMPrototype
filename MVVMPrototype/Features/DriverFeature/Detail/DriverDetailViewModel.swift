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
    private let defaults = UserDefaults.standard
    private let favoritesKey = "FavoriteDrivers"
    
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
    
    init(driver: Driver) {
        self.driver = driver
        self.isFavorite = getFavoriteStatus()
    }
    
    func fetchRaceResults() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await NetworkClient.shared.fetchRaceResults(forDriver: driver.driverID)
            races = response
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleFavorite() {
        var favorites = defaults.stringArray(forKey: favoritesKey) ?? []
        
        if favorites.contains(driver.driverID) {
            favorites.removeAll { $0 == driver.driverID }
        } else {
            favorites.append(driver.driverID)
        }
        
        defaults.set(favorites, forKey: favoritesKey)
        isFavorite.toggle()
    }
    
    private func getFavoriteStatus() -> Bool {
        let favorites = defaults.stringArray(forKey: favoritesKey) ?? []
        return favorites.contains(driver.driverID)
    }
}
