//
//  Intro.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 27/10/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class Intro {
    var image: UIImage?
    var title: String?
    var description: String?
    
    init(_ _image: UIImage, _ _title: VCLiteral, _ _desc: VCLiteral) {
        image = _image
        title = _title.localized
        description = _desc.localized
    }
    
    class func getArray() -> [Intro] {
        #if HealthCarePrashantExpert
        return [Intro(#imageLiteral(resourceName: "ic_intro_1"), .INTRO_1_TITLE, .INTRO_1_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_2"), .INTRO_2_TITLE, .INTRO_2_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_3"), .INTRO_3_TITLE, .INTRO_3_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_4"), .INTRO_4_TITLE, .INTRO_4_DESC)]
        #elseif HealExpert
        return [Intro(#imageLiteral(resourceName: "ic_intro_1"), .INTRO_1_TITLE, .INTRO_1_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_2"), .INTRO_2_TITLE, .INTRO_2_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_3"), .INTRO_3_TITLE, .INTRO_3_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_4"), .INTRO_4_TITLE, .INTRO_4_DESC),
                Intro(#imageLiteral(resourceName: "ic_intro_5"), .INTRO_5_TITLE, .INTRO_5_DESC)]
        #elseif RoyoConsultExpert
        return [Intro(UIImage(), .INTRO_1_TITLE, .INTRO_1_DESC),
                Intro(UIImage(), .INTRO_2_TITLE, .INTRO_2_DESC),
                Intro(UIImage(), .INTRO_3_TITLE, .INTRO_3_DESC),
                Intro(UIImage(), .INTRO_4_TITLE, .INTRO_4_DESC),
                Intro(UIImage(), .INTRO_5_TITLE, .INTRO_5_DESC)]
        #else
        return []
        #endif
    }
}
