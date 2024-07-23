//
//  DriversListView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import SwiftUI

struct DriversListView: View {
    @State private var viewModel = DriversViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                } else {
                    driversList
                }
            }
            .navigationTitle("F1 Drivers")
        }
        .searchable(text: $viewModel.searchText, prompt: "Search drivers")
        .task {
            await viewModel.fetchDrivers()
        }
    }
    
    private var driversList: some View {
        List(viewModel.filteredDrivers, id: \.driverID) { driver in
            NavigationLink(destination: DriverDetailView(driver: driver)) {
                DriverRow(driver: driver)
            }
        }
    }
}

struct DriverRow: View {
    let driver: Driver
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(driver.fullName)
                .font(.headline)
            Text(driver.nationality)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Error")
                .font(.title)
                .padding()
            Text(message)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}


#Preview {
    DriversListView()
}
