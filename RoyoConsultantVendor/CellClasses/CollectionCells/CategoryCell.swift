//
//  CategoryCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell, ReusableCellCollection {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewLeft: UIImageView!
    
    var imageSize: CGSize?
    
    var item: Any? {
        didSet {
            let obj = item as? Category
            backGroundView.backgroundColor = UIColor.init(hex: /obj?.color_code?.lowercased())
            #if TaraDocPro
            lblTitle.textColor = ColorAsset.txtMoreDark.color
            #else
            lblTitle.textColor = ColorAsset.txtWhite.color
            #endif
            
            #if HealthCarePrashantExpert || HealExpert
            lblTitle.text = /obj?.name
            imgViewLeft.setCategoryImage(imageOrURL: /obj?.image, size: imageSize ?? CGSize.zero, contentMode: .bottomLeft)
            imgViewLeft.isHidden = false
            imgView.isHidden = true
            lblTitle.textAlignment = .right
            #else
            lblTitle.text = /obj?.name
            imgView.setCategoryImage(imageOrURL: /obj?.image, size: imageSize ?? CGSize.zero, contentMode: .bottomRight)
            imgViewLeft.isHidden = true
            imgView.isHidden = false
            lblTitle.textAlignment = .left
            #endif
        }
    }
    
}
