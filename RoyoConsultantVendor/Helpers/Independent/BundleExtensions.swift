//
//  BundleExtensions.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 14/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        let versionInPoints = infoDictionary?["CFBundleShortVersionString"] as! String
        return versionInPoints
    }

    var versionDecimalScrapped: String {
        return versionNumber.components(separatedBy: ".").joined()
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

}
