//
//  DriversListView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import SwiftUI

struct DriversListView: View {
    @State var viewModel = DriversListViewModel()
    internal let inspection = Inspection<Self>()
    
    init(viewModel: DriversListViewModel = DriversListViewModel()) {
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
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    }
    
    private var driversList: some View {
        List(viewModel.filteredDrivers, id: \.driverID) { driver in
            NavigationLink(destination: DriverDetailView(driver: driver)) {
                DriverRow(driver: driver)
                    .accessibilityIdentifier("DriverCell_\(driver.driverID)")
            }
        }
        .accessibilityIdentifier("list_view")
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
