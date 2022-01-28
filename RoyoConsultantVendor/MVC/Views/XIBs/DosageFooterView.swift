//
//  DosageFooterView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 09/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class DosageFooterView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = DigitalPresHeaderFooterProvider

    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    var didTapAdd: (() -> Void)?
    var didReset: (() -> Void)?
    
    var item: DigitalPresHeaderFooterProvider? {
        didSet {
            btnAdd.setTitle(/item?.footerProperty?.model?.addTitle?.localized, for: .normal)
            btnReset.setTitle(/item?.footerProperty?.model?.resetTitle?.localized, for: .normal)
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Add
            didTapAdd?()
        case 1: //Reset
            didReset?()
        default:
            break
        }
    }
}
