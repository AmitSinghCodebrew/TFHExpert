//
//  ImageCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 02/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell, ReusableCellCollection {

    @IBOutlet weak var imgView: UIImageView!
    
    var item: Any? {
        didSet {
            imgView.setImageNuke(item)
        }
    }
}
