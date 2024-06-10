//
//  ContentView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var store = OutputStore.shared
    @State var displayGroupSheet: Bool = false
    @State var displayAddSheet: Bool = false
    @State var selectedIndex: Int = 0
    @State var selectedDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView {
                CalendarView(
                        interval: DateInterval.init(start: .distantPast, end: .distantFuture),
                        store: store,
                        displayGroupSheet: $displayGroupSheet,
                        selectedIndex: $selectedIndex,
                        displayAddSheet: $displayAddSheet,
                        selectedDate: $selectedDate
                    )
                }
                HStack {
                    headerBtn(
                        Label("Log", systemImage: "plus.circle.fill")
                            .font(Font.headline),
                        color: Color.accentColor,
                        destination:  AddItemView().navigationTitle("Add Item")
                    )
                }.padding()
            }
            .navigationTitle("Pouch Log")
            .navigationBarTitleDisplayMode(.large)
            .navigationViewStyle(.stack)
            .navigationDestination(
                isPresented: $displayGroupSheet,
                destination: {
                    getGroupView()
                }
            )
            .navigationDestination(
                isPresented: $displayAddSheet,
                destination: {
                    AddItemView(defaultDate: selectedDate)
                        .navigationTitle("Add Item")
                }
            )
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    NavigationLink(destination:
//                                    InfoView()
//                        .navigationTitle("Info")
//                        .navigationBarTitleDisplayMode(.inline)
//                    ) {
//                        Image(systemName: "info.circle")
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination:
//                            TrendView()
//                            .navigationTitle("Trends")
//                            .navigationBarTitleDisplayMode(.inline)
//                    ) {
//                        Image(systemName: "chart.line.uptrend.xyaxis")
//                    }
//                }
//            }
        }
    }
    
    private func headerBtn(_ label: some View, color: Color, destination: some View) -> some View {
        let btn = Button(action: {}, label: {
            NavigationLink(destination: destination) {
                label
            }.frame(maxWidth: .infinity, maxHeight: 55)
        })
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(9)
        
        return AnyView(btn);
    }
    
    private func getGroupView() -> some View {
        var view: any View
        if store.data.isEmpty || selectedIndex >= store.data.count {
            view = Text("No Data")
        }
        else {
            view = GroupView(bucket: $store.data[selectedIndex])
                .navigationTitle(store.data[selectedIndex].id.formatted(date: .abbreviated, time: .omitted))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(
                            destination: AddItemView(defaultDate:store.data[selectedIndex].id)
                                .navigationTitle("Add Item")
                        ) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
        }
        return AnyView(view)
    }
}


#Preview {
    ContentView()
}
