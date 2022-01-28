//
//  TransactionHistory.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class TransactionData: Codable {
    var payments: [Payment]?
    var after: String?
    var before: String?
    var per_page: Int?
}

final class Payment: Codable {
    var id: Int?
    var from: User?
    var to: User?
    var transaction_id: Int?
    var created_at: String?
    var updated_at: String?
    var call_duration: Double?
    var service_type: String?
    var amount: Double?
    var type: TransactionType?
    var status: String?
    var payout_message: String?
    var closing_balance: Double?
}

final class WalletBalance: Codable {
    var balance: Double?
}

final class CardsData: Codable {
    var cards: [PaymentCard]?
}

final class PaymentCard: Codable {
    var id: Int?
    var card_brand: String?
    var last_four_digit: String?
    var created_at: String?
    var is_default: CustomBool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case card_brand
        case last_four_digit
        case created_at
        case is_default = "default"
    }
}

final class CreateRequestData: Codable {
    var amountNotSufficient: Bool?
    var message: String?
}

final class StripeData: Codable {
    var transaction_id: String?
    var requires_source_action: Bool?
    var url: String?
    
}
