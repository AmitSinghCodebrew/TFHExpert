//
//  IntroCell.swift
//  RoyoConsult
//
//  Created by Sandeep Kumar on 01/10/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class IntroCell: UICollectionViewCell, ReusableCellCollection {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var item: Any? {
        didSet {
            imgView.image = (item as? Intro)?.image
        }
    }
}
