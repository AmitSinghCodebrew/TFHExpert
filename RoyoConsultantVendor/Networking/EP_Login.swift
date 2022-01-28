//
//  LoginEP.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation
import Moya

enum EP_Login {
    case login(provider_type: ProviderType, provider_id: String?, provider_verification: String?, user_type: UserType, country_code: String?, is_agreed: Bool?)
    case sendOTP(phone: String?, countryCode: String?)
    case profileUpdate(name: String?, email: String?, phone: String?, country_code: String?, dob: String?, bio: String?, speciality: String?, call_price: String?, chat_price: String?, category_id: String?, experience: String?, profile_image: String?, workingSince: String?, namePrefix: String?, custom_fields: String?, master_preferences: Any?, inviteCode: String?, is_agreed: Bool?)
    case register(name: String?, email: String?, password: String?, phone: String?, code: String?, user_type: UserType, fcm_id: String?, country_code: String?, dob: String?, bio: String?, profile_image: String?, workingSince: String?, custom_fields: String?, master_preferences: Any?, inviteCode: String?, is_agreed: Bool?)
    case forgotPsw(email: String?)
    case updatePhone(phone: String?, countryCode: String?, otp: String?)
    case changePassword(currentPSW: String?, newPSW: String?)
    case sendEmailOTP(email: String)
    case verifyEmailOTP(email: String, otp: String?)
    case locationUpdate
}

extension EP_Login: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        return URL(string: Configuration.getValue(for: .APP_BASE_PATH))!
    }
    
    var path: String {
        switch self {
        case .login:
            return APIConstants.login
        case .sendOTP:
            return APIConstants.sendOTP
        case .profileUpdate, .locationUpdate:
            return APIConstants.profileUpdate
        case .register:
            return APIConstants.register
        case .forgotPsw:
            return APIConstants.forgotPsw
        case .updatePhone:
            return APIConstants.updatePhone
        case .changePassword:
            return APIConstants.changePsw
        case .sendEmailOTP:
            return APIConstants.sendEmailOTP
        case .verifyEmailOTP:
            return APIConstants.verifyEmail
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        default:
            return Task.requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .profileUpdate, .updatePhone, .locationUpdate:
            return ["Accept" : "application/json",
                    "Authorization":"Bearer " + /UserPreference.shared.data?.token,
                    "devicetype": "IOS",
                    "app-id": Configuration.getValue(for: .APP_PROJECT_ID),
                    "timezone": NSTimeZone.local.identifier,
                    "user-type": UserType.service_provider.rawValue,
                    "language" : L102Language.currentAppleLanguage() == .Arabic ? "ar" : "en"]
        default:
            return ["devicetype": "IOS",
                    "Accept" : "application/json",
                    "app-id": Configuration.getValue(for: .APP_PROJECT_ID),
                    "timezone": NSTimeZone.local.identifier,
                    "user-type": UserType.service_provider.rawValue,
                    "language" : L102Language.currentAppleLanguage() == .Arabic ? "ar" : "en"]
        }
    }
    
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    //Custom Varaibles
    var parameters: [String: Any]? {
        let location = LocationManager.shared.locationData

        
        switch self {
        case .login(let provider_type, let provider_id, let provider_verification, let user_type, let country_code, let is_agreed):
            return Parameters.login.map(values: [provider_type.rawValue, provider_id, provider_verification, user_type.rawValue, country_code, is_agreed])
        case .sendOTP(let phone, let countryCode):
            return Parameters.sendOTP.map(values: [phone, countryCode])
        case .profileUpdate(let name, let email, let phone, let country_code, let dob, let bio, let speciality, let call_price, let chat_price, let category_id, let experience, let profile_image, let workingSince, let namePrefix, let customFields, let master_preferences, let inviteCode, let is_agreed):
            return Parameters.profileUpdate.map(values: [name, email, phone, country_code, dob, bio, speciality, call_price, chat_price, category_id, experience, profile_image, workingSince, namePrefix, String(/location.latitude), String(/location.longitude), LocationManager.shared.address?.name, customFields, master_preferences, inviteCode, is_agreed])
        case .register(let name, let email, let password, let phone, let code, let user_type, let fcm_id, let country_code, let dob, let bio, let profile_image, let workingSince, let customFields, let master_preferences, let inviteCode, let is_agreed):
            return Parameters.register.map(values: [name, email, password, phone, code, user_type.rawValue, fcm_id, country_code, dob, bio, profile_image, workingSince, customFields, master_preferences, inviteCode, is_agreed])
        case .forgotPsw(let email):
            return Parameters.email.map(values: [email])
        case .updatePhone(let phone, let countryCode, let otp):
            return Parameters.updatePhone.map(values: [phone, countryCode, otp])
        case .changePassword(let currentPSW, let newPSW):
            return Parameters.changePsw.map(values: [currentPSW, newPSW])
        case .sendEmailOTP(let email):
            return Parameters.email.map(values: [email])
        case .verifyEmailOTP(let email, let otp):
            return Parameters.verifyEmail.map(values: [email, otp])
        case .locationUpdate:
            return Parameters.locationUpdate.map(values: [String(/location.latitude), String(/location.longitude)])
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
    
}
