//
//  DataParser.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//


import Foundation
import Moya

extension TargetType {
    
    func parseModel(data: Data) -> Any? {
        switch self {
        //EP_Login Endpoint
        case is EP_Login:
            let endpoint = self as! EP_Login
            switch endpoint {
            case .login,
                 .profileUpdate,
                 .register,
                 .updatePhone,
                 .locationUpdate:
                let response = JSONHelper<CommonModel<User>>().getCodableModel(data: data)?.data
                UserPreference.shared.data = response
                return response
            default:
                return nil
            }
        case is EP_Home:
            let endPoint = self as! EP_Home
            switch endPoint {
            case .uploadMedia:
                return JSONHelper<CommonModel<ImageUploadData>>().getCodableModel(data: data)?.data
            case .categories:
                return JSONHelper<CommonModel<CategoryData>>().getCodableModel(data: data)?.data
            case .getFilters:
                return JSONHelper<CommonModel<FilterData>>().getCodableModel(data: data)?.data
            case .services(_):
                return JSONHelper<CommonModel<ServicesData>>().getCodableModel(data: data)?.data
            case .updateServices:
                let response = JSONHelper<CommonModel<User>>().getCodableModel(data: data)?.data
                UserPreference.shared.data = response
                return response
            case .transactionHistory:
                return JSONHelper<CommonModel<TransactionData>>().getCodableModel(data: data)?.data
            case .wallet:
                return JSONHelper<CommonModel<WalletBalance>>().getCodableModel(data: data)?.data
            case .requests:
                return JSONHelper<CommonModel<RequestData>>().getCodableModel(data: data)?.data
            case .acceptRequest,
                 .startChat,
                 .cancelRequest,
                 .addClass,
                 .updateFCMId,
                 .endChat,
                 .updateClassStatus,
                 .makeCall,
                 .callStatus,
                 .payouts,
                 .replyQuestion,
                 .deleteCard,
                 .updateCard,
                 .addPrescriptions:
                return nil
            case .logout:
                UserPreference.shared.data = nil
                return nil
            case .notifications(_):
                return JSONHelper<CommonModel<NotificationData>>().getCodableModel(data: data)?.data
            case .chatListing(_):
                return JSONHelper<CommonModel<ChatData>>().getCodableModel(data: data)?.data
            case .chatMessages:
                return JSONHelper<CommonModel<MessagesData>>().getCodableModel(data: data)?.data
            case .vendorDetail(_):
                return JSONHelper<CommonModel<VendorDetailData>>().getCodableModel(data: data)?.data?.vendor_data
            case .getSlots:
                return JSONHelper<CommonModel<SlotsData>>().getCodableModel(data: data)?.data
            case .classes:
                return JSONHelper<CommonModel<ClassesData>>().getCodableModel(data: data)?.data
            case .revenue:
                return JSONHelper<CommonModel<RevenueData>>().getCodableModel(data: data)?.data
            case .appversion:
                let obj = JSONHelper<CommonModel<AppData>>().getCodableModel(data: data)?.data
                return obj
            case .pages:
                return JSONHelper<CommonModel<PagesData>>().getCodableModel(data: data)?.data?.pages
            case .addBank, .banks:
                return JSONHelper<CommonModel<BanksData>>().getCodableModel(data: data)?.data
            case .addMoney(_, _):
                return JSONHelper<CommonModel<StripeData>>().getCodableModel(data: data)?.data
            case .addCard, .cards:
                return JSONHelper<CommonModel<CardsData>>().getCodableModel(data: data)?.data
            case .getClientDetail(_):
                let obj = JSONHelper<CommonModel<ClientDetail>>().getCodableModel(data: data)?.data
                UserPreference.shared.clientDetail = obj
                return obj
            case .getAdditionalDetails,
                 .addAdditionalDetails:
                return JSONHelper<CommonModel<AdditionalDetailsData>>().getCodableModel(data: data)?.data
            case .addFeed:
                return JSONHelper<CommonModel<FeedsData>>().getCodableModel(data: data)?.data?.feed
            case .getFeeds,
                 .viewFeed,
                 .addFav:
                return JSONHelper<CommonModel<FeedsData>>().getCodableModel(data: data)?.data
            case .masterPreferences:
                let prefs = JSONHelper<CommonModel<MasterPreferences>>().getCodableModel(data: data)?.data?.preferences
                UserPreference.shared.masterPrefs = prefs
                return prefs
            case .getQuestions:
                return JSONHelper<CommonModel<QuestionsData>>().getCodableModel(data: data)?.data
            case .requestDetail:
                return JSONHelper<CommonModel<RequestData>>().getCodableModel(data: data)?.data?.request_detail
            case .addWaterLimit, .getWaterLimit, .drinkWater:
                return JSONHelper<CommonModel<WaterIntakeData>>().getCodableModel(data: data)?.data
            case .addProteinLimit, .getProteinLimit, .drinkProtein:
                return JSONHelper<CommonModel<WaterIntakeData>>().getCodableModel(data: data)?.data
            case .startCall, .startRequest:
                return JSONHelper<CommonModel<CallerData>>().getCodableModel(data: data)?.data
            case .extraPayment:
                return nil
            case .addMedicalHistory:
                return nil
            case .getMedicalHistory:
                return JSONHelper<CommonModel<MedicalHistoryData>>().getCodableModel(data: data)?.data
            #if NurseLynxExpert
            case .updateCarePlan:
                return nil
            #endif
            }
        case is Ep_Others:
            let endPoint = self as! Ep_Others
            switch endPoint {
            case .getContactList:
                return JSONHelper<CommonModel<ContactsData>>().getCodableModel(data: data)?.data
            case .getPendingRequests:
                return JSONHelper<CommonModel<PendingData>>().getCodableModel(data: data)?.data
            case .acceptRequest:
                return JSONHelper<CommonModel<RequestDetailData>>().getCodableModel(data: data)?.data
            case .contactMessage:
                return JSONHelper<CommonModel<SendEmergencyData>>().getCodableModel(data: data)?.data
                
            default:
                return nil

            }
        default:
            return nil
        }
        
    }
}
