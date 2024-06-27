//
//  SettingStore.swift
//  JPouch
//
//  Created by Riley Goldman on 6/10/24.
//

import Foundation
import CoreData

class SettingStore: ObservableObject {
    static let shared = SettingStore()
    
    @Published var data: SettingEntity!
    
    private let container: NSPersistentContainer
    
    init() {
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        if isPreview == "1" {
            container = PersistenceController.preview.container
        }
        else {
            container = PersistenceController.instance.container
        }
        data = fetchData()
    }
    
    func set(
        redThreshold: Int16,
        orangeThreshold: Int16,
        yellowThreshold: Int16,
        nightStart: Date,
        nightEnd: Date
    ) {
        self.data.redThreshold = redThreshold
        self.data.orangeThreshold = orangeThreshold
        self.data.yellowThreshold = yellowThreshold
        
        self.data.nightStart = nightStart
        self.data.nightEnd = nightEnd
       
        save()
    }
    
    func clear() {
        let request = NSFetchRequest<any NSFetchRequestResult>(entityName: "SettingEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
        } catch let error as NSError {
            print("ERROR resetting settings \(error)")
        }
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        }
        catch {
            print("ERROR saving data \(data!)")
        }
        self.data = fetchData() /// automatically refresh data after changing it
    }
    
    private func fetchData() -> SettingEntity {
        let request = NSFetchRequest<SettingEntity>(entityName: "SettingEntity")
        
        do {
            let rawData = try container.viewContext.fetch(request)
            print("Found \(rawData.count) settings...")
            return rawData.first ?? defaultSetting
        } catch {
            let nsError = error as NSError
            print("Unable to fetch data \(nsError), \(nsError.userInfo)")
            return defaultSetting
        }
    }
    
    private var defaultSetting: SettingEntity  {
        let settings = SettingEntity(context: self.container.viewContext)
        settings.redThreshold = 16
        settings.orangeThreshold = 12
        settings.yellowThreshold = 8
        
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        dateComponents.hour = 7
        dateComponents.minute = 30
        settings.nightEnd = Calendar.current.date(from: dateComponents)
        
        dateComponents.hour = 23
        dateComponents.minute = 00
        settings.nightStart = Calendar.current.date(from: dateComponents)
        
        return settings
    }
}
