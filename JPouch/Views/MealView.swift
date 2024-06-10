//
//  MealView.swift
//  JPouch
//
//  Created by Riley Goldman on 5/20/24.
//

import SwiftUI
import Charts

struct MealView: View {
    var meal: Meal
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(meal.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.title)
                    Spacer()
                    
                    HStack {
                        Text("Sugar").bold()
                        Text("\(meal.sugar.round(to: 2)) g").italic()
                    }
                    HStack {
                        Text("Fiber").bold()
                        Text("\(meal.fiber.round(to: 2)) g").italic()
                    }
                    HStack {
                        Text("Caffiene").bold()
                        Text("\(meal.caffiene.round(to: 2)) mg").italic()
                    }
                    Spacer()
                }
                Chart(meal.macros, id: \.key) { macro in
                    SectorMark(angle: .value(macro.key, macro.value))
                        .foregroundStyle(
                            by: .value("Macro", macro.key)
                        )
                }
                .chartLegend(position: .trailing, alignment: .center)
            }
            HStack {
                Chart(meal.fatMakeup, id: \.key) { fat in
                    BarMark(
                        x: .value("fat", fat.value)
                    )
                    .foregroundStyle(by: .value("Fat Category", fat.key))
                }.chartLegend(position: .top, alignment: .center)
            }
        }
        .frame(width: .infinity, height: 150)
        .padding(.horizontal)
    }
}

#Preview {
    let meal = Meal()
    meal.carbs = 240
    meal.fat = 120
    meal.saturatedFat = 20
    meal.monounsaturatedFat = 90
    meal.polyunsaturatedFat = 30
    meal.protien = 120
    meal.sugar = 40
    meal.caffiene = 12
    meal.fiber = 13
    
    return MealView(meal: meal)
}
