//
//  BlogDetailCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class BlogDetailCell: UITableViewCell, ReusableCell {
    typealias T = DefaultCellModel<Feed>
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    var item: DefaultCellModel<Feed>? {
        didSet {
            lblTitle.text = /item?.property?.model?.title
            lblDesc.text = /item?.property?.model?.description
        }
    }
}
