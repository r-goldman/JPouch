//
//  OutputBucket.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import Foundation

class Bucket<T, K>: Identifiable {
    let id: T
    var items: [K]
    
    init(id: T) {
        self.id = id
        self.items = []
    }
}
