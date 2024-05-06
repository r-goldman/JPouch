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
    @State var selectedIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ScrollView {
                CalendarView(
                        interval: DateInterval.init(start: .distantPast, end: .distantFuture),
                        store: store,
                        selectedIndex: $selectedIndex,
                        displayGroupSheet: $displayGroupSheet
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
                    GroupView(bucket: $store.data[selectedIndex])
                        .navigationTitle(store.data[selectedIndex].id.formatted(date: .abbreviated, time: .omitted))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: AddItemView(defaultDate: getDefaultDate(store.data[selectedIndex].id)).navigationTitle("Add Item")) {
                                    Image(systemName: "plus.circle")
                                }
                            }
                        }
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: TrendView().navigationTitle("Trends").navigationBarTitleDisplayMode(.inline)) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                }
            }
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
    
    private func getDefaultDate(_ calendarDay: Date) -> Date {
        var components = Calendar.current.dateComponents([.day, .month, .year], from: calendarDay)
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = currentTime.hour
        components.minute = currentTime.minute
        
        return Calendar.current.date(from: components)!
        
    }
}


#Preview {
    ContentView()
}
