//
//  ContentView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: OutputEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \OutputEntity.timestamp, ascending: false)
        ]
    )
    private var outputEntities: FetchedResults<OutputEntity>
    
    @State private var showingTrends: Bool = false
    @State private var showingAddView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    
                    Button(action: {}, label: {
                        NavigationLink(destination: TrendView()) {
                            Label("Trends", systemImage: "chart.xyaxis.line")
                        }
                    })
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background(Color.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(9)
                    
                    Button(action: {
                        showingAddView.toggle()
                    }, label: {
                        Label("New", systemImage: "plus.circle.fill")
                    })
                    .frame(maxWidth: .infinity, maxHeight: 55)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(9)
                    
                }.padding()
                
                List {
                    ForEach(groupBy(outputEntities, dateComponents: [.day, .month, .year])) { bucket in
                        NavigationLink {
                            GroupView(bucket: bucket)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(bucket.id.formatted(date: .abbreviated, time: .omitted))
                                Text("Total \(bucket.items.count)").foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pouch Log")
            .sheet(isPresented: $showingAddView) {
                AddItemView()
            }
            .navigationViewStyle(.stack)
        }
    }
    
    private func groupBy(_ items: FetchedResults<OutputEntity>, dateComponents: Set<Calendar.Component>) -> [Bucket<Date, OutputEntity>] {
        return DateUtility.groupBy(items, dateComponents: dateComponents)
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
