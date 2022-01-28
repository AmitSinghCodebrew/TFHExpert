//
//  WeekDayCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class WeekDayCell: UICollectionViewCell, ReusableCellCollection {
        
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblDay: UILabel!

    var cornerRadiusForBackView: CGFloat = 0.0
    
    var item: Any? {
        didSet {
            let obj = item as? WeekdayOrDate
            backView.cornerRadius = cornerRadiusForBackView
            backView.borderWidth = 1.0
            lblDay.text = /obj?.weekDay
            lblDay.textColor = /obj?.isSelected ? ColorAsset.txtWhite.color : ColorAsset.txtMoreDark.color
            backView.borderColor = /obj?.isSelected ? ColorAsset.appTint.color : ColorAsset.txtMoreDark.color
            backView.backgroundColor = /obj?.isSelected ? ColorAsset.appTint.color : ColorAsset.backgroundColor.color
        }
    }
}
