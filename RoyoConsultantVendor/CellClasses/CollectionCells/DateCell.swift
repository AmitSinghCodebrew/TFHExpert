//
//  DateCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class DateCell: UICollectionViewCell, ReusableCellCollection {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    var item: Any? {
        didSet {
            let obj = item as? WeekdayOrDate
            backView.backgroundColor = /obj?.isSelected ? ColorAsset.appTint.color : ColorAsset.backgroundColor.color
            backView.cornerRadius = 4.0
            backView.clipsToBounds = true
            backView.borderColor = /obj?.isSelected ? ColorAsset.appTint.color : ColorAsset.txtExtraLight.color
            backView.borderWidth = 1.0
            lblDay.textColor = /obj?.isSelected ? ColorAsset.txtWhite.color : ColorAsset.txtExtraLight.color
            lblDate.textColor = /obj?.isSelected ? ColorAsset.txtWhite.color : ColorAsset.txtMoreDark.color
            lblDay.text = /obj?.date?.weekdayToString()
            lblDate.text = /obj?.date?.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false)
        }
    }
    
}
