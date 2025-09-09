//
//  ForecaWeatherApp.swift
//  ForecaWeather
//
//  Created by İlker Memişoğlu on 9.09.2025.
//

import SwiftUI

@main
struct ForecaWeatherApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
