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
                Spacer()
                getModeButton("14 Days", value: .Daily)
                getModeButton("3 Months", value: .Weekly)
                getModeButton("Year", value: .Monthly)
                Spacer()
            }.padding(.top)
            Chart(group(outputEntities)) {
                BarMark(
                    x: .value("Date", getBarLabel(bucket: $0)),
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
                let start = formatter.string(from: first)
                let end = formatter.string(from: last)
                return "\(month) \(start)-\(end)"
            case .Monthly:
                formatter.dateFormat = "MMM"
                return formatter.string(from: first)
        }
    }
    
    private func getModeButton(_ display: String, value: ChartMode) -> some View {
        let style: any PrimitiveButtonStyle = chartMode == value ? .borderedProminent : .bordered
        let btn = Button(
            action: { chartMode = value },
            label: {
                Text(display).frame(maxWidth: .infinity)
            }
        )
            .buttonStyle(style)
        .frame(maxHeight: 30)
        
        return AnyView(btn)
    }
}

#Preview {
    TrendView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
