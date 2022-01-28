//
//  MedicineCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 09/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class MedicineCell: UITableViewCell, ReusableCell {
    
    typealias T = DigitalPresCellProvider

    @IBOutlet weak var lblMedicineName: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    var didTapEdit: (() -> Void)?
    var didTapDelete: (() -> Void)?
    
    var item: DigitalPresCellProvider? {
        didSet {
            lblMedicineName.text = /item?.property?.model?.prescription?.medicine_name
            lblInfo.text = "\(VCLiteral.DURATION.localized): \(/item?.property?.model?.prescription?.duration)\n\(VCLiteral.DOSAGE_TYPE.localized): \(/item?.property?.model?.prescription?.dosage_type)"
        }
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        didTapDelete?()
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        didTapEdit?()
    }
}
