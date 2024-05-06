//
//  CalendarView.swift
//  JPouch
//
//  Created by Riley Goldman on 5/3/24.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @Binding var selected: Bucket<Date, OutputEntity>
    @Binding var displayGroupSheet: Bool
    
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
        Coordinator(selected: $selected, displayGroupSheet: $displayGroupSheet)
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let store = OutputStore.shared
        guard let modified = store.modified else { return }
        uiView.reloadDecorations(forDateComponents: modified, animated: true)
        store.modified = nil
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        @Binding var selected: Bucket<Date, OutputEntity>
        @Binding var displayGroupSheet: Bool
        @StateObject var store =  OutputStore.shared
        
        init(selected: Binding<Bucket<Date, OutputEntity>>, displayGroupSheet: Binding<Bool>) {
            self._selected = selected
            self._displayGroupSheet = displayGroupSheet
        }
        
        @MainActor
        func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration?
        {
            let bucket = store.data.filter({ $0.id == Calendar.current.date(from: dateComponents)})
            if bucket.isEmpty { return nil }
            
            let count = bucket.first?.items.count ?? 0
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
            
            let bucket = store.data.filter {$0.id == dateComponents!.date}
            if !bucket.isEmpty {
                selected = bucket.first!
                displayGroupSheet = true
            }
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
        selected: .constant(bucket),
        displayGroupSheet: .constant(false)
    )
}
