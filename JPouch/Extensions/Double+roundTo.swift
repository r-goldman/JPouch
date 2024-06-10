//
//  Double+roundTo.swift
//  JPouch
//
//  Created by Riley Goldman on 5/20/24.
//

import Foundation
 
extension Double {
    func round(to places: Int = 0) -> String {
        let divisor = pow(10.0, Double(places))
        let rounded = (self * divisor).rounded() / divisor
        
        return String(rounded)
    }
}
