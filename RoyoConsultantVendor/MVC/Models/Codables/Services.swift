//
//  Services.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 30/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class ServicesData: Codable {
    var services: [Service]?
    var after: String?
    var before: String?
    var per_page: Int?
}

final class Service: Codable {
    var id: Int?
    var category_id: Int?
    var service_id: Int?
    var available: CustomBool?
    var price_minimum: Either<Double, String>?
    var price_maximum: Either<Double, String>?
    var minimum_duration: Either<Double, String>?
    var gap_duration: Either<Double, String>?
    var name: String?
    var color_code: String?
    var description: String?
    var need_availability: CustomBool?
    var price_fixed: Either<Double, String>?
    var price_type: PriceType?
    var minimmum_heads_up: Either<Double, String>?
    var price: Double?
    var category_service_id: Int?
    var unit_price: Either<Double, String>?
    var main_service_type: String?
    var clinic_address: ClinicAddress?
    var service_name: String?
    var isSelected: Bool? = false
    
    init(_ _name: String?) {
        service_name = _name
        name = _name
        isSelected = true
    }
    
    
    public func isClinicAddress() -> Bool {
        return /main_service_type == "clinic_visit" || /main_service_type == "home_visit"
    }
}


class ClinicAddress: Codable {
    var locationName: String?
    var lat: Double?
    var long: Double?
}
