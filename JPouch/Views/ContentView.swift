//
//  ContentView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var displayGroupSheet: Bool = false
    @State var selectedGroup: Bucket<Date, OutputEntity> = Bucket(id: Date()) // default non-nil value
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                //ScrollView {
                CalendarView(
                        interval: DateInterval.init(start: .distantPast, end: .distantFuture),
                        selected: $selectedGroup,
                        displayGroupSheet: $displayGroupSheet
                    )
                //}
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
                    GroupView(bucket: $selectedGroup)
                        .navigationTitle(selectedGroup.id.formatted(date: .abbreviated, time: .omitted))
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                NavigationLink(destination: AddItemView(defaultDate: selectedGroup.id).navigationTitle("Add Item")) {
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
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    NavigationLink(destination: AddItemView().navigationTitle("Add Item")) {
//                        Image(systemName: "plus.circle")
//                    }
//                }
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
}


#Preview {
    ContentView()
}
