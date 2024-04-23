//
//  SwiftUIView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import SwiftUI
import Charts

struct TrendView: View {
    @FetchRequest(
        entity: OutputEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \OutputEntity.timestamp, ascending: false)
        ]
    )
    private var outputEntities: FetchedResults<OutputEntity>
    
    var body: some View {
        VStack {
            Text("Hello")
        }
    }
    
    private func groupBy(_ items: FetchedResults<OutputEntity>, dateComponents: Set<Calendar.Component>) -> [Bucket<Date, OutputEntity>] {
        return DateUtility.groupBy(items, dateComponents: dateComponents)
    }
}

#Preview {
    TrendView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
