//
//  MedicalHistoryHeaderView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 14/05/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class MedicalHistoryHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = MedicalHistoryHeaderFooterProvider

    @IBOutlet weak var backView: UIView! {
        didSet {
            backView.roundCorners(with: [.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 4)
        }
    }
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    var item: MedicalHistoryHeaderFooterProvider? {
        didSet {
            imgView.setImageNuke(item?.headerProperty?.model?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            lblName.text = /item?.headerProperty?.model?.name
            lblCategory.text = /item?.headerProperty?.model?.category
        }
    }
}
