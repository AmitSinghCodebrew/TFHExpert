//
//  FilterXIBCell.swift
//  RoyoConsultantExpert
//
//  Created by Sandeep Kumar on 28/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class FilterXIBCell: UICollectionViewCell, ReusableCellCollection {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblText: UILabel!
    
    var item: Any? {
        didSet {
            let obj = item as? Service
            lblText.text = /obj?.service_name?.capitalizingFirstLetter()
            backView.borderWidth = 1.0
            backView.borderColor = /obj?.isSelected ? ColorAsset.txtTheme.color : ColorAsset.btnBorder.color
            backView.backgroundColor = /obj?.isSelected ? ColorAsset.txtTheme.color : ColorAsset.backgroundCell.color
            lblText.textColor = /obj?.isSelected ? ColorAsset.txtWhite.color : ColorAsset.txtExtraLight.color
        }
    }

}
