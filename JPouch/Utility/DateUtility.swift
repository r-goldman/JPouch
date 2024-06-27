//
//  DateUtility.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import Foundation

struct DateUtility {
    static func groupBy<T: Timestamped>(_ items: some RandomAccessCollection<T>, dateComponents: Set<Calendar.Component>) -> [Bucket<Date, T>] {
        let empty: [Date: [T]] = [:]
        let result = items.reduce(into: empty) { dict, item in
            let components = Calendar.current.dateComponents(dateComponents, from: item.timestamp)
            let date = Calendar.current.date(from: components)!
            let existing = dict[date] ?? []
            dict[date] = [item] + existing
        }
        
        var bucketList: [Bucket<Date, T>] = [];
        for (key, value) in result.sorted(by: {$0.key > $1.key}) {
            let bucket = Bucket<Date, T>(id: key)
            bucket.items = value;
            bucketList.append(bucket)
        }
        
        return bucketList;
    }
}
