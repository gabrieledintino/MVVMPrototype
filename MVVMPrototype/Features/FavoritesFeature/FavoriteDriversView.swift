//
//  ConstructorsView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import SwiftUI

struct FavoriteDriversView: View {
    @State private var viewModel = FavoriteDriversViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else if viewModel.favoriteDrivers.isEmpty {
                    Text("No favorite drivers yet")
                        .foregroundColor(.secondary)
                } else {
                    favoriteDriversList
                }
            }
            .navigationTitle("Favorite Drivers")
        }
        .task {
            await viewModel.loadFavoriteDrivers()
        }
    }
    
    private var favoriteDriversList: some View {
        List {
            ForEach(viewModel.favoriteDrivers, id: \.driverID) { driver in
                NavigationLink(destination: DriverDetailView(driver: driver)) {
                    DriverRow(driver: driver)
                }
            }
            .onDelete(perform: viewModel.removeFavorites)
        }
    }
}

#Preview {
    FavoriteDriversView()
}
