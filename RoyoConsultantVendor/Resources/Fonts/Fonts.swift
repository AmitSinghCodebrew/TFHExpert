//
//  Fonts.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 25/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

enum Fonts: String {
    case CamptonSemiBold = "Campton-SemiBold"
    case CamptonMedium = "Campton-Medium"
    case CamptonLight = "Campton-Light"
    case CamptonBook = "Campton-Book"
    
  func ofSize(_ value: CGFloat) -> UIFont {
    return UIFont(name: self.rawValue, size: value) ?? UIFont.systemFont(ofSize: value)
  }
}
