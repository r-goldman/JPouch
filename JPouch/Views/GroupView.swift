//
//  DayView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import SwiftUI
import Charts
import HealthKit

struct GroupView: View {
    @Binding var bucket: Bucket<Date, OutputEntity>
    @State var nutrition: [HKQuantitySample] = []
    
    init(bucket: Binding<Bucket<Date, OutputEntity>>) {
        self._bucket = bucket
        self.getNutritionDetails(forIdentifier: .dietaryFiber)
    }
    
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
                ForEach(bucket.items.indices, id: \.self) { i in
                    NavigationLink {
                        AddItemView(entity: $bucket.items[i]).navigationTitle("Edit Item")
                    } label: {
                        VStack(alignment: .leading) {
                            Text(bucket.items[i].timestamp.formatted(date: .omitted, time: .shortened))
                            
                        }
                    }
                }.onDelete(perform: deleteItem)
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        let vm = OutputStore.shared
        offsets.map { bucket.items[$0] }.forEach(vm.delete)
        vm.save()
    }
    
    private func getNutritionDetails(forIdentifier: HKQuantityTypeIdentifier) {
        let startOfDay = bucket.id
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: true
        )
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: startOfDay.addingTimeInterval(60 * 60 * 24),
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: HKQuantityType.quantityType(forIdentifier: forIdentifier)!,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]
        ) { (query, results, error) in
            guard let samples = results as? [HKQuantitySample] else {
                // Handle any errors here.
                print(error ?? "uknown err")
                return
            }
            
            nutrition.append(contentsOf: samples)
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            DispatchQueue.main.async {
                // Update the UI here.
                print(nutrition)
            }
        }
        
        HKHealthStore().execute(query)
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
        return .constant(bucket)
    }())
}
