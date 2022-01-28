//
//  Gender.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 09/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

class Gender: SKGenericPickerModelProtocol {
    
    typealias ModelType = VCLiteral

    var title: String?
    
    var model: VCLiteral?
    
    required init(_ _title: String?, _ _model: VCLiteral?) {
        title = _title
        model = _model
    }
    
    class func getGenders() -> [Gender] {
        return [Gender(VCLiteral.MALE.localized, .MALE),
                Gender(VCLiteral.FEMALE.localized, .FEMALE)]
    }
}
