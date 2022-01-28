//
//  Parameter+Keys.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 12/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

typealias OptionalDictionary = [String : Any]?

extension Sequence where Iterator.Element == Keys {
    func map(values: [Any?]) -> OptionalDictionary {
        var params = [String : Any]()
        
        for (index,element) in zip(self,values) {
            if element != nil {
                params[index.rawValue] = element
            }
        }
        return params
    }
}

enum Keys: String {
    case provider_type
    case provider_id
    case provider_verification
    case user_type
    case country_code
    case name
    case email
    case password
    case phone
    case code
    case fcm_id
    case dob
    case bio
    case profile_image
    case speciality
    case call_price
    case chat_price
    case category_id
    case experience
    case otp
    case working_since
    case title
    case lat
    case long
    case location_name
    case image
    case after
    case parent_id
    case user_id
    case filters
    case category_services_type
    case transaction_type
    case date
    case service_type
    case request_id
    case vendor_id = "doctor_id"
    case service_id
    case CategoryId
    case type
    case class_id
    case status
    case price
    case time
    case app_type
    case current_version
    case device_type
    case country
    case currency
    case account_holder_name
    case account_holder_type
    case ifc_code
    case account_number
    case bank_name
    case bank_id
    case amount
    case card_number
    case exp_month
    case exp_year
    case cvc
    case balance
    case card_id
    case fields
    case description
    case consultant_id
    case addFav
    case favorite
    case pre_scription_notes
    case pre_scriptions
    case custom_fields
    case master_preferences
    case answer
    case question_id
    case second_oponion
    case current_password
    case new_password
    case limit
    case quantity
    case invite_code
    case call_id
    case cancel_reason
    case id
    case comment
    case is_agreed
    
    case contacts
    case body
}

struct Parameters {
    static let login: [Keys] = [.provider_type, .provider_id, .provider_verification, .user_type, .country_code, .is_agreed]
    
    static let register: [Keys] = [.name, .email, .password, .phone, .code, .user_type, .fcm_id, .country_code, .dob, .bio, .profile_image, .working_since, .custom_fields, .master_preferences, .invite_code, .is_agreed]
    
    static let profileUpdate: [Keys] = [.name, .email, .phone, .country_code, .dob, .bio, .speciality, .call_price, .chat_price, .category_id, .experience, .profile_image, .working_since, .title, .lat, .long, .location_name, .custom_fields, .master_preferences, .invite_code, .is_agreed]
    
    static let updatePhone: [Keys] = [.phone, .country_code, .otp]
    
    static let updateFCMId: [Keys] = [.fcm_id]
    
    static let email: [Keys] = [.email]
    
    static let verifyEmail: [Keys] = [.email, .otp]
    
    static let changePsw: [Keys] = [.current_password, .new_password]

    static let sendOTP: [Keys] = [.phone, .country_code]
    
    static let categories: [Keys] = [.parent_id, .after]
    
    static let getFilters: [Keys] = [.category_id, .user_id]
    
    static let services: [Keys] = [.category_id]
    
    static let updateServices: [Keys] = [.category_id, .filters, .category_services_type]
    
    static let transactionHistory: [Keys] = [.transaction_type, .after]

    static let requests: [Keys] = [.date, .after, .second_oponion, .service_id, .type]
    
    static let acceptRequest: [Keys] = [.request_id, .cancel_reason]
    
    static let startChat: [Keys] = [.request_id]
    
    static let notifications: [Keys] = [.after]
    
    static let chatMessages: [Keys] = [.request_id, .after]
    
    static let endChat: [Keys] = [.request_id]
    
    static let chatListing: [Keys] = [.after]
    
    static let vendorDetail: [Keys] = [.vendor_id]
    
    static let getSlots: [Keys] = [.vendor_id, .date, .service_id, .category_id]
    
    static let classes: [Keys] = [.type, .CategoryId, .after]
    
    static let updateClassStatus: [Keys] = [.class_id, .status]
    
    static let addClass: [Keys] = [.category_id, .price, .date, .time, .name]
    
    static let makeCall: [Keys] = [.request_id]
    
    static let callStatus: [Keys] = [.request_id, .status, .call_id]
    
    static let startRequest: [Keys] = [.request_id]
    
    static let appversion: [Keys] = [.app_type, .current_version, .device_type]
    
    static let addBank: [Keys] = [.country, .currency, .account_holder_name, .account_holder_type, .ifc_code, .account_number, .bank_name, .bank_id]

    static let payouts: [Keys] = [.bank_id, .amount]
    
    static let addCard: [Keys] = [.card_number, .exp_month, .exp_year, .cvc]
    
    static let addMoney: [Keys] = [.balance, .card_id]
    
    static let deleteCard: [Keys] = [.card_id]
    
    static let updateCard: [Keys] = [.card_id, .name, .exp_month, .exp_year]
    
    static let clientDetail: [Keys] = [.app_type]
    
    static let addAdditionalDetails: [Keys] = [.fields]
    
    static let addFeed: [Keys] = [.title, .description, .type, .image]
    
    static let getFeeds: [Keys] = [.type , .consultant_id, .after, .favorite]
    
    static let addFav: [Keys] = [.favorite]
    
    static let addPrescription: [Keys] = [.request_id, .type, .pre_scription_notes, .title, .image, .pre_scriptions]

    static let masterPreferences: [Keys] = [.type]
    
    static let getQuestions: [Keys] = [.after]

    static let replyQuestion: [Keys] = [.question_id, .answer]
    
    static let uploadMedia: [Keys] = [.type]
    
    static let addWaterLimit: [Keys] = [.limit]
    
    static let drinkWater: [Keys] = [.quantity]
    
    static let extraPayment: [Keys] = [.request_id, .balance, .description]
    
    static let addMedicalHistory: [Keys] = [.request_id, .comment]
    
    static let getMedicalHistory: [Keys] = [.request_id, .after]
    
    static let locationUpdate: [Keys] = [.lat, .long]
    static let addContact: [Keys] = [.contacts]
    static let deleteContact: [Keys] = [.id]
    static let contactMessage: [Keys] = [.body]
    static let contactListing: [Keys] = [.after]
    static let acceptRequestV2: [Keys] = [.id]
    static let pendingRequest: [Keys] = [.date, .second_oponion]


    #if NurseLynxExpert
    static let updateCarePlan: [Keys] = [.id, .request_id, .status]
    #endif
}

