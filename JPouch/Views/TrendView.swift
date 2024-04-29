//
//  SwiftUIView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import SwiftUI
import Charts

enum ChartMode: String {
    case Daily = "daily"
    case Weekly = "weekly"
    case Monthly = "monthly"
}

struct TrendView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: OutputEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \OutputEntity.timestamp, ascending: false)
        ]
    )
    private var outputEntities: FetchedResults<OutputEntity>
    @State private var chartMode: ChartMode = .Daily;
    
    var body: some View {
        VStack {
            Picker("Timescale", selection: $chartMode) {
                Text("14 Days").tag(ChartMode.Daily)
                Text("3 Months").tag(ChartMode.Weekly)
                Text("Year").tag(ChartMode.Monthly)
            }.pickerStyle(.segmented)
            Chart(group(outputEntities)) { bucket in
                BarMark(
                    x: .value("Date", getBarLabel(bucket: bucket)),
                    y: .value("Total", bucket.items.count)
                )
                .annotation(position: .overlay, alignment: .center) {
                    Text("\(bucket.items.count)").foregroundColor(.white)
                }
            }.padding()
        }
    }
    
    private func group(_ items: FetchedResults<OutputEntity>) -> [Bucket<Date, OutputEntity>] {
        let oneDayAgo = Double(-60 * 60 * 24)
        let dateComponents: Set<Calendar.Component>
        let maxAge: Date
        switch chartMode {
            case .Daily:
                dateComponents = [.day, .month, .year]
                maxAge = Date().advanced(by: oneDayAgo * 14) // 14 days ago
                break
            case .Weekly:
                dateComponents = [.weekOfYear, .year]
                maxAge = Date().advanced(by: oneDayAgo * 7 * 12) // 12 weeks ago
                break
            case .Monthly:
                dateComponents = [.month, .year]
                maxAge = Calendar.current.date(byAdding: .year, value: -1, to: Date())! // 1 year ago
        }
        let filtered = items.filter({ $0.timestamp > maxAge})
        return DateUtility.groupBy(filtered, dateComponents: dateComponents)
    }
    
    private func getBarLabel(bucket: Bucket<Date, OutputEntity>) -> String {
        let formatter = DateFormatter()
        let first = bucket.items.first!.timestamp
        switch chartMode {
            case .Daily:
                formatter.dateFormat = "MMM dd"
                return formatter.string(from: first)
            case .Weekly:
                formatter.dateFormat = "MMM"
                let month = formatter.string(from: first)
                let last = bucket.items.last!.timestamp
                formatter.dateFormat = "dd"
                let end = formatter.string(from: first) // items are sorted desc
                let start = formatter.string(from: last)
                return "\(month) \(start)-\(end)"
            case .Monthly:
                formatter.dateFormat = "MMM"
                return formatter.string(from: first)
        }
    }
}

#Preview {
    TrendView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
