//
//  DoubleExtension.swift
//  AE
//
//  Created by MAC_MINI_6 on 23/05/19.
//  Copyright © 2019 MAC_MINI_6. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func roundedString(toPlaces places:Int) -> String {
        return String(format: "%.\(places)f", self)
    }
    
    func getFormattedPrice() -> String {
        let localeID = Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue : /UserPreference.shared.clientDetail?.currency])
        let formmater = NumberFormatter()
        formmater.numberStyle = .currency
        formmater.locale = Locale.init(identifier: localeID)
        return /formmater.string(from: self as NSNumber)
    }
}

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
