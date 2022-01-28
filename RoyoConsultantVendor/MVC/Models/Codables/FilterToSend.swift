//
//  FilterToSend.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class FilterToSend: Codable {
    var filter_id: Int?
    var filter_option_ids: [Int]?
    
    
    init(_ id: Int?, _ optionIds: [Int]?) {
        filter_id = id
        filter_option_ids = optionIds
    }
}

final class PreferenceToSend: Codable {
    var preference_id: Int?
    var option_ids: [Int]?
    
    init(_ id: Int?, _ optionIds: [Int]?) {
        preference_id = id
        option_ids = optionIds
    }
}
