//
//  Configuration.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 17/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

import Foundation

enum Configuration {
    
    enum ConfigKey: String {
        case APP_CLIENT_ID
        case APP_IMAGE_THUMBS
        case APP_IMAGE_UPLOAD
        case APP_IMAGE_ORIGINAL
        case APP_BASE_PATH
        case APP_SOCKET_BASE_PATH
        case APP_JITSI_SERVER
        case APP_APPLE_APP_ID
        case APP_ANDROID_PACKAGE_NAME
        case APP_FIREBASE_PAGE_LINK
        case APP_BUNDLE_ID
        case APP_PROJECT_ID
        case APP_PLIST_NAME
        case APP_APP_NAME
        case APP_GOOGLE_PLACES_KEY
        case APP_PDF
        case APP_AUDIO
        case APP_LOCALIZABLE
        case RELATED_OTHER_APPLE_APP_ID
    }
    
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    private static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
    
    static func appName() -> String {
        return NSLocalizedString(getValue(for: .APP_APP_NAME), tableName: Configuration.getValue(for: .APP_LOCALIZABLE), comment: "")
    }
    
    static func getValue(for key: ConfigKey) -> String {
        return try! Configuration.value(for: key.rawValue)
    }
}

