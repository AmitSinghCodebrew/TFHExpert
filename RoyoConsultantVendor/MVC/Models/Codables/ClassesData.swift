//
//  ClassesData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 11/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class ClassesData: Codable {
    var classes: [ClassObj]?
    var after: String?
    var before: String?
    var per_page: Int?
}

final class ClassObj: Codable {
    var id: Int?
    var name: String?
    var status: ClassStatus?
    var calling_type: String? //SDK
    var class_date: String?
    var created_at: String?
    var bookingDateUTC: String?
    var price: Either<Double, String>?
    var category_id: Int?
    var created_by: User?
    var booking_date: String?
    var time: String?
    var category_data: Category?
    var isOccupied: Bool?
    var enroll_user_data: [User]?
}
