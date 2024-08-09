//
//  DriverDetailView.swift
//  MVVMPrototype
//
//  Created by Gabriele D'intino (EXT) on 16/07/24.
//

import SwiftUI

struct DriverDetailView: View {
    let driver: Driver
    @State private var viewModel: DriverDetailViewModel
    
    init(driver: Driver) {
        self.driver = driver
        _viewModel = State(initialValue: DriverDetailViewModel(driver: driver))
    }
    
    var body: some View {
        List {
            Section(header: Text("Driver Information")) {
                InfoRow(title: "Full Name", value: driver.fullName)
                InfoRow(title: "Nationality", value: driver.nationality)
                InfoRow(title: "Date of Birth", value: driver.dateOfBirth)
                InfoRow(title: "Driver Number", value: driver.permanentNumber)
            }
            
            Section(header: Text("Race Results for current season")) {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage)
                        .accessibilityIdentifier("error_view")
                } else if viewModel.races.isEmpty {
                    Text("No race results available.")
                } else {
                    ForEach(viewModel.races, id: \.round) { race in
                        RaceResultRow(race: race, driverID: driver.driverID)
                    }
                }
            }
        }
        .navigationTitle(driver.fullName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                        .accessibilityIdentifier(viewModel.isFavorite ? "star.fill" : "star")
                }
            }
        }
        .task {
            await viewModel.fetchRaceResults()
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
    }
}

struct RaceResultRow: View {
    let race: Race
    let driverID: String
    
    var body: some View {
        if let result = race.results.first(where: { $0.driver.driverID == driverID }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(race.raceName)
                        .font(.headline)
                    Text(formattedDate(race.date, race.time))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 12) {
                        positionView(result.position)
                        Text("\(result.points) pts")
                            .fontWeight(.semibold)
                    }
                    Text("Started: P\(result.grid)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func formattedDate(_ date: String, _ time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        // Combine the date and time strings
        let combinedString = "\(date)T\(time)"

        // Create a date formatter to parse the combined date and time string
        let isoDateFormatter = ISO8601DateFormatter()

        // Parse the combined string into a Date object
        guard let dateTime = isoDateFormatter.date(from: combinedString) else {
            return "\(date) \(time)"
        }
        return dateFormatter.string(from: dateTime)
    }
    
    private func positionView(_ position: String) -> some View {
            Text(position)
                .font(.system(size: 18, weight: .bold))
                .frame(minWidth: 25)
                .padding(6)
                .background(backgroundColor(for: position))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        
    private func backgroundColor(for position: String) -> Color {
        switch position {
            case "1": return .yellow
            case "2": return .gray
            case "3": return .orange
            default: return .blue
        }
    }

}


//#Preview {
//    DriverDetailView(driver: Driver)
//}
