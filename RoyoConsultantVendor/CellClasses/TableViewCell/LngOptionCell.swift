//
//  GenderCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 26/10/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class LngOptionCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<FilterOption>
    
    @IBOutlet weak var lblTitle: UILabel!
    
    var item: DefaultCellModel<FilterOption>? {
        didSet {
            lblTitle.text = /item?.property?.model?.option_name
            lblTitle.textColor = /item?.property?.model?.isSelected ? ColorAsset.txtWhite.color : ColorAsset.txtMoreDark.color
            backgroundColor = /item?.property?.model?.isSelected ? ColorAsset.appTint.color : ColorAsset.backgroundCell.color
        }
    }
    
}
