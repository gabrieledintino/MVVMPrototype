//
//  MVVMPrototypeApp.swift
//  MVVMPrototype
//
//  Created by Gabriele D'Intino on 15/07/24.
//

import SwiftUI

@main
struct MVVMPrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(nbaStatsService: NBAStatsService(apiKey: "2bc99545-99f4-4cb8-ae67-a34a50d9904e"))
        }
    }
}
