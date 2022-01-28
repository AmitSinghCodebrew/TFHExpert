//
//  LottieFiles.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 17/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

enum LottieFiles: String {
    case NextAccessory
    case Dots
    case Uploading
    case Error
    case ErrorEmoji
    case BtnWhiteLoader
    case BtnAppTintLoader
    case LineProgress
    case DeleteAudio
    case PregnantWomen
    
    func getFileName() -> String {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark ? getDarkModeFiles() : getLightModeFiles()
        } else {
            return getLightModeFiles()
        }
    }
    
    private func getLightModeFiles() -> String {
        switch self {
        case .NextAccessory:
            return "BaloonLight"
        case .Dots:
            return "DotsLight"
        case .Uploading:
            return "Uploading"
        case .Error:
            return "Error"
        case .ErrorEmoji:
            return "ErrorEmoji"
        case .BtnWhiteLoader:
            return "BtnWhiteLoader"
        case .BtnAppTintLoader:
            return "BtnAppTintLoader"
        case .LineProgress:
            return "LineProgress"
        case .DeleteAudio:
            return "DeleteAudio"
        case .PregnantWomen:
            return "PregnantWomen"
        }
    }
    
    private func getDarkModeFiles() -> String {
        switch self {
        case .NextAccessory:
            return "BaloonDark"
        case .Dots:
            return "DotsDark"
        case .Uploading:
            return "Uploading"
        case .Error:
            return "Error"
        case .ErrorEmoji:
            return "ErrorEmoji"
        case .BtnWhiteLoader:
            return "BtnWhiteLoader"
        case .BtnAppTintLoader:
            return "BtnAppTintLoader"
        case .LineProgress:
            return "LineProgress"
        case .DeleteAudio:
            return "DeleteAudio"
        case .PregnantWomen:
            return "PregnantWomen"
        }
    }
    
}
