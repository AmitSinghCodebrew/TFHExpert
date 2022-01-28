//
//  RemotePush.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 15/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class RemotePush: Codable {
    var messageType: String?
    var sentAt: String?
    var googleCAE: String?
    var receiverId: String?
    var message: String?
    var request_id: String?
    var aps: APS?
    var senderName: String?
    var senderId: String?
    var googleCSenderId: String?
    var call_id: String?
    var pushType: PushType?
    
    private enum CodingKeys: String, CodingKey {
        case googleCAE = "google.c.a.e"
        case googleCSenderId = "google.c.sender.id"
        case messageType
        case sentAt
        case receiverId
        case message
        case request_id
        case aps
        case senderName
        case senderId
        case pushType
        case call_id
    }
}

final class APS: Codable {
    var alert: AlertNotification?
    var badge: Int?
    var sound: String?
}

final class AlertNotification: Codable {
    var body: String?
    var title: String?
}

enum PushType: String, CaseIterableDefaultsLast, Codable {
    case NEW_REQUEST
    case chat
    case AMOUNT_RECEIVED
    case REQUEST_COMPLETED
    case ASSINGED_USER
    case CALL_CANCELED
    case CALL_ACCEPTED
    case CALL_RINGING
    case PAYOUT_PROCESSED
    case PAYOUT_FAILED
    case BALANCE_ADDED
    case BALANCE_FAILED
    case CANCELED_REQUEST
    case REQUEST_FAILED
    case RESCHEDULED_REQUEST
    case PROFILE_APPROVED
    case UPCOMING_APPOINTMENT
    case PATIENT_ADDED_SYMPTOMS
    case PAID_EXTRA_PAYMENT
    case USER_AVAILABLE
    case REQUEST_EXTRA_PAYMENT
    case BOOKING_REQUEST
    case PROFILE_REJECTED
    case DOCUMENT_REJECTED
    
    case UNKNOWN
}

