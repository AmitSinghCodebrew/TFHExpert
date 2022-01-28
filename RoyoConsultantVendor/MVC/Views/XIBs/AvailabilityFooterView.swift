//
//  AvailabilityFooterView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AvailabilityFooterView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = AvailibilityHeaderFooterProvider
    
    @IBOutlet weak var btnAdd: UIButton!
    
    var didTapAdd: (() -> Void)?
    
    var item: AvailibilityHeaderFooterProvider? {
        didSet {
            btnAdd.setTitle(/item?.footerProperty?.model?.btnTitle, for: .normal)
        }
    }
    
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        didTapAdd?()
    }
}
