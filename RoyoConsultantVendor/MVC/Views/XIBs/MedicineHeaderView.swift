//
//  MedicineHeaderView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 09/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class MedicineHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = DigitalPresHeaderFooterProvider

    @IBOutlet weak var lblTitle: UILabel!
    
    var item: DigitalPresHeaderFooterProvider? {
        didSet {
            
        }
    }
}

