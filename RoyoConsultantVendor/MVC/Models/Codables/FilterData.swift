//
//  FilterData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class FilterData: Codable {
    var filters: [Filter]?
}

final class Filter: Codable {
    var id: Int?
    var category_id: Int?
    var filter_name: String?
    var preference_name: String?
    var is_multi: CustomBool?
    var options: [FilterOption]?
}

final class FilterOption: Codable {
    var id: Int?
    var option_name: String?
    var filter_type_id: Int?
    var isSelected: Bool?
}

final class MasterPreferences: Codable {
    var preferences: [Filter]?
}


extension Array where Element == Filter {
    func getLanguagePrefrence() -> Filter? {
        return self.first(where: {$0.preference_name == "Languages"})
    }
    
    func getGenderPreference() -> Filter? {
        return self.first(where: {$0.preference_name == "Gender"})
    }
}
