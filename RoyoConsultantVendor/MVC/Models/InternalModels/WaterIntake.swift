//
//  WaterIntake.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 23/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

class WaterGlass {
    var qty: Int? //in millilitres
    var isSelected: Bool? = false

    init(_ ml: Int?) {
        qty = ml
    }
    
    class func getGlasses() -> [WaterGlass] {
        return [WaterGlass(100),
                WaterGlass(250),
                WaterGlass(500),
                WaterGlass(750),
                WaterGlass(1000)]
    }
    
    class func getProteins() -> [WaterGlass] {
        return [WaterGlass(25),
                WaterGlass(50),
                WaterGlass(75),
                WaterGlass(100),
                WaterGlass(125),
                WaterGlass(150),
                WaterGlass(175),
                WaterGlass(200),
                WaterGlass(225),
                WaterGlass(250)]
    }
}
