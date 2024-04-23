//
//  DateUtility.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import Foundation

struct DateUtility {
    static func groupBy(_ items: any RandomAccessCollection<OutputEntity>, dateComponents: Set<Calendar.Component>) -> [Bucket<Date, OutputEntity>] {
        let empty: [Date: [OutputEntity]] = [:]
        let result = items.reduce(into: empty) { dict, item in
            if (item.timestamp != nil) {
                let components = Calendar.current.dateComponents(dateComponents, from: item.timestamp!)
                let date = Calendar.current.date(from: components)!
                let existing = dict[date] ?? []
                dict[date] = existing + [item]
            }
        }
        
        var bucketList: [Bucket<Date, OutputEntity>] = [];
        for (key, value) in result.sorted(by: {$0.key > $1.key}) {
            let bucket = Bucket<Date, OutputEntity>(id: key)
            bucket.items = value;
            bucketList.append(bucket)
        }
        
        return bucketList;
    }
}
