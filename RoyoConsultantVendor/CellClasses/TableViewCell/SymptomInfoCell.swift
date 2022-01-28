//
//  SymptomInfoCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class SymptomInfoCell: UITableViewCell, ReusableCell {
    
    @IBOutlet weak var lblDesc: UILabel!
    
    typealias T = AppDetailCellModel

    var item: AppDetailCellModel? {
        didSet {
            lblDesc.text = /item?.property?.model?.request?.symptom_details
        }
    }
}

