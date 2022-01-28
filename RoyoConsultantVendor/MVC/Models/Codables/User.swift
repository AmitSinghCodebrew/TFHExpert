//
//  User.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class User: Codable {
    var id: Int?
    var name: String?
    var phone: String?
    var country_code: String?
    var profile_image: String?
    var fcm_id: String?
    var email: String?
    var provider_type: ProviderType?
    var stripe_id: String?
    var stripe_account_id: String?
    var is_agreed: Bool?
    var socket_id: String?
    var token: String?
    var categoryData: Category?
    var services: [Service]?
    var filters: [Filter]?
    var profile: ProfileUser?
    var account_verified: Bool?
    var totalRating: Double?
    var reviewCount: Int?
    var address: String?
    var qualification: String?
    var speciality: String?
    var call_price: Either<Double, String>?
    var chat_price: Either<Double, String>?
    var patientCount: Int?
    var additionals: [AdditionalDetail]?
    var master_preferences: [Filter]?
    var custom_fields: [CustomField]?
    var reference_code: String?
    var medical_history: [MedicalHistory]?
    var category: String?
    var custom_message: String?
}

final class MedicalHistory: Codable {
    var id: Int?
    var request_id: Int?
    var comment: String?
    var request: Requests?
}

final class ProfileUser: Codable {
    var id: Int?
    var dob: String?
    var country: String?
    var experience: String?
    var speciality: String?
    var rating: Double?
    var about: String?
    var user_id: Int?
    var bio: String?
    var title: String?
    var working_since: String?
}


final class MedicalHistoryData: Codable {
    var doctors: [User]?
    var after: String?
    var before: String?
    var per_page: Int?
}
