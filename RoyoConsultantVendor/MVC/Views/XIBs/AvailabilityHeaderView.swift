//
//  AvailabilityHeaderView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AvailabilityHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = AvailibilityHeaderFooterProvider
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var item: AvailibilityHeaderFooterProvider? {
        didSet {
            lblTitle.text = /item?.headerProperty?.model?.title
        }
    }
    
}
