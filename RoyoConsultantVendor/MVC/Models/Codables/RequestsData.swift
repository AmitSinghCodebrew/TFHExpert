//
//  RequestsData.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class RequestData: Codable {
    var requests: [Requests]?
    var request_detail: Requests?
    var after: String?
    var before: String?
    var per_page: Int?
    var notification_count: Int?
}

final class Requests: Codable {
    var id: Int?
    var from_user: User?
    var to_user: User?
    var booking_date: String?
    var bookingDateUTC: String?
    var canReschedule: Bool?
    var canCancel: Bool?
    var time: String?
    var service_type: String?
    var duration: Double?
    var status: RequestStatus?
    var price: Either<Double, String>?
    var is_prescription: Bool?
    var main_service_type: String?
    var extra_detail: ExtraDetail?
    var second_oponion: SecondOpinion?
    var pre_scription: PrescriptionDetail?
    var symptoms: [Symptom]?
    var symptom_details: String?
    var symptom_images: [MediaObj]?
    var service: Service?
    var extra_payment: ExtraPayment?
    var medical_history_added: Bool?
    var cancel_reason: String?

    #if NurseLynxExpert
    var tier_detail: Tier?
    #elseif CloudDocPro
    var question_answers: [QuestionAnswer]?
    #endif
    
    func getRelatedAction() -> RequestAction {
        switch /main_service_type?.lowercased() {
        case "audio_call":
            return .CALL
        case "video_call":
            return .VIDEO_CALL
        case "home_visit":
            return .HOME
        case "chat":
            return .CHAT
        default:
            return .DEFAULT
        }
    }
}

class Tier: Codable {
    var id: Int?
    var title: String?
    var price: Double?
    var tier_options: [TierOption]?
}

class TierOption: Codable {
    var id: Int?
    var title: String?
    var tier_id: Int?
    var status: CarePlanStatus?
    
    var type: TierOptionToggle?
}



enum TierOptionToggle: String, Codable, CaseIterableDefaultsLast {
    case NeedSomeHelp = "1"
    case NeedMuchHelp = "2"
    case None = "3"
    
    #if NurseLynxExpert
    var localized: String {
        switch self {
        case .NeedSomeHelp:
            return VCLiteral.NeedSomeHelp.localized
        case .NeedMuchHelp:
            return VCLiteral.NeedMuchHelp.localized
        case .None:
            return ""
        }
    }
    #endif
}

final class ExtraPayment: Codable {
    var balance: Double?
    var status: ExtraPaymentStatus?
    var description: String?
    var created_at: String?
    
    init(_ _balane: Double?, _ _status: ExtraPaymentStatus, _ _description: String?) {
        balance = _balane
        status = _status
        description = _description
    }
}


final class PrescriptionDetail: Codable {
    var id: Int?
    var type: PrescriptionType?
    var title: String?
    var pre_scription_notes: String?
    var request_id: Int?
    var medicines: [Prescription]?
    var images: [String]?
}

final class ExtraDetail: Codable {
    var service_address: String?
    var lat: String?
    var long: String?
    var phone_number: String?
    var country_code: String?
    
}

enum RequestAction {
    case CALL
    case VIDEO_CALL
    case CHAT
    case HOME
    case DEFAULT
}

final class SecondOpinion: Codable {
    var title: String?
    var images: String? //Multiple images , separated
    var record_type: String?
}

final class Symptom: Codable {
    var id: Int?
    var name: String?
    var image: String?
    var isSelected: Bool? = false
    var symptom_id: Int?
}

final class CallerData: Codable {
    var action: String?
    var call_id: String?
}

