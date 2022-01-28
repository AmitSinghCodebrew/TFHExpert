//
//  VendorDetailData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 03/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class VendorDetailData: Codable {
    var vendor_data: User?
    
    private enum CodingKeys: String, CodingKey {
        case vendor_data = "dcotor_detail"
    }
}


