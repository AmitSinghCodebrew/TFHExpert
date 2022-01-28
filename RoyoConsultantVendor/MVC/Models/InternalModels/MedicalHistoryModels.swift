//
//  MedicalHistoryModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 14/05/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class MedicalHistoryHeaderFooterProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = MedicalHistoryProvider
    
    typealias HeaderModelType = User
    
    typealias FooterModelType = Any
    
    var headerProperty: HeaderProperty?
    
    var footerProperty: FooterProperty?
    
    var items: [MedicalHistoryProvider]?
    
    required init(_ _header: HeaderProperty?, _ _footer: FooterProperty?, _ _items: [MedicalHistoryProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getArray(doctors: [User]?) -> [MedicalHistoryHeaderFooterProvider] {
        
        var items = [MedicalHistoryHeaderFooterProvider]()
        
        doctors?.forEach({ doctor in
            var cells = [MedicalHistoryProvider]()
            doctor.medical_history?.forEach({ history in
                cells.append(MedicalHistoryProvider.init((MedicalHIstoryDescCell.identfier, UITableView.automaticDimension, history), nil, nil))
            })
            items.append(MedicalHistoryHeaderFooterProvider.init((MedicalHistoryHeaderView.identfier, 94, doctor), (MedicalHistoryFooterView.identfier, 24, ""), cells))
        })

        return items
    }
}


class MedicalHistoryProvider: CellModelProvider {
    
    typealias CellModelType = MedicalHistory

    var property: Property?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: Property?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}
