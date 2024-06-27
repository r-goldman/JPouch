//
//  TestView.swift
//  JPouch
//
//  Created by Riley Goldman on 5/19/24.
//

import SwiftUI
import Charts
import HealthKit

struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var settings: SettingStore
    @State var redThreshold: Int
    @State var orangeThreshold: Int
    @State var yellowThreshold: Int
    @State var nightStart: Date
    @State var nightEnd: Date
    @State var displayReset: Bool = false
    
    init() {
        self.settings = SettingStore.shared
        self.redThreshold = Int(settings.data.redThreshold)
        self.orangeThreshold = Int(settings.data.orangeThreshold)
        self.yellowThreshold = Int(settings.data.yellowThreshold)
        self.nightStart = settings.data.nightStart!
        self.nightEnd = settings.data.nightEnd!
    }
    
    var redRange: Range<Int> {
        (orangeThreshold + 1)..<21
    }
    var orangeRange: Range<Int> {
        (yellowThreshold + 1)..<redThreshold
    }
    var yellowRange: Range<Int> {
        1..<orangeThreshold
    }
    
    var body: some View {
        VStack {
            Form {
                Section("Thresholds (≥)") {
                    Picker("Red", selection: $redThreshold) {
                        ForEach(redRange, id: \.self) {
                            Text("\($0)").tag($0)
                        }
                    }
                    Picker("Orange", selection: $orangeThreshold) {
                        ForEach(orangeRange, id: \.self) {
                            Text("\($0)").tag($0)
                        }
                    }
                    Picker("Yellow", selection: $yellowThreshold) {
                        ForEach(yellowRange, id: \.self) {
                            Text("\($0)").tag($0)
                        }
                    }
                }
                Section("Sleep Schedule") {
                    DatePicker("Wake Up", selection: $nightEnd, displayedComponents: [.hourAndMinute])
                    DatePicker("Go to Sleep", selection: $nightStart, displayedComponents: [.hourAndMinute])
                }
                Section {
                    Button(action: saveSettings) {
                        Text("Submit")
                    }
                    Button(action: { displayReset = true }) {
                        Text("Reset").foregroundStyle(Color.red)
                    }
                }
            }
        }
        .alert("Are you sure you want to revert to the default settings?", isPresented: $displayReset) {
            Button("Yes", role: .destructive) { resetSettings() }
            Button("No", role: .cancel) {}
        }
    }
    
    func saveSettings() {
        settings.set(
            redThreshold: Int16(redThreshold),
            orangeThreshold: Int16(orangeThreshold),
            yellowThreshold: Int16(yellowThreshold),
            nightStart: nightStart,
            nightEnd: nightEnd
        )
        dismiss()
    }
    func resetSettings() {
        settings.clear()
        dismiss()
    }
}


#Preview {
    InfoView()
}
