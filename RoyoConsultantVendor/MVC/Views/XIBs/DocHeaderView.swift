//
//  DocHeaderView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 04/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class DocHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = DocHeaderProvider
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    var didTapAdd: (() -> Void)?
    
    var item: DocHeaderProvider? {
        didSet {
            lblTitle.text = /item?.headerProperty?.model?.name
            btnAdd.setTitle(VCLiteral.ADD.localized, for: .normal)
        }
    }
    
    
    @IBAction func btnAddAction(_ sender: Any) {
        didTapAdd?()
    }
    
}
