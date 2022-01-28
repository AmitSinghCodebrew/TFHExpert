//
//  DocumentCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 04/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
enum DocCellBtnType {
    case Delete
    case Edit
}

class DocumentCell: UITableViewCell, ReusableCell {
    
    typealias T = DocCellProvider

    @IBOutlet weak var lblDocTitle: UILabel!
    @IBOutlet weak var lblDocDesc: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    var didTapFor: ((_ _type: DocCellBtnType) -> Void)?
    
    var item: DocCellProvider? {
        didSet {
            lblDocTitle.text = /item?.property?.model?.title
            lblDocDesc.text = /item?.property?.model?.description
            imgView.backgroundColor = ColorAsset.appTint.color
            imgView.setImageNuke(/item?.property?.model?.file_name)
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Delete
            didTapFor?(.Delete)
        case 1: //Edit
            didTapFor?(.Edit)
        default:
            break
        }
    }
    
}
