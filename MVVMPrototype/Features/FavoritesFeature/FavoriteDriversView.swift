//
//  ConstructorsView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import SwiftUI

struct FavoriteDriversView: View {
    @State internal var viewModel = FavoriteDriversViewModel()
    internal let inspection = Inspection<Self>()
    
    init(viewModel: FavoriteDriversViewModel = FavoriteDriversViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .accessibilityIdentifier("progress_view")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                        .accessibilityIdentifier("error_view")
                } else if viewModel.favoriteDrivers.isEmpty {
                    Text("No favorite drivers yet")
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("text_view")
                } else {
                    favoriteDriversList
                }
            }
            .navigationTitle("Favorite Drivers")
        }
        .task {
            await viewModel.loadFavoriteDrivers()
        }
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var favoriteDriversList: some View {
        List {
            ForEach(viewModel.favoriteDrivers, id: \.driverID) { driver in
                NavigationLink(destination: DriverDetailView(driver: driver)) {
                    DriverRow(driver: driver)
                }
            }
            .onDelete(perform: viewModel.removeFavorites)
            .accessibilityIdentifier("list_view")
        }
    }
}

#Preview {
    FavoriteDriversView()
}
