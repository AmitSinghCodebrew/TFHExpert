//
//  BanksData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 13/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class BanksData: Codable {
    var bank_accounts: [Bank]?
}

final class Bank: Codable {
    var id: Int?
    var name: String?
    var bank_name: String?
    var account_number: String?
    var last_four_digit: String?
    var ifc_code: String?
    var account_holder_type: String
    var country: String?
    var currency: String?
    var created_at: String?
}
