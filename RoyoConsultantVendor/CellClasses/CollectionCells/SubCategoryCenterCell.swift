//
//  SubCategoryCenterCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 29/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class SubCategoryCenterCell: UICollectionViewCell, ReusableCellCollection {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var item: Any? {
        didSet {
            let obj = item as? Category
            lblTitle.text = /obj?.name
            imgView.setImageNuke(/obj?.image, placeHolder: #imageLiteral(resourceName: "ic_category"))
        }
    }
}
