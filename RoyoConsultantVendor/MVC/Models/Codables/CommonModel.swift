//
//  CommonModel.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

final class CommonModel<T: Codable>: Codable {
    var status: String?
    var statuscode: Int?
    var message: String?
    var data: T?
}

enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either where L == Double, R == String {
    var getDoubleValue: Double? {
        switch self {
        case .left(let doubleValue):
            return doubleValue
        case .right(let rightValue):
            return rightValue.toDouble()
        }
    }
}

extension Either: Decodable where L: Decodable, R: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let left = try? container.decode(L.self) {
            self = .left(left)
        } else if let right = try? container.decode(R.self) {
            self = .right(right)
        } else {
            throw DecodingError.typeMismatch(Either<L, R>.self, .init(codingPath: decoder.codingPath, debugDescription: "Expected either `\(L.self)` or `\(R.self)`"))
        }
    }
}

extension Either: Encodable where L: Encodable, R: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .left(left):
            try container.encode(left)
        case let .right(right):
            try container.encode(right)
        }
    }
}
