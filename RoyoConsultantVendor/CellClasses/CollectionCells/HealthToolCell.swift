//
//  HealthToolCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 06/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HealthToolCell: UICollectionViewCell, ReusableCellCollection {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    var item: Any? {
        didSet {
            let obj = item as? HealthTool
            imgView.image = obj?.image
            lblTitle.text = /obj?.title?.localized
            lblSubTitle.text = /obj?.subtitle?.localized
        }
    }
   
}
