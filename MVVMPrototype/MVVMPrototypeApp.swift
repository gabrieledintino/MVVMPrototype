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
            ContentView()
                .onAppear { appearSetup() }
        }
    }
    
    func appearSetup() {
#if DEBUG
#if os(iOS)
        UIView.setAnimationsEnabled(false)
#endif
        if CommandLine.arguments.contains("--reset-userdefaults") {
            let defaults = UserDefaults.standard
            if let appDomain = Bundle.main.bundleIdentifier {
                defaults.removePersistentDomain(forName: appDomain)
            }
            defaults.synchronize()
        }
#endif
    }
}
