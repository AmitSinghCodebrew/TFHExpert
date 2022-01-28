//
//  ServiceRevenueCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 14/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ServiceRevenueCell: UICollectionViewCell, ReusableCellCollection {
    
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    
    var item: Any? {
        didSet {
            let obj = item as? RevenueService
            lblTotal.text = String(format: VCLiteral.TOTAL_SERVICES.localized, /obj?.service_name?.capitalizingFirstLetter())
            lblCount.text = "\(/obj?.count)"
            backGroundView.backgroundColor = UIColor.init(hex: /obj?.color_code)
        }
    }
}
