//
//  dindinApp.swift
//  dindin
//
//  Created by Ricardo Garcia on 28/04/25.
//

import SwiftUI

@main
struct dindinApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
