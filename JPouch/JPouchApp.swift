//
//  JPouchApp.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI

@main
struct JPouchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
