//
//  MedicalHistoryFooterView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 14/05/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class MedicalHistoryFooterView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    typealias T = MedicalHistoryHeaderFooterProvider
    
    @IBOutlet weak var backView: UIView! {
        didSet {
            backView.roundCorners(with: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 4)
        }
    }

    var item: MedicalHistoryHeaderFooterProvider? {
        didSet {
            
        }
    }
}
