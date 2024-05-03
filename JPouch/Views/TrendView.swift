//
//  SwiftUIView.swift
//  JPouch
//
//  Created by Riley Goldman on 4/22/24.
//

import SwiftUI
import Charts

enum Timescale: String {
    case Daily = "daily"
    case Weekly = "weekly"
    case Monthly = "monthly"
}

struct TagCount {
    var name: String
    var value: Int
    var bucket: Bucket<Date, OutputEntity>
}

struct TrendView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @FetchRequest(
        entity: OutputEntity.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \OutputEntity.timestamp, ascending: false)
        ]
    )
    private var outputEntities: FetchedResults<OutputEntity>
    
    @State private var timescale: Timescale = .Daily
    @State private var chartFilter: String? = nil
    @State private var presentPopup: Bool = false
    
    var body: some View {
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            VStack {
                Image(systemName: "rectangle.landscape.rotate")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                Text("Rotate Device").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            }
            .foregroundColor(.white)
            .frame(maxWidth: 300, maxHeight: 300)
            .background(Color.black.opacity(0.5))
            .cornerRadius(20)
            .padding()
        }
        else {
            withAnimation {
                mainContent
            }
        }
    }
    
    var mainContent: some View {
        VStack {
            Picker("Timescale", selection: $timescale) {
                Text("14 Days").tag(Timescale.Daily)
                Text("3 Months").tag(Timescale.Weekly)
                Text("Year").tag(Timescale.Monthly)
            }.pickerStyle(.segmented)
            
            let bucketList = group(outputEntities)
            let tagData = getTagData(bucketList)
            
            TabView {
                Chart(bucketList) { bucket in
                    BarMark(
                        x: .value("Date", getBarLabel(bucket: bucket)),
                        y: .value("Total", bucket.items.count)
                    )
                    .annotation(position: .overlay, alignment: .center) {
                        Text("\(bucket.items.count)").foregroundColor(.white)
                    }
                }
                .padding()
                .tabItem {
                    Label("Summary", systemImage: "chart.bar")
                }
                
                ZStack(alignment:.topTrailing) {
                    renderTagChart((tagData.0, tagData.1))
                    Button(
                        action: { presentPopup = true },
                        label: {Label("", systemImage: "gear")}
                    )
                    .padding()
                    .popover(
                        isPresented: $presentPopup,
                        arrowEdge: .trailing
                    ) {
                        VStack(alignment: .trailing) {
                            Form {
                                Picker("Focus", selection: $chartFilter) {
                                    ForEach(tagData.1.sorted(by:<), id: \.self) { value in
                                        Text(value).tag(value as String?)
                                    }
                                    Text("none").tag(nil as String?)
                                }.onChange(of: chartFilter, { presentPopup = false })
                                Button("Clear", action: { chartFilter = nil; presentPopup = false })
                            }
                        }
                        .frame(minWidth: 300, minHeight: 150)
                        .presentationCompactAdaptation(.popover)
                    }
                }.tabItem {
                    Label("Detail", systemImage: "percent")
                }
                
                Chart(tagData.2.sorted(by: {$0.key < $1.key}), id: \.self.key) { key, value in
                    SectorMark(
                        angle: .value("Tag Name", value)
                    )
                    .foregroundStyle(
                        by: .value("Tag Name", key)
                    )
                    .annotation(position: .overlay, alignment: .center) {
                        Text("\(value)").foregroundColor(.white)
                    }
                }
                .chartLegend(position: .trailing, alignment: .center)
                .padding()
                .tabItem {
                    Label("Totals", systemImage: "chart.pie")
                }
            }
        }
    }

    private func getTagData(_ bucketList: [Bucket<Date,OutputEntity>]) -> ([TagCount], Set<String>, Dictionary<String, Int>) {
        var tagSet: Set<String> = []
        var tagList: [TagCount] = []
        var tagDict: [String:Int] = [:]
        
        for bucket in bucketList {
            var tagMap: [String:Int] = ["no tag":0]
            for item in bucket.items {
                let tagValues = item.tags?.components(separatedBy: ",") ?? []
                if tagValues.count == 0 {
                    tagMap["no tag"]! += 1
                    tagSet.insert("no tag")
                }
                tagValues.forEach({ value in
                    if tagDict[value] == nil { tagDict[value] = 1 }
                    else { tagDict[value]! += 1 }
                        
                    tagSet.insert(value)
                        
                    if tagMap[value] == nil { tagMap[value] = 1 }
                    else { tagMap[value]! += 1 }
                })
            }
            tagMap.forEach({ tagName, count in
                if (count > 0) {
                    tagList.append(TagCount(name: tagName, value: count, bucket: bucket))
                }
            })
        }
        return (tagList, tagSet, tagDict)
    }
    
    private func renderTagChart(_ tagData: ([TagCount], Set<String>)) -> some View {
        let (tagList, tagSet) = tagData
        let chart = Chart(tagList, id: \.self.bucket.id) { tag in
            BarMark(
                x: .value("Date", getBarLabel(bucket: tag.bucket)),
                y: .value("Total", tag.value)
            )
            .foregroundStyle(
                by: .value("Tag Name", tag.name)
            )
            .annotation(position: .overlay, alignment: .center) {
                Text("\(tag.value)").foregroundColor(.white)
            }
        }
        .chartLegend(position: .trailing, alignment: .center)
        .padding()
        
        
        var wrappedChart: any View = chart;
        if (chartFilter != nil) {
            wrappedChart = chart.chartForegroundStyleScale(domain: tagSet, mapping: { str in
                return str == chartFilter ? Color.green : Color.gray.opacity(0.5)
            })
        }
        return AnyView(wrappedChart)
    }
    
    private func group(_ items: FetchedResults<OutputEntity>) -> [Bucket<Date, OutputEntity>] {
        let oneDayAgo = Double(-60 * 60 * 24)
        let dateComponents: Set<Calendar.Component>
        let maxAge: Date
        switch timescale {
            case .Daily:
                dateComponents = [.day, .month, .year]
                maxAge = Date().advanced(by: oneDayAgo * 14) // 14 days ago
                break
            case .Weekly:
                dateComponents = [.weekOfYear, .yearForWeekOfYear]
                maxAge = Date().advanced(by: oneDayAgo * 7 * 12) // 12 weeks ago
                break
            case .Monthly:
                dateComponents = [.month, .year]
                maxAge = Calendar.current.date(byAdding: .year, value: -1, to: Date())! // 1 year ago
        }
        let filtered = items.filter({ $0.timestamp > maxAge})
        return DateUtility.groupBy(filtered, dateComponents: dateComponents).sorted(by: { $0.id < $1.id })
    }
    
    private func getBarLabel(bucket: Bucket<Date, OutputEntity>) -> String {
        let formatter = DateFormatter()
        let first = bucket.items.first!.timestamp
        switch timescale {
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
