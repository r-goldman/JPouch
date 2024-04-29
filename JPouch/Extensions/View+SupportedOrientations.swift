//
//  View+SupportedOrientations.swift
//  JPouch
//
//  Created by Riley Goldman on 4/29/24.
//

import SwiftUI

extension View {
    func supportedOrientations(_ supportedOrientations: UIInterfaceOrientationMask) -> some View {
        preference(key: SupportedOrientationsPreferenceKey.self, value: supportedOrientations)
    }
}
