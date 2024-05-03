//
//  ContentView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var vm =  OutputViewModel.shared
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    headerBtn(
                        Label("Trends", systemImage: "chart.line.uptrend.xyaxis"),
                        color: Color.secondary,
                        destination:  TrendView().navigationTitle("Trends")
                    )
                    headerBtn(
                        Label("Log", systemImage: "plus.circle.fill")
                            .font(Font.headline),
                        color: Color.accentColor,
                        destination:  AddItemView().navigationTitle("Add Item")
                    )
                    
                }.padding()
                
                List {
                    ForEach(vm.data.indices, id: \.self) { i in
                        NavigationLink {
                            GroupView(bucket: $vm.data[i])
                                .navigationTitle(vm.data[i].id.formatted(date: .abbreviated, time: .omitted))
                        } label: {
                            VStack(alignment: .leading) {
                                Text(vm.data[i].id.formatted(date: .abbreviated, time: .omitted))
                                Text("Total \(vm.data[i].items.count)").foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pouch Log")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(.stack)
        }
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
    ContentView()
}
