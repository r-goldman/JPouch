//
//  CalendarView.swift
//  JPouch
//
//  Created by Riley Goldman on 5/3/24.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var store: OutputStore
    @Binding var displayGroupSheet: Bool
    @Binding var selectedIndex: Int
    @Binding var displayAddSheet: Bool
    @Binding var selectedDate: Date
    
    func makeUIView(context: Context) -> some UICalendarView {
        let view = UICalendarView()
        view.delegate = context.coordinator
        view.calendar = Calendar(identifier: .gregorian)
        view.availableDateRange = interval
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            store: store,
            selectedIndex: $selectedIndex,
            displayGroupSheet: $displayGroupSheet,
            selectedDate: $selectedDate,
            displayAddSheet: $displayAddSheet
        )
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let modified = store.modified else { return }
        uiView.reloadDecorations(forDateComponents: modified, animated: true)
        store.modified = nil
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        @ObservedObject var store: OutputStore
        @Binding var selectedIndex: Int
        @Binding var displayGroupSheet: Bool
        @Binding var displayAddSheet: Bool
        @Binding var selectedDate: Date
        
        init(
            store:OutputStore,
            selectedIndex: Binding<Int>,
            displayGroupSheet: Binding<Bool>,
            selectedDate: Binding<Date>,
            displayAddSheet: Binding<Bool>
        ) {
            self.store = store
            self._selectedIndex = selectedIndex
            self._displayGroupSheet = displayGroupSheet
            self._selectedDate = selectedDate
            self._displayAddSheet = displayAddSheet
        }
        
        @MainActor
        func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration?
        {
            let index = store.data.firstIndex(where: { $0.id == Calendar.current.date(from: dateComponents)})
            
            guard let index else { return nil }
            let bucket = store.data[index]
            
            let count = bucket.items.count
            return .customView {
                let icon = UILabel()
                icon.text = "\(count)"
                icon.textColor = self.getTextColor(count)
                return icon
            }
        }
        
        private func getTextColor(_ count: Int) -> UIColor {
            if count >= 15 {
                return .red
            }
            else if count >= 10 {
                return .orange
            }
            else if count >= 5 {
                return UIColor(Color.yellow)
            }
            else {
                return  UIColor(Color.green)
            }
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate dateComponents: DateComponents?) {
            guard dateComponents != nil else { return }
            
            let index = store.data.firstIndex(where: {$0.id == dateComponents!.date})
            
            guard let index else {
                selectedDate = Calendar.current.date(from: dateComponents!)!
                displayAddSheet = true
                return
            }
        
            selectedIndex = index
            displayGroupSheet = true
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           canSelectDate dateComponents: DateComponents?) -> Bool {
            return true
        }
    }
}

#Preview {
    let viewContext = PersistenceController.preview.container.viewContext
    let bucket = Bucket<Date, OutputEntity>(id: Calendar.current.startOfDay(for: Date()))
    bucket.items = Array(1...15).map { index in
        let data = OutputEntity(context: viewContext)
        data.id = UUID()
        data.color = UIColor(.brown).rgb
        data.consistency = "thick"
        data.timestamp = Date().advanced(by: Double(index * -60 * 60 * Int.random(in: 2...8)))
        return data
    }
    return CalendarView(
        interval: DateInterval.init(start: .distantPast, end: .distantFuture),
        store: OutputStore.shared,
        displayGroupSheet: .constant(false),
        selectedIndex: .constant(0),
        displayAddSheet: .constant(false),
        selectedDate: .constant(Date())
    )
}
