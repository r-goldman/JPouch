//
//  OutputBucket.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import Foundation

class Bucket<T, K>: Identifiable, ObservableObject {
    let id: T
    @Published var items: [K]

    init(id: T) {
        self.id = id
        self.items = []
    }
}
