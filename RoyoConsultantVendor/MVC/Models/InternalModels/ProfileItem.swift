//
//  ProfileItem.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ProfileItem {
    var title: VCLiteral?
    var image: UIImage?
    var page: Page?

    init(_ _title: VCLiteral, _ _image: UIImage?) {
        title = _title
        image = _image
    }
    
    init(_ _page: Page?, _image: UIImage?) {
        page = _page
        image = _image
    }
    
    class func getItems(pages: [Page]?) -> [ProfileItem] {
        
//        ProfileItem.init(.CONTACT_US, #imageLiteral(resourceName: "ic_contact_drawer")),
//        ProfileItem.init(.TERMS_AND_CONDITIONS, #imageLiteral(resourceName: "ic_terms")),
//        ProfileItem.init(.ABOUT, #imageLiteral(resourceName: "ic_info")),
        
        var items = [ProfileItem.init(.ACCOUNT_SETTINGS, #imageLiteral(resourceName: "ic_setting")),
                     ProfileItem.init(.CHANGE_PASSWORD, #imageLiteral(resourceName: "ic_password")),
                     ProfileItem.init(.CHANGE_LANGUAGE, #imageLiteral(resourceName: "ic_language")),
                     ProfileItem.init(.CHAT, #imageLiteral(resourceName: "ic_chat_profile")),
                     ProfileItem.init(.HISTORY, #imageLiteral(resourceName: "ic_history")),
                     ProfileItem.init(.FREE_EXPERT_ADVICE, #imageLiteral(resourceName: "ic_class_profile")),
                     ProfileItem.init(.CLASSES, #imageLiteral(resourceName: "ic_class_profile")),
                     ProfileItem.init(.NOTIFICATIONS, #imageLiteral(resourceName: "ic_notification_drawer")),
                     ProfileItem.init(.INVITE_PEOPLE, #imageLiteral(resourceName: "ic_invite_drawer"))]
        
        pages?.forEach({ items.append(ProfileItem.init($0, _image: #imageLiteral(resourceName: "ic_info")))})
        #if NurseLynxExpert
        items.insert(ProfileItem.init(.EMERGENCY_CONTACTS, #imageLiteral(resourceName: "contacts")), at: 1)
        
        #endif
        
        if UserPreference.shared.data?.provider_type != .email {
            items.removeAll(where: {$0.title == .CHANGE_PASSWORD})
        }
        
        #if HomeDoctorKhalidExperts
        items.insert(ProfileItem.init(.BANK_DETAILS, #imageLiteral(resourceName: "ic_bank")), at: 1)

        items.removeAll(where: {$0.title == .CLASSES || $0.title == .FREE_EXPERT_ADVICE})
        #elseif HealthCarePrashantExpert
        items.removeAll { (item) -> Bool in
            return (item.title == .CLASSES) || (item.title == .FREE_EXPERT_ADVICE) || (item.title == .HISTORY) || (item.title == .CHANGE_LANGUAGE)
        }
        items.insert(ProfileItem.init(.SECOND_OPINION, #imageLiteral(resourceName: "ic_class_profile")), at: 1)
        #elseif NurseLynxExpert
        items.removeAll { (item) -> Bool in
            return (item.title == .CLASSES) || (item.title == .FREE_EXPERT_ADVICE) || (item.title == .CHANGE_LANGUAGE)
        }
        #elseif RoyoConsultExpert
        #elseif CloudDocPro
        items.removeAll(where: { $0.title == .CHANGE_LANGUAGE || $0.title == .CLASSES || $0.title == .FREE_EXPERT_ADVICE })

        #else
        items.removeAll(where: {$0.title == .FREE_EXPERT_ADVICE})
        #endif
        
        if /UserPreference.shared.clientDetail?.support_url != "" {
            items.append(ProfileItem.init(.SUPPORT, #imageLiteral(resourceName: "ic_info")))
        }
        
        return items + [ProfileItem.init(.LOGOUT, #imageLiteral(resourceName: "ic_logout"))]
    }

}
