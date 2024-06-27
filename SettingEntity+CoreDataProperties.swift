//
//  SettingEntity+CoreDataProperties.swift
//  JPouch
//
//  Created by Riley Goldman on 6/10/24.
//
//

import Foundation
import CoreData


extension SettingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingEntity> {
        return NSFetchRequest<SettingEntity>(entityName: "SettingEntity")
    }

    @NSManaged public var redThreshold: Int16
    @NSManaged public var orangeThreshold: Int16
    @NSManaged public var yellowThreshold: Int16
    @NSManaged public var nightStart: Date?
    @NSManaged public var nightEnd: Date?
    @NSManaged public var id: UUID?

}

extension SettingEntity : Identifiable {

}
