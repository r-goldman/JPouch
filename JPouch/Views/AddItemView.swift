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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var entity: OutputEntity?
    @State private var colorValue: Color
    @State private var consistencyValue: String
    @State private var tagsValue: Set<String>
    @State private var timestamp: Date
    @State private var tagViewHeight: CGFloat = 0
    
    init(entity: OutputEntity? = nil) {
        if (entity != nil) {
            let tags = Set<String>(entity?.tags?.components(separatedBy: ",") ?? [])
            self._entity = State(initialValue: entity)
            
            self._colorValue = State(initialValue: Color(uiColor: UIColor(rgb: entity?.color ?? 0)))
            self._consistencyValue = State(initialValue: entity?.consistency ?? "thick" )
            self._tagsValue = State(initialValue: tags)
            self._timestamp = State(initialValue: entity?.timestamp ?? Date())
        }
        else {
            self._entity = State(initialValue: nil)
            self._colorValue = State(initialValue: colorOptions[0])
            self._consistencyValue = State(initialValue: "thick")
            self._tagsValue = State(initialValue: Set<String>())
            self._timestamp = State(initialValue: Date())
        }
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
                                    .stroke(Color.blue, lineWidth: 4)
                                    .stroke(Color.white, lineWidth: 2)
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
                    values: ["butt burn", "gassy", "undigested"],
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
                            self.insert()
                        }
                        Spacer()
                    }
            }
        }
    }
    
    private func insert() {
        let data: OutputEntity
        if (self.entity != nil) {
            data = self.entity!
        }
        else {
            data = OutputEntity(context: viewContext)
            data.id = UUID()
        }
               
        data.color = UIColor(colorValue).rgb
        data.consistency = consistencyValue
        data.tags = tagsValue.sorted(by:<).joined(separator: ",")
        data.timestamp = timestamp
        
        do {
            try viewContext.save()
        }
        catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        dismiss()
    }
}

#Preview {
    AddItemView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
