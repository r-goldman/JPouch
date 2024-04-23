//
//  AddOutputView.swift
//  J Pouch
//
//  Created by Riley Goldman on 4/21/24.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    private var entity: OutputEntity? = nil
    @State private var colorValue: Color
    @State private var consistencyValue: String
    @State private var timestamp: Date
    
    init(entity: OutputEntity? = nil) {
        if (entity != nil) {
            self.entity = entity
            self._colorValue = State(initialValue: Color(uiColor: UIColor(rgb: entity!.color)))
            self._consistencyValue = State(initialValue: entity!.consistency ?? "paste")
            self._timestamp = State(initialValue: entity!.timestamp ?? Date())
        }
        else {
            self._colorValue = State(initialValue: Color(red: 88/255, green: 51/255, blue: 0))
            self._consistencyValue = State(initialValue: "paste")
            self._timestamp = State(initialValue: Date())
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Output")) {
                VStack {
                    ColorPicker("Color", selection: $colorValue, supportsOpacity: false)
                    Picker("Consistency", selection: $consistencyValue) {
                        Text("Paste").tag("paste")
                        Text("Slime").tag("slime")
                        Text("Liquid").tag("liquid")
                        
                    }
                }
            }
            Section(header: Text("Time")) {
                DatePicker("Time", selection: $timestamp)
                    .datePickerStyle(.graphical)
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
