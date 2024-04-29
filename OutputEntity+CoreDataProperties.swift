//
//  OutputEntity+CoreDataProperties.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//
//

import Foundation
import CoreData


extension OutputEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutputEntity> {
        return NSFetchRequest<OutputEntity>(entityName: "OutputEntity")
    }

    @NSManaged public var color: Int32
    @NSManaged public var consistency: String
    @NSManaged public var id: UUID?
    @NSManaged public var tags: String?
    @NSManaged public var timestamp: Date

}

extension OutputEntity : Identifiable, Timestamped {

}
