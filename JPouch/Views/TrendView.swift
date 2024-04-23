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
            HStack {
                Button("14 Days") { chartMode = .Daily}
                    .foregroundColor(chartMode == .Daily ? .secondary : .accentColor)
                Spacer()
                Button("3 Months") { chartMode = .Weekly}
                    .foregroundColor(chartMode == .Weekly ? .secondary : .accentColor)
                Spacer()
                Button("Year") { chartMode = .Monthly}
                    .foregroundColor(chartMode == .Monthly ? .secondary : .accentColor)
            }.padding()
            Chart(group(outputEntities)) {
                LineMark(
                    x: .value("Date", $0.id),
                    y: .value("Total", $0.items.count)
                )
                .interpolationMethod(.catmullRom)
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
}

#Preview {
    TrendView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
