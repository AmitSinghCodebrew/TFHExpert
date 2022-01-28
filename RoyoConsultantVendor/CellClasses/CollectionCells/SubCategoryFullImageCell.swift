//
//  SubCategoryFullImageCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class SubCategoryFullImageCell: UICollectionViewCell, ReusableCellCollection {
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
