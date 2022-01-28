//
//  EP_Home.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 15/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation
import Moya

enum EP_Home {
    case categories(parentId: String?, after: String?)
    case uploadMedia(image: UIImage, type: MediaTypeUpload, doc: Document?, localAudioPath: String?)
    case getFilters(categoryId: String?, userId: String?)
    case services(categoryId: String?)
    case updateServices(categoryId: String?, filters: Any?, category_services_type: Any?)
    case transactionHistory(transactionType: TransactionType, after: String?)
    case wallet
    case requests(date: String?, after: String?, secondOpinion: String?, service_id: Int?, status: RequestStatus?)
    case acceptRequest(requestId: String?)
    case startChat(requestId: String?)
    case cancelRequest(requestId: String?, reason: String?)
    case notifications(after: String?)
    case logout
    case chatListing(after: String?)
    case chatMessages(requestId: String?, after: String?)
    case endChat(requestId: String?)
    case vendorDetail(vendorId: String?)
    case getSlots(vendor_id: String?, date: String?, service_id: String?, category_id: String?)
    case classes(type: ClassType, categoryId: String?, after: String?)
    case updateClassStatus(classId: String?, status: ClassStatus)
    case addClass(categoryId: String?, price: String?, date: String?, time: String?, name: String?)
    case updateFCMId
    case revenue
    case makeCall(requestID: String?)
    case callStatus(requestID: String?, status: CallStatus, callId: String?)
    case startRequest(requestId: String?)
    case appversion(app: AppType, version: String?)
    case pages
    case addBank(country: String?, currency: String?, account_holder_name: String?, account_holder_type: String?, ifc_code: String?, account_number: String?, bank_name: String?, bank_id: Int?)
    case banks
    case payouts(bankId: Int?, amount: String?)
    case addCard(cardNumber: String?, expMonth: String?, expYear: String?, cvv: String?)
    case addMoney(balance: String?, cardId: String?)
    case deleteCard(cardId: String?)
    case updateCard(cardId: String?, name: String?, expMonth: String?, expYear: String?)
    case cards
    case getClientDetail(app: AppType)
    case getAdditionalDetails(id: Int?)
    case addAdditionalDetails(fields: Any?)
    case addFeed(title: String?, desc: String?, type: FeedType?, image: String?)
    case getFeeds(feedType: FeedType?, consultant_id: Int?, after: String?, favourite: CustomBool?)
    case addFav(feedId: Int?, favorite: CustomBool)
    case viewFeed(id: Int?)
    case addPrescriptions(request_id: Int?, type: PrescriptionType, pre_scription_notes: String?, title: String?, image: [String]?, pre_scriptions: Any?)
    case masterPreferences(type: MasterPrefernceType)
    case getQuestions(after: String?)
    case replyQuestion(id: Int?, answer: String?)
    case requestDetail(requestId: Int?)
    case addProteinLimit(limit: String?)
    case getProteinLimit
    case drinkProtein(qty: String?)
    case addWaterLimit(limit: String?)
    case getWaterLimit
    case drinkWater(qty: String?)
    case extraPayment(requestId: Int?, balance: String?, description: String?)
    case startCall(requestId: Int?)
    #if NurseLynxExpert
    case updateCarePlan(id: Int?, requestId: Int?, status: CarePlanStatus)
    #endif
    case addMedicalHistory(id: Int?, comment: String?)
    case getMedicalHistory(request_id: Int?, after: String?)
}

extension EP_Home: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL.init(string: Configuration.getValue(for: .APP_BASE_PATH))!
    }
    
    var path: String {
        switch self {
        case .uploadMedia:
            return APIConstants.uploadImage
        case .categories:
            return APIConstants.categories
        case .getFilters:
            return APIConstants.getFilters
        case .services:
            return APIConstants.services
        case .updateServices:
            return APIConstants.updateServices
        case .transactionHistory:
            return APIConstants.transactionHistory
        case .wallet:
            return APIConstants.wallet
        case .requests:
            return APIConstants.requests
        case .acceptRequest:
            return APIConstants.acceptRequest
        case .startChat:
            return APIConstants.startChat
        case .logout:
            return APIConstants.logout
        case .cancelRequest:
            return APIConstants.cancelRequest
        case .notifications(_):
            return APIConstants.notifications
        case .chatListing(_):
            return APIConstants.chatListing
        case .chatMessages:
            return APIConstants.chatMessages
        case .endChat(_):
            return APIConstants.endChat
        case .vendorDetail(_):
            return APIConstants.vendorDetail
        case .getSlots:
            return APIConstants.getSlots
        case .classes:
            return APIConstants.classes
        case .updateClassStatus:
            return APIConstants.updateClassStatus
        case .addClass:
            return APIConstants.addClass
        case .updateFCMId:
            return APIConstants.updateFCMId
        case .revenue:
            return APIConstants.revenue
        case .makeCall(_):
            return APIConstants.makeCall
        case .callStatus:
            return APIConstants.callStatus
        case .startRequest(_):
            return APIConstants.startRequest
        case .appversion:
            return APIConstants.appVersion
        case .pages:
            return APIConstants.pages
        case .addBank:
            return APIConstants.addBank
        case .banks:
            return APIConstants.banks
        case .payouts:
            return APIConstants.payouts
        case .addCard:
            return APIConstants.addCard
        case .addMoney:
            return APIConstants.addMoney
        case .deleteCard(_):
            return APIConstants.deleteCard
        case .updateCard:
            return APIConstants.updateCard
        case .cards:
            return APIConstants.cards
        case .getClientDetail(_):
            return APIConstants.clientDetail
        case .getAdditionalDetails(_):
            return APIConstants.additionalDetails
        case .addAdditionalDetails(_):
            return APIConstants.additionalDetailData
        case .addFeed(_, _, _, _),
             .getFeeds(_, _, _, _):
            return APIConstants.feeds
        case .addFav(let id, _):
            return "\(APIConstants.addFav)/\(/id)"
        case .viewFeed(let id):
            return "\(APIConstants.viewFeed)/\(/id)"
        case .addPrescriptions(_, _, _, _, _, _):
            return APIConstants.addPrescription
        case .masterPreferences(_):
            return APIConstants.masterPreferences
        case .getQuestions:
            return APIConstants.askQuestions
        case .replyQuestion:
            return APIConstants.replyQuestion
        case .requestDetail:
            return APIConstants.requestDetail
        case .addWaterLimit, .getWaterLimit:
            return APIConstants.waterLimit
        case .drinkWater:
            return APIConstants.drinkWater
        case .addProteinLimit, .getProteinLimit:
            return APIConstants.proteinLimit
        case .drinkProtein:
            return APIConstants.drinkProtein
        case .extraPayment:
            return APIConstants.extraPayment
        case .startCall:
            return APIConstants.startCall
        case .addMedicalHistory:
            return APIConstants.createMedicalHistory
        case .getMedicalHistory:
            return APIConstants.getMedicalHistory
        #if NurseLynxExpert
        case .updateCarePlan:
            return APIConstants.updateCarePlan
        #endif
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .categories,
             .getFilters,
             .services,
             .transactionHistory,
             .wallet,
             .requests,
             .notifications,
             .chatListing,
             .chatMessages,
             .vendorDetail,
             .getSlots,
             .classes,
             .revenue,
             .pages,
             .banks,
             .cards,
             .getClientDetail(_),
             .getAdditionalDetails(_),
             .getFeeds(_, _, _, _),
             .viewFeed(_),
             .masterPreferences(_),
             .getQuestions(_),
             .getWaterLimit,
             .getProteinLimit,
             .requestDetail,
             .getMedicalHistory:
            return .get
        default:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .categories(let parentId, let after):
            return Parameters.categories.map(values: [parentId, after])
        case .getFilters(let categoryId, let userId):
            return Parameters.getFilters.map(values: [categoryId, userId])
        case .services(let categoryId):
            return Parameters.services.map(values: [categoryId])
        case .updateServices(let categoryId, let filters, let category_services_type):
            return Parameters.updateServices.map(values: [categoryId, filters, category_services_type])
        case .transactionHistory(let transactionType, let after):
            return Parameters.transactionHistory.map(values: [transactionType.rawValue, after])
        case .requests(let date, let after, let secondOpinion, let service_id, let status):
            return Parameters.requests.map(values: [date, after, secondOpinion, service_id, status?.apiFilterValue])
        case .acceptRequest(let requestId):
            return Parameters.acceptRequest.map(values: [requestId])
        case .startChat(let requestId):
            return Parameters.startChat.map(values: [requestId])
        case .cancelRequest(let requestId, let reason):
            return Parameters.acceptRequest.map(values: [requestId, reason])
        case .notifications(let after):
            return Parameters.notifications.map(values: [after])
        case .chatListing(let after):
            return Parameters.chatListing.map(values: [after])
        case .chatMessages(let requestId, let after):
            return Parameters.chatMessages.map(values: [requestId, after])
        case .endChat(let requestId):
            return Parameters.endChat.map(values: [requestId])
        case .vendorDetail(let vendorID):
            return Parameters.vendorDetail.map(values: [vendorID])
        case .getSlots(let vendor_id, let date, let service_id, let category_id):
            return Parameters.getSlots.map(values: [vendor_id, date, service_id, category_id])
        case .classes(let type, let categoryId, let after):
            return Parameters.classes.map(values: [type.rawValue, categoryId, after])
        case .updateClassStatus(let classId, let status):
            return Parameters.updateClassStatus.map(values: [classId, status.rawValue])
        case .addClass(let categoryId, let price, let date, let time, let name):
            return Parameters.addClass.map(values: [categoryId, price, date, time, name])
        case .updateFCMId:
            return Parameters.updateFCMId.map(values: [UserPreference.shared.firebaseToken])
        case .makeCall(let requestID):
            return Parameters.makeCall.map(values: [requestID])
        case .callStatus(let requestID, let status, let callId):
            return Parameters.callStatus.map(values: [requestID, status.rawValue, callId])
        case .startRequest(let requestId):
            return Parameters.startRequest.map(values: [requestId])
        case .appversion(let app, let version):
            return Parameters.appversion.map(values: [app.rawValue, version, "1"]) //1-IOS
        case .addBank(let country, let currency, let account_holder_name, let account_holder_type, let ifc_code, let account_number, let bank_name, let bank_id):
            return Parameters.addBank.map(values: [country, currency, account_holder_name, account_holder_type, ifc_code, account_number, bank_name, bank_id])
        case .payouts(let bankId, let amount):
            return Parameters.payouts.map(values: [bankId, amount])
        case .addCard(let cardNumber, let expMonth, let expYear, let cvv):
            return Parameters.addCard.map(values: [cardNumber, expMonth, expYear, cvv])
        case .addMoney(let balance, let cardId):
            return Parameters.addMoney.map(values: [balance, cardId])
        case .deleteCard(let cardId):
            return Parameters.deleteCard.map(values: [cardId])
        case .updateCard(let cardId, let name, let expMonth, let expYear):
            return Parameters.updateCard.map(values: [cardId, name, expMonth, expYear])
        case .getClientDetail(let app):
            return Parameters.clientDetail.map(values: [app.rawValue])
        case .getAdditionalDetails(let id):
            return Parameters.services.map(values: [id])
        case .addAdditionalDetails(let fields):
            return Parameters.addAdditionalDetails.map(values: [fields])
        case .addFeed(let title, let desc, let type, let image):
            return Parameters.addFeed.map(values: [title, desc, type?.rawValue, image])
        case .getFeeds(let feedType, let consultant_id, let after, let favourite):
            return Parameters.getFeeds.map(values: [feedType?.rawValue, consultant_id, after, favourite?.rawValue])
        case .addFav(_, let favorite):
            return Parameters.addFav.map(values: [/Int(favorite.rawValue)])
        case .addPrescriptions(let request_id, let type, let pre_scription_notes, let title, let image, let pre_scriptions):
            return Parameters.addPrescription.map(values: [request_id, type.rawValue, pre_scription_notes, title, image, pre_scriptions])
        case .masterPreferences(let type):
            return Parameters.masterPreferences.map(values: [type.rawValue])
        case .getQuestions(let after):
            return Parameters.getQuestions.map(values: [after])
        case .replyQuestion(let id, let answer):
            return Parameters.replyQuestion.map(values: [id, answer])
        case .uploadMedia(_, let type, _, _):
            return Parameters.uploadMedia.map(values: [type.rawValue])
        case .requestDetail(let requestId):
            return Parameters.acceptRequest.map(values: [requestId])
        case .addWaterLimit(let limit):
            return Parameters.addWaterLimit.map(values: [limit])
        case .drinkWater(let quantity):
            return Parameters.drinkWater.map(values: [quantity])
        case .addProteinLimit(let limit):
            return Parameters.addWaterLimit.map(values: [limit])
        case .drinkProtein(let quantity):
            return Parameters.drinkWater.map(values: [quantity])
        case .extraPayment(let requestId, let balance, let description):
            return Parameters.extraPayment.map(values: [requestId, balance, description])
        case .startCall(let requestId):
            return Parameters.makeCall.map(values: [requestId])
        case .addMedicalHistory(let id, let comment):
            return Parameters.addMedicalHistory.map(values: [id, comment])
        case .getMedicalHistory(let request_id, let after):
            return Parameters.getMedicalHistory.map(values: [request_id, after])
        #if NurseLynxExpert
        case .updateCarePlan(let id, let requestId, let status):
            return Parameters.updateCarePlan.map(values: [id, requestId, status.rawValue])
        #endif
        default:
            return nil
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .uploadMedia:
            return Task.uploadMultipart(multipartBody ?? [])
        default:
            return Task.requestParameters(parameters: parameters ?? [:], encoding: parameterEncoding)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .appversion(_, _),
             .masterPreferences(_):
            return ["Accept" : "application/json",
                    "devicetype": "IOS",
                    "app-id": Configuration.getValue(for: .APP_PROJECT_ID),
                    "timezone": NSTimeZone.local.identifier,
                    "user-type": UserType.service_provider.rawValue,
                    "language" : L102Language.currentAppleLanguage() == .Arabic ? "ar" : "en"]
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
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .categories,
             .getFilters,
             .services,
             .transactionHistory,
             .wallet,
             .requests,
             .notifications,
             .chatListing,
             .chatMessages,
             .vendorDetail,
             .getSlots,
             .classes,
             .revenue,
             .pages,
             .banks,
             .cards,
             .getClientDetail(_),
             .getAdditionalDetails(_),
             .getFeeds(_, _, _, _),
             .viewFeed(_),
             .masterPreferences(_),
             .getQuestions,
             .getWaterLimit,
             .getProteinLimit,
             .requestDetail,
             .getMedicalHistory:
            return URLEncoding.queryString
        default:
            return JSONEncoding.default
        }
    }
    
    var multipartBody: [MultipartFormData]? {
        var multiPartData = [MultipartFormData]()
        switch self {
        case .uploadMedia(let image, let mediaType, let doc, let localAudioPath):
            switch mediaType {
            case .image:
                let data = image.jpegData(compressionQuality: 0.5) ?? Data()
                multiPartData.append(MultipartFormData.init(provider: .data(data), name: Keys.image.rawValue, fileName: "image.jpg", mimeType: "image/jpeg"))
            case .pdf:
                let data = doc?.data ?? Data()
                multiPartData.append(MultipartFormData.init(provider: .data(data), name: Keys.image.rawValue, fileName: /doc?.fileName, mimeType: "application/pdf"))
            case .audio:
                let fileName = /localAudioPath?.split(separator: "/").last?.lowercased()
                guard let data = try? Data.init(contentsOf: URL.init(string: /localAudioPath)!) else {
                    return multiPartData
                }
                multiPartData.append(MultipartFormData.init(provider: .data(data), name: Keys.image.rawValue, fileName: fileName, mimeType: "audio/m4a"))
            }
        default: break
        }
        
        parameters?.forEach({ (key, value) in
            let tempValue = /(value as? String)
            let data = tempValue.data(using: String.Encoding.utf8) ?? Data()
            multiPartData.append(MultipartFormData.init(provider: .data(data), name: key))
        })
        return multiPartData
    }
    
}
