//
//  LoginEP.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation
import Moya

enum Ep_Others {
    
    case getContactList(after: String?)
    case addContact(contacts: String?)
    case deleteContact(contactId: String?)
    case contactMessage(body: String?)
    case acceptRequest(requestId: String?)
    case cancelRequest(requestId: String?)
    case getPendingRequests
    
}

extension Ep_Others: TargetType, AccessTokenAuthorizable {
    
    var baseURL: URL {
        return URL(string: Configuration.getValue(for: .APP_BASE_PATH))!
    }
    
    var path: String {
        switch self {
        
        case .getContactList:
            return APIConstants.contactList
        case .addContact:
            return APIConstants.contactAdd
        case .deleteContact:
            return APIConstants.contactDelete
        case .contactMessage:
            return APIConstants.contactMessage
        case .acceptRequest:
            return APIConstants.acceptRequestV2
        case .cancelRequest:
            return APIConstants.cancelRequestV2
        case .getPendingRequests:
            return APIConstants.pendingRequest
        }
    }
    
    var method: Moya.Method {
        switch self {
        
        case .getContactList, .getPendingRequests:
            return .get
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
        default:
            return ["Accept" : "application/json",
                    "Authorization":"Bearer " + /UserPreference.shared.data?.token,
                    "devicetype": "IOS",
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
        
        switch self {
        
        case .getContactList(let after):
            return Parameters.contactListing.map(values: [after])
        case .addContact(let contacts):
            return Parameters.addContact.map(values: [contacts])
        case .deleteContact(let contactId):
            return Parameters.deleteContact.map(values: [contactId])
        case .contactMessage(let body):
            return Parameters.contactMessage.map(values: [body])
        case .acceptRequest(let requestId):
            return Parameters.acceptRequestV2.map(values: [requestId])
        case .cancelRequest(let requestId):
            return Parameters.acceptRequestV2.map(values: [requestId])
        case .getPendingRequests:
            return nil

        default:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        
        case .getContactList, .getPendingRequests:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
}
