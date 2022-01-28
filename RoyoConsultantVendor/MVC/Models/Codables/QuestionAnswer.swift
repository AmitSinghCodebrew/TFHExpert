//
//  QuestionAnswer.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/04/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import Foundation

class CarePlan: Codable {
    var id: Int?
    var title: String?
    var status: CarePlanStatus?

    init(_ _title: String?) {
        title = _title
    }
}

enum CarePlanStatus: String, Codable, CaseIterableDefaultsLast {
    case completed
    case pending

    var title: String {
        switch self {
        case .completed:
            return VCLiteral.COMPLETE.localized
        case .pending:
            return "Pending"
        }
    }
}


class QuestionAnswer: Codable {
    var question: String?
    var answer: String?
    var request_id: Int?
    var id: Int?

    init(_ _question: String?, _ _answer: String?) {
        question = _question
        answer = _answer
    }
}
