//
//  RequestsData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class PendingData: Codable {
    var pending_requests: [Pending]?
    var after: String?
    var before: String?
    var per_page: Int?
}

final class Pending: Codable {
    var id: Int?
    var category: Category?
    var extra_details: ExtraDetail?
    var service_type: String?
    var status: RequestStatus?
    var main_service_type: String?

    var sr_info: User?
    var from_user: User?
    var booking_date: String?
    var booking_end_date: String?
    var order_data: String?
    var sp_id: Int?
    var bookingDateUTC: String?
    var price: Either<Double, String>?
    var remain_second: Int?
    
}

final class RequestDetailData: Codable {
    var request_detail: RequestId?
}

final class RequestId: Codable {
    var id: Int?
}

final class SendEmergencyData: Codable {
    var contact_added: Bool?
}

