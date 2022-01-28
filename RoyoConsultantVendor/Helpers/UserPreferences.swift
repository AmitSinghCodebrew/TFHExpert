//
//  UserPreferences.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit


class IQView: UIView {
    
}


final class UserPreference {
    
    private let DEFAULTS_KEY = "ROYO_CONSULTANT_APP_VENDOR"
    private let SETTINGS_KEY = "ROYO_CONSULTANT_APP_SETTINGS_VENDOR"
    private let MASTER_PREFERENCES_KEY = "MASTER_PREFERENCES_KEY"
    private let INTRO_SCREENS_KEY = "INTRO_SCREENS_KEY"
    private let LANAGUGE_SCREEN_KEY = "LANAGUGE_SCREEN_KEY"
    private let CHOOSE_APP_KEY =  "CHOOSE_APP_KEY"
    private let LOCATION_SCREEN_KEY = "LOCATION_SCREEN_KEY"

    static let shared = UserPreference()
    
    private init() {
        
    }
    
    var data : User? {
        get{
            return fetchData(key: DEFAULTS_KEY)
        }
        set{
            if let value = newValue {
                saveData(value, key: DEFAULTS_KEY)
            } else {
                removeData(key: DEFAULTS_KEY)
            }
        }
    }
    
    var clientDetail : ClientDetail? {
        get{
            return fetchData(key: SETTINGS_KEY)
        }
        set{
            if let value = newValue {
                saveData(value, key: SETTINGS_KEY)
            } else {
                removeData(key: SETTINGS_KEY)
            }
        }
    }
    
    var dateFormat: String {
        get {
            return "MMM dd, yyyy"
        }
    }
    
    var isGradientViews: Bool {
        get {
            #if TaraDocPro
            return true
            #else
            return false
            #endif
        }
    }
    
    var gradientColors: [UIColor] {
        get {
            #if TaraDocPro
            return [ColorAsset.Gradient0.color, ColorAsset.Gradient1.color]
            #else
            return []
            #endif
        }
    }
    
    var masterPrefs: [Filter]? {
        get {
            return fetchData(key: MASTER_PREFERENCES_KEY)
        }
        set {
            if let value = newValue {
                saveData(value, key: MASTER_PREFERENCES_KEY)
            } else {
                removeData(key: MASTER_PREFERENCES_KEY)
            }
        }
    }
    
    var isChooseAppScreenShown: Bool? {
        get {
            #if HealthCarePrashantExpert || HealExpert
            return fetchData(key: CHOOSE_APP_KEY)
            #else
            return true
            #endif
        }
        set {
            if let value = newValue {
                saveData(value, key: CHOOSE_APP_KEY)
            } else {
                removeData(key: CHOOSE_APP_KEY)
            }
        }
    }

    
    var isIntroScreensSeen: Bool? {
        get {
            #if HealthCarePrashantExpert || HealExpert
            return fetchData(key: INTRO_SCREENS_KEY)
            #else
            return true
            #endif
        }
        set {
            if let value = newValue {
                saveData(value, key: INTRO_SCREENS_KEY)
            } else {
                removeData(key: INTRO_SCREENS_KEY)
            }
        }
    }
    
    var isLocationScreenSeen: Bool? {
        get {
            #if HealthCarePrashantExpert || HealExpert || RoyoConsultExpert || TaraDocPro
            return fetchData(key: LOCATION_SCREEN_KEY)
            #else
            return true
            #endif
        }
        set {
            if let value = newValue {
                saveData(value, key: LOCATION_SCREEN_KEY)
            } else {
                removeData(key: LOCATION_SCREEN_KEY)
            }
        }
    }
    
    var isLanguageScreenShown: Bool? {
        get {
            #if HealExpert || HomeDoctorKhalidExperts
            return fetchData(key: LANAGUGE_SCREEN_KEY)
            #else
            return true
            #endif
        }
        set {
            if let value = newValue {
                saveData(value, key: LANAGUGE_SCREEN_KEY)
            } else {
                removeData(key: LANAGUGE_SCREEN_KEY)
            }
        }
    }
    
    public var firebaseToken: String?
    
    public var pages: [Page]?
    
    public var socialLoginData: GoogleAppleFBUserData?
    
    public func getCurrencyAbbr() -> String {
        let localeID = Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue : /UserPreference.shared.clientDetail?.currency])
        let locale = Locale.init(identifier: localeID)
        return /locale.currencySymbol
    }
    
    //MARK:- Generic function used anywhere directly copy it
    private func saveData<T: Codable>(_ value: T, key: String) {
        
        guard let data = JSONHelper<T>().getData(model: value) else {
            removeData(key: key)
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    private func fetchData<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return JSONHelper<T>().getCodableModel(data: data)
    }
    
    private func removeData(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
