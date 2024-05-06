//
//  OutputEntityViewModel.swift
//  JPouch
//
//  Created by Riley Goldman on 5/3/24.
//

import Foundation
import CoreData
import SwiftUI

class OutputStore: ObservableObject {
    static let shared = OutputStore()
    
    @Published var modified: [DateComponents]? = nil
    @Published var data: [Bucket<Date, OutputEntity>] = []
    
    private let groupBy: Set<Calendar.Component> = [.day, .month, .year]
    private let container: NSPersistentContainer
    
    init() {
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        if isPreview == "1" {
            container = PersistenceController.preview.container
        }
        else {
            container = PersistenceController.instance.container
        }
        self.data = fetchData(groupBy: self.groupBy)
    }
    
    func upsert(entity: OutputEntity? = nil, color: Color, consistency: String, timestamp: Date, tags: Set<String>?) {
        var originalDate: DateComponents? = nil
        var entityObj: OutputEntity
        if (entity == nil) {
            entityObj = OutputEntity(context: self.container.viewContext)
            entityObj.id = UUID()
        }
        else {
            entityObj = entity!
            originalDate = Calendar.current.dateComponents([.day, .month, .year], from: entityObj.timestamp)
        }
        entityObj.color = UIColor(color).rgb
        entityObj.consistency = consistency
        entityObj.tags = tags?.sorted(by:<).joined(separator: ",").lowercased()
        entityObj.timestamp = timestamp
        save()
        
        let newDate = Calendar.current.dateComponents([.day, .month, .year], from: timestamp)
        if originalDate != newDate {
            if originalDate != nil {
                modified = [originalDate!, newDate]
            }
            else {
                modified = [newDate]
            }
        }
    }
    
    func delete(entity: OutputEntity) {
        let originalDate = Calendar.current.dateComponents([.day, .month, .year], from: entity.timestamp)
        container.viewContext.delete(entity)
        modified = [originalDate]
    }
    
    func save() {
        do {
            try container.viewContext.save()
        }
        catch {
            print("ERROR saving data \(data)")
        }
        self.data = fetchData(groupBy: self.groupBy) /// automatically refresh data after changing it
    }
    
    func fetchData(groupBy: Set<Calendar.Component>) -> [Bucket<Date, OutputEntity>] {
        let request = NSFetchRequest<OutputEntity>(entityName: "OutputEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \OutputEntity.timestamp, ascending: false)]
        
        do {
            let rawData = try container.viewContext.fetch(request)
            return DateUtility.groupBy(rawData, dateComponents: groupBy)
        } catch {
            let nsError = error as NSError
            print("Unable to fetch data \(nsError), \(nsError.userInfo)")
            return []
        }
    }
}
