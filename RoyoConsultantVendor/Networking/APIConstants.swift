//
//  APIConstants.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 12/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

enum DynamicLinkPage: String {
    case Invite
}

internal struct APIConstants {
    static let login = "api/login"
    static let register = "api/register"
    static let profileUpdate = "api/profile-update"
    static let uploadImage = "api/upload-image"
    static let updatePhone = "api/update-phone"
    static let updateFCMId = "api/update-fcm-id"
    static let forgotPsw = "api/forgot_password"
    static let changePsw = "api/password-change"
    static let logout = "api/app_logout"
    static let sendOTP = "api/send-sms"
    static let categories = "api/categories"
    static let getFilters = "api/get-filters"
    static let services = "api/services"
    static let updateServices = "api/update-services"
    static let transactionHistory = "api/wallet-history-sp"
    static let wallet = "api/wallet-sp"
    static let requests = "api/requests"
    static let acceptRequest = "api/accept-request"
    static let cancelRequest = "api/cancel-request"
    static let notifications = "api/notifications"
    static let vendorDetail = "api/doctor-detail"
    static let getSlots = "api/get-slots"
    static let classes = "api/classes"
    static let updateClassStatus = "api/class/status"
    static let addClass = "api/add-class"
    static let revenue = "api/revenue"
    static let callStatus = "api/call-status"
    static let makeCall = "api/make-call"
    static let startRequest = "api/start-request"
    static let appVersion = "api/appversion"
    static let pages = "api/pages"
    static let addBank = "api/add-bank"
    static let banks = "api/bank-accounts"
    static let payouts = "api/payouts"
    static let addMoney = "api/add-money"
    static let addCard = "api/add-card"
    static let deleteCard = "api/delete-card"
    static let updateCard = "api/update-card"
    static let cards = "api/cards"
    static let clientDetail = "api/clientdetail"
    static let additionalDetails = "api/additional-details"
    static let additionalDetailData = "api/additional-detail-data"
    static let feeds = "api/feeds"
    static let addFav = "api/feeds/add-favorite"
    static let viewFeed = "api/feeds/view"
    static let addPrescription = "api/pre_screptions"
    static let masterPreferences = "api/master/preferences"
    static let askQuestions = "api/ask-questions"
    static let replyQuestion = "api/reply-question"
    static let pdf = "generate-pdf"
    static let requestDetail = "api/request-detail"
    static let waterLimit = "api/water-limit"
    static let drinkWater = "api/drink-water"
    static let proteinLimit = "api/protein-limit"
    static let drinkProtein = "api/drink-protein"
    static let extraPayment = "api/extra-payment"
    static let startCall = "api/start-call"
    static let createMedicalHistory = "api/create-medical-history"
    static let getMedicalHistory = "api/get-medical-history"
    static let sendEmailOTP = "api/send-email-otp"
    static let verifyEmail = "api/email-verify"
    #if NurseLynxExpert
    static let updateCarePlan = "api/update-care-plans"
    #endif
    //Chat
    static let chatListing = "api/chat-listing"
    static let chatMessages = "api/chat-messages"
    static let endChat = "api/complete-chat"
    static let startChat = "api/start-chat"
    
    //Other
    static let contactList = "api/contact-list"
    static let contactAdd = "api/contact-add"
    static let contactDelete = "api/contact-delete"
    static let contactMessage = "api/contact-message"

    static let termsConditions = "terms-conditions"
    static let privacyPolicy = "privacy-policy"
    
    static let acceptRequestV2 = "api/v2/accept-request"
    static let cancelRequestV2 = "api/v2/cancel-request"
    static let pendingRequest = "api/v2/pendig-requests"
}
