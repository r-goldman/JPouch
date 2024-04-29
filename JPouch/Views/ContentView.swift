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
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        headerBtn(
                            Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                .resizable().scaledToFit().padding(10),
                            color: Color.secondary,
                            destination:  TrendView()
                        )
                        headerBtn(
                            Image(systemName: "fork.knife.circle")
                                .resizable().scaledToFit().padding(10),
                            color: Color.brown,
                            destination:  AddFoodView()
                        )
                    }
                    headerBtn(
                        Label("Log", systemImage: "plus.circle.fill")
                            .font(Font.headline),
                        color: Color.accentColor,
                        destination:  AddItemView()
                    )
                    
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
            .navigationViewStyle(.stack)
        }
    }
    
    private func groupBy(_ items: FetchedResults<OutputEntity>, dateComponents: Set<Calendar.Component>) -> [Bucket<Date, OutputEntity>] {
        return DateUtility.groupBy(items, dateComponents: dateComponents)
    }
    
    private func headerBtn(_ label: some View, color: Color, destination: some View) -> some View {
        let btn = Button(action: {}, label: {
            NavigationLink(destination: destination) {
                label
            }
        })
        .frame(maxWidth: .infinity, maxHeight: 55)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(9)
        
        return AnyView(btn);
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
