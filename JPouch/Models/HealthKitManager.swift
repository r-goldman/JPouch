//
//  HealthKitManager.swift
//  JPouch
//
//  Created by Riley Goldman on 5/19/24.
//

import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    private let dietaryDataTypes: Array<HKQuantityType> = [
        .dietaryProtein,
        .dietaryCarbohydrates,
        .dietaryFatTotal,
        .dietaryFatSaturated,
        .dietaryFatMonounsaturated,
        .dietaryFatPolyunsaturated,
        .dietaryFiber,
        .dietarySugar,
        .dietaryCaffeine
    ].map { HKQuantityType.quantityType(forIdentifier: $0)! }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        let readTypesSet = Set<HKObjectType>(dietaryDataTypes)
        
        healthStore.requestAuthorization(toShare: nil, read: readTypesSet) { success, error in
            completion(success, error)
        }
    }
    
    func fetchDietaryData(start: Date, end: Date, completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: true
        )
        
        let query = HKSampleQuery(
            queryDescriptors: dietaryDataTypes.map {
                HKQueryDescriptor(
                    sampleType: $0,
                    predicate: predicate
                )
            },
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (query, samples, error) in
            guard let samples = samples as? [HKQuantitySample] else {
                completion(nil, error)
                return
            }
            
            completion(samples, nil)
        }
        
        healthStore.execute(query)
    }
    
    /// template
    private func fetchDietaryFiberData(completion: @escaping ([HKQuantitySample]?, Error?) -> Void) {
        guard let dietaryFiberType = HKQuantityType.quantityType(forIdentifier: .dietaryFiber) else {
            completion(nil, NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Dietary Fiber Type is unavailable"]))
            return
        }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: true
        )
        
        let query = HKSampleQuery(
            sampleType: dietaryFiberType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { (_, samples, error) in
            guard let samples = samples as? [HKQuantitySample] else {
                completion(nil, error)
                return
            }
            completion(samples, nil)
        }
        
        healthStore.execute(query)
    }
}
