//
//  AddOutputView.swift
//  J Pouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI
let colorOptions = Array<Color>([
    Color(red: 97/255, green: 61/255, blue: 11/255), // brown
    Color(red: 181/255, green: 125/255, blue: 40/255), // tan
    Color(red: 235/255, green: 192/255, blue: 40/255), // yellow
    Color(red: 166/255, green: 9/255, blue: 7/255), // red
    Color(red: 40/255, green: 77/255, blue: 12/255), // green
    Color.black,
    Color.gray
])

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
        
    var entity: Binding<OutputEntity>?
    @State private var colorValue: Color
    @State private var consistencyValue: String
    @State private var tagsValue: Set<String>
    @State private var timestamp: Date
    @State private var tagViewHeight: CGFloat = 0
    
    init(entity: Binding<OutputEntity>? = nil, defaultDate: Date = Date()) {
        self.entity = entity
        let entityVal = entity?.wrappedValue
        
        self.colorValue = entityVal != nil ? Color(uiColor: UIColor(rgb: entityVal!.color)) : colorOptions[0]
        self.consistencyValue = entityVal?.consistency ?? "thick"
        
        var components = Calendar.current.dateComponents([.day, .month, .year], from: defaultDate)
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = currentTime.hour
        components.minute = currentTime.minute
        
        self.timestamp = entityVal?.timestamp ?? Calendar.current.date(from: components)!
        
        let tagsArr = entityVal?.tags?.components(separatedBy: ",") ?? []
        self.tagsValue = tagsArr.isEmpty ? Set() : Set(tagsArr)
    }
    
    var body: some View {
        Form() {
            Section(header: Text("Attributes")) {
                VStack(alignment: .leading) {
                    HStack {
                        Menu(
                            content: {
                                Picker("", selection: $colorValue) {
                                    ForEach(colorOptions, id: \.self) { color in
                                        Image(systemName: "circle.fill")
                                            .tint(color)
                                            .tag(color)
                                    }
                                }
                                .pickerStyle(.palette)
                            },
                            label: {
                                Circle()
                                    .fill(colorValue)
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 60, height: 40)
                            }
                        )
                            Picker("Consistency", selection: $consistencyValue) {
                                Text("Thick").tag("thick")
                                Text("Slime").tag("slime")
                                Text("Watery").tag("watery")
                            }.pickerStyle(.segmented)
                    }.padding(5)
                }
            }
            Section(header: Text("Tags")) {
                TagPicker(
                    values: ["butt burn", "gassy", "overnight", "undigested"],
                    selection: $tagsValue,
                    height: $tagViewHeight
                ).frame(minHeight: tagViewHeight)
            }
            Section(header: Text("Time")) {
                DatePicker("Time", selection: $timestamp)
                    .datePickerStyle(.compact)
            }
            Section {
                    HStack {
                        Spacer()
                        Button("Submit") {
                            self.upsert()
                        }
                        Spacer()
                    }
            }
        }
    }
    
    private func upsert() {
        let vm = OutputStore.shared
        vm.upsert(entity: self.entity?.wrappedValue, color: colorValue, consistency: consistencyValue, timestamp: timestamp, tags: tagsValue)
    
        dismiss()
    }
}

#Preview {
    AddItemView()
}
