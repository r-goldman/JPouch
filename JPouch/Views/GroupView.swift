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
    @State var meals: [Meal] = []
    @State var showingDataList: Bool = true
    @State var showingMealList: Bool = false
    
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
                Section("Data", isExpanded: $showingDataList) {
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
                Section("Meals", isExpanded: $showingMealList) {
                    ForEach(meals, id: \.id) { meal in
                        MealView(meal: meal)
                    }
                }
            }
            .listStyle(.sidebar)
        }.onAppear(perform: loadDietaryData)
    }
    
    private func deleteItem(at offsets: IndexSet) {
        let vm = OutputStore.shared
        offsets.map { bucket.items[$0] }.forEach(vm.delete)
        vm.save()
    }
    
    private func loadDietaryData() {
        HealthKitManager.shared.requestAuthorization { success, error in
            if success {
                let startDate = bucket.id
                let endDate = bucket.id.advanced(by: 60
                    * 60 * 24)
                HealthKitManager.shared.fetchDietaryData(start: startDate, end: endDate) { samples, error in
                    if let samples = samples {
                        DispatchQueue.main.async {
                            self.meals = Meal.fromSamples(samples)
                        }
                    }
                }
            } else {
                // Handle errors appropriately in your app
                print("HealthKit authorization failed: \(String(describing: error?.localizedDescription))")
            }
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
        return .constant(bucket)
    }())
}
