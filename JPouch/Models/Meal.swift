//
//  Meal.swift
//  JPouch
//
//  Created by Riley Goldman on 5/19/24.
//

import Foundation
import HealthKit

class Meal: Timestamped {
    private let samples: [HKQuantitySample]
    
    var id: UUID
    var timestamp: Date
    
    // macros
    var carbs: Double = 0.0
    var protien: Double = 0.0
    var fat: Double = 0.0
    
    var macros: KeyValuePairs<String, Double> {
        get {
            return [
                "Carbs": carbs,
                "Protien": protien,
                "Fat": fat
            ]
        }
    }
    
    // fat breakdown
    var saturatedFat: Double = 0.0
    var monounsaturatedFat: Double = 0.0
    var polyunsaturatedFat: Double = 0.0
    
    var fatMakeup: KeyValuePairs<String, Double> {
        get {
            return [
                "Saturated": saturatedFat,
                "Monounsaturated": monounsaturatedFat,
                "Polyunsaturated": polyunsaturatedFat
            ]
        }
    }
    
    // misc
    var fiber: Double = 0.0
    var sugar: Double = 0.0
    var caffiene: Double = 0.0
    
    init() {
        id = UUID()
        timestamp = Date()
        samples = []
    }
    private init(samples: [HKQuantitySample]) {
        self.samples = samples
        self.id = samples.first?.uuid ?? UUID()
        self.timestamp = samples.first?.startDate ?? Date.distantPast
        for sample in samples {
            let type = HKQuantityTypeIdentifier(rawValue: sample.quantityType.identifier)
            let amount = sample.quantity.doubleValue(for: .gram())
            
            switch type {
                case .dietaryProtein:
                    self.protien += amount
                    break
                case .dietaryCarbohydrates:
                    self.carbs += amount
                    break
                case .dietaryFatTotal:
                    self.fat += amount
                    break
                case .dietaryFatSaturated:
                    self.saturatedFat += amount
                    break
                case .dietaryFatMonounsaturated:
                    self.monounsaturatedFat += amount
                    break
                case .dietaryFatPolyunsaturated:
                    self.polyunsaturatedFat += amount
                    break
                case .dietaryFiber:
                    self.fiber += amount
                    break
                case .dietarySugar:
                    self.sugar += amount
                    break
                case .dietaryCaffeine:
                    self.caffiene += (amount / 1000.0)
                    break
                default:
                    print("WARNING: unknown dietary type \(type)")
            }
        }
    }
    
    static func fromSamples(_ samples: [HKQuantitySample]) -> [Meal] {
        var meals: [Meal] = []
        var mealStartTime: Date? = nil
        var currentGroup: [HKQuantitySample] = []
        for sample in samples {
            let timestamp = sample.startDate
            if (mealStartTime == nil) {
                mealStartTime = timestamp
                currentGroup.append(sample)
            }
            else if (timestamp.timeIntervalSince1970 - mealStartTime!.timeIntervalSince1970 < 60 * 30) {
                currentGroup.append(sample)
            }
            else {
                meals.append(Meal(samples: currentGroup))
                currentGroup = []
                mealStartTime = nil
            }
        }
        
        if !currentGroup.isEmpty {
            meals.append(Meal(samples: currentGroup))
        }
        
        return meals
    }
}
