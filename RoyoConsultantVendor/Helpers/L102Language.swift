//
//  L102Language.swift
//  Localization102
//
//  Created by Moath_Othman on 2/24/16.
//  Copyright © 2016 Moath_Othman. All rights reserved.
//

import UIKit

enum AppleLanguage: String {
    case English = "en"
    case Arabic = "ar"
    
    var title: VCLiteral {
        switch self {
        case .English:
            return .LANGUAGE_ENGLISH
        case .Arabic:
            return .LANGUAGE_ARABIC
        }
    }
    
    var locale: Locale {
        switch self {
        case .English:
            return Foundation.Locale(identifier: "en_US_POSIX")
        case .Arabic:
            return Foundation.Locale(identifier: "ar_SA")
        }
    }
}

// constants
let APPLE_LANGUAGE_KEY = "AppleLanguages"
/// L102Language
class L102Language {
    /// get current Apple language
    class func currentAppleLanguage() -> AppleLanguage? {
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
        let endIndex = current.startIndex
        let currentWithoutLocale = String(current[..<current.index(endIndex, offsetBy: 2)])
        //    let currentWithoutLocale = current.substring(to: current.index(endIndex, offsetBy: 2))
        return AppleLanguage.init(rawValue: currentWithoutLocale)
    }
    
    class func currentAppleLanguageFull() -> String {
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: APPLE_LANGUAGE_KEY) as! NSArray
        let current = langArray.firstObject as! String
        return current
    }

    /// set @lang to be the first in Applelanguages list
    class func setAppleLanguage(to language: AppleLanguage) {
        let userdef = UserDefaults.standard
        userdef.set([language.rawValue,currentAppleLanguage()?.rawValue ?? ""], forKey: APPLE_LANGUAGE_KEY)
        userdef.synchronize()
    }
    
    class var isRTL: Bool {
        return L102Language.currentAppleLanguage() == .Arabic
    }
}

/// Exchange the implementation of two methods for the same Class
func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    let origMethod: Method = class_getInstanceMethod(cls, originalSelector)!;
    let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector)!;
    if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}

extension Bundle {
    /**
     Custom method for localization
     - returns: we use localizedStringForKey:: method to return the localized method, note in swizzling we exchange the IMPlementation not the reference on the function, hence calling this method will use the original implementation of localizedStringForKey:: Method.
     */
    @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
        if self == Bundle.main {
            //we get the preferred language.(e.g. en)
            let currentLanguage = L102Language.currentAppleLanguage()
            var bundle = Bundle();
            
            //we check if there is a bundle for that language (e.g. en.lproj), if not we user Base.proj, and we get store a reference in bundle var.
            if let _path = Bundle.main.path(forResource: L102Language.currentAppleLanguageFull(), ofType: "lproj") {
                bundle = Bundle(path: _path)!
            }else
            if let _path = Bundle.main.path(forResource: currentLanguage?.rawValue ?? "", ofType: "lproj") {
                bundle = Bundle(path: _path)!
            } else {
                let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
                bundle = Bundle(path: _path)!
            }
            return (bundle.specialLocalizedStringForKey(key, value: value, table: tableName))
        } else {
            return (self.specialLocalizedStringForKey(key, value: value, table: tableName))
        }
    }
}

class L102Localizer: NSObject {
    /// Exchange the implementation of function localizedString:: and function specialLocalizedStringForKey:: in Bundle class
    class func DoTheMagic() {
        MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(_:value:table:)))
    }
}

extension UIImageView {
  func setRTLsupported(_ _image: UIImage) {
    if L102Language.isRTL {
      let flippedImage = UIImage.init(cgImage: _image.cgImage!, scale: _image.scale, orientation: UIImage.Orientation.upMirrored)
      self.image = flippedImage
    } else {
      self.image = _image
    }
  }
}

extension UIButton {
  func setRTLsupported(image: UIImage) {
    if L102Language.isRTL {
      let flippedImage = UIImage.init(cgImage: image.cgImage!, scale: image.scale, orientation: UIImage.Orientation.upMirrored)
      self.setImage(flippedImage, for: .normal)
    } else {
      self.setImage(image, for: .normal)
    }
  }
}


