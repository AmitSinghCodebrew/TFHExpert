//
//  AppData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 29/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class AppData: Codable {
    var update_type: AppUpdateType?
}

final class ClientDetail: Codable {
    var client_features: [ClientFeature]?
    var currency_code: String?
    var jitsi_id: Int?
    var charges: String?
    var class_calling: String?
    var unit_price: String?
    var slot_duration: String?
    var vendor_auto_approved: Bool?
    var currency: String?
    var insurance: Bool?
    var insurances: [Insurance]?
    var applogo: String?
    var custom_fields: CustomFields?
    var country_id: Int?
    var country_name: String?
    var domain: String?
    var domain_url: String?
    var country_name_code: String?
    var invite_enabled: Bool?
    var support_url: String?
    var pages: [Page]?
    
    func getJitsiUniqueID(_ type: JitsiUsedFor, id: Int) -> String {
        switch type {
        case .CALL:
 
            return "Call_\(/jitsi_id)_\(id)"
        case .CLASS:
 
            return "Class_\(/jitsi_id)_\(id)"
        }
    }
    
    func hasAddress() -> Bool {
        return /client_features?.contains(where: {/$0.name == "Address Required"})
    }
    
    func hasInsurance() -> Bool {
        return /insurance
    }
    
    func hasQualification(for app: UserType) -> Bool {
        switch app {
        case .customer:
            return /custom_fields?.customer?.contains(where: {$0.field_name == "Qualification"})
        case .service_provider:
            return /custom_fields?.service_provider?.contains(where: {$0.field_name == "Qualification"})
        }
    }
    
    func hasZipCode(for app: UserType) -> Bool {
        switch app {
        case .customer:
            return /custom_fields?.customer?.contains(where: {/$0.field_name == "Zip Code"})
        case .service_provider:
            return /custom_fields?.service_provider?.contains(where: {/$0.field_name == "Zip Code"})
        }
    }
    
    func getCustomField(for type: CustomFieldType, user: UserType) -> CustomField? {
        switch user {
        case .customer:
            switch type {
            case .ZipCode:
                return custom_fields?.customer?.first(where: {$0.field_name == "Zip Code"})
            case .Qualification:
                return custom_fields?.customer?.first(where: {$0.field_name == "Qualification"})
            }
        case .service_provider:
            switch type {
            case .ZipCode:
                return custom_fields?.service_provider?.first(where: {$0.field_name == "Zip Code"})
            case .Qualification:
                return custom_fields?.service_provider?.first(where: {$0.field_name == "Qualification"})
            }
        }
    }
    
    func openAddressInsuranceScreen() -> Bool {
        return hasAddress() || hasInsurance()
    }
}

final class Insurance: Codable {
    var id: Int?
    var category_id: Int?
    var name: String?
    var company: String?
    
    var isSelected: Bool?
}

final class ClientFeature: Codable {
    var client_feature_id: Int?
    var feature_id: Int?
    var client_id: Int?
    var name: String?
}

final class CustomFields: Codable {
    var customer: [CustomField]?
    var service_provider: [CustomField]?
}

final class CustomField: Codable {
    var id: Int?
    var field_type: String?
    var field_name: String?
    var field_value: String?
    var required_sign_up: String?
}

enum JitsiUsedFor {
    case CALL
    case CLASS
}

enum CustomFieldType: Int {
    case ZipCode
    case Qualification
    
    var fieldName: String {
        switch self {
        case .ZipCode:
            return "Zip Code"
        case .Qualification:
            return "Qualification"
        }
    }
}
