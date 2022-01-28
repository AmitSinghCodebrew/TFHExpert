//
//  AdditionalDetailsData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 11/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class AdditionalDetailsData: Codable {
    var additional_details: [AdditionalDetail]?
    var additionals: [AdditionalDetail]?
}

final class AdditionalDetail: Codable {
    var id: Int?
    var name: String?
    var category_id: Int?
    var type: String?
    var documents: [Doc]?
}

final class Doc: Codable {
    var description: String?
    var file_name: String?
    var title: String?
    
    init(_ _title: String?, _ _desc: String?, _ _fileName: String?) {
        title = _title
        description = _desc
        file_name = _fileName
    }
}
