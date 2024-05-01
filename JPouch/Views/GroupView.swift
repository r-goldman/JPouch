//
//  DayView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import SwiftUI
import Charts

struct GroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var bucket: Bucket<Date, OutputEntity>
    var body: some View {
        VStack(alignment: .leading) {
            Chart(bucket.items) {
                PointMark(
                    x: .value("Time", $0.timestamp),
                    y: .value("Color", 1)
                )
                .foregroundStyle(Color(UIColor(rgb: $0.color)))
                .symbol(by: .value("Consistency", $0.consistency))
            }
            .frame(height: 75)
            .chartXScale(domain: [
                Date(primitivePlottable: bucket.id)!,
                Date(primitivePlottable: bucket.id)!.advanced(by: 60 * 60 * 24)
            ])
            .chartYAxis(.hidden)
            .chartYScale(domain: [0, 2])
            .padding()
            
            List {
                ForEach(bucket.items) { item in
                    NavigationLink {
                        AddItemView(entity: item).navigationTitle("Edit Item")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(item.timestamp.formatted(date: .omitted, time: .shortened))
                            
                        }
                    }
                }.onDelete(perform: deleteItem)
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        offsets.map { bucket.items[$0] }.forEach(viewContext.delete)
        do {
            bucket.objectWillChange.send()
            try viewContext.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

#Preview {
    GroupView(bucket: {
        let viewContext = PersistenceController.preview.container.viewContext
        let colors = [UIColor.brown.rgb, UIColor.black.rgb, UIColor.red.rgb]
        let consistencies = ["thick", "slimey", "watery"]
        let today = Calendar.current.startOfDay(for: Date())
        let bucket = Bucket<Date, OutputEntity>(id: today)
        for index in 1..<5 {
            let newItem = OutputEntity(context: viewContext)
            newItem.id = UUID()
            newItem.color = colors[Int(index / 2)];
            newItem.consistency = consistencies[index % 3]
            newItem.tags = "preview,tag #\(Int.random(in: 1...100))"
            newItem.timestamp = today.advanced(by: Double(index * -60 * 60 * 3))
            bucket.items.append(newItem)
        }
        return bucket
    }()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
