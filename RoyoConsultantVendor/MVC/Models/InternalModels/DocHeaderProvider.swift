//
//  DocModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 04/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class DocHeaderProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = DocCellProvider
    
    typealias HeaderModelType = AdditionalDetail
    
    typealias FooterModelType = Any
    
    var headerProperty: HeaderProperty?
    
    var footerProperty: FooterProperty?
    
    var items: [DocCellProvider]?
    
    required init(_ _header: HeaderProperty?, _ _footer: FooterProperty?, _ _items: [DocCellProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getSectionWiseData(_ array: [AdditionalDetail]?) -> [DocHeaderProvider] {
        
        var sections = [DocHeaderProvider]()
        array?.forEach({ (detail) in
            
            var cells = [DocCellProvider]()
            
            
            detail.documents?.forEach({
                cells.append(DocCellProvider.init((DocumentCell.identfier, UITableView.automaticDimension, $0), nil, nil))
            })
            
            sections.append(DocHeaderProvider.init((DocHeaderView.identfier, 40.0, detail), nil, cells))
        })
        
        return sections
    }
}


class DocCellProvider: CellModelProvider {
    
    typealias CellModelType = Doc

    var property: Property?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: Property?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}
