//
//  Persistence.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import CoreData
import UIKit

struct PersistenceController {
    static let instance = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let colors = [UIColor.brown.rgb, UIColor.black.rgb, UIColor.red.rgb]
        let consistencies = ["thick", "slimey", "watery"]
        
        for index in 0..<25 {
            let newItem = OutputEntity(context: viewContext)
            newItem.id = UUID()
            newItem.color = colors[index % 3];
            newItem.consistency = consistencies[index % 3]
            newItem.tags = "preview,tag #\(Int.random(in: 1...5))"
            newItem.timestamp = Date().advanced(by: Double(index * -60 * 60 * Int.random(in: 2...8)))
        }
        
        var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
        components.minute = 0
        
        let defaultSetting = SettingEntity(context: viewContext)
        defaultSetting.redThreshold = 15
        defaultSetting.orangeThreshold = 13
        defaultSetting.yellowThreshold = 8
        
        components.hour = 7
        defaultSetting.nightStart = Calendar.current.date(from: components)
        
        components.hour = 14
        defaultSetting.nightEnd = Calendar.current.date(from: components)
        
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "JPouch")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("ERROR loading core data \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
