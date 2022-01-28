//
//  CategoriesData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class CategoryData: Codable {
    var classes_category: [Category]?
    var after: String?
    var before: String?
    var per_page: Int?
}

final class Category: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var enable: String?
    var parent_id: Int?
    var description: String?
    var multi_select: String?
    var color_code: String?
    var image_icon: String?
    var is_subcategory: Bool?
    var is_filters: Bool?
    var is_additionals: Bool?
}
