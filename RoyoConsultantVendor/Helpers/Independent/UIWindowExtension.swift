//
//  UIWindowExtension.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 16/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

extension UIWindow {
    static var keyWindow: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    static func replaceRootVC(_ vc: UIViewController) {
        var window: UIWindow?
        if #available(iOS 13, *) {
            window = UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            window = UIApplication.shared.keyWindow
        }
        
        window?.rootViewController = vc
        window?.tintColor = ColorAsset.appTint.color
        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()
        UIView.transition(with: window!, duration: 0.4, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {
        }, completion: { _ in })
    }
}

struct ScreenSize {
  static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCALE = UIScreen.main.scale
}
