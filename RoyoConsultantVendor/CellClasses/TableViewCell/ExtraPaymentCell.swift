//
//  ExtraPaymentCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 24/02/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class ExtraPaymentCell: UITableViewCell, ReusableCell {

    typealias T = AppDetailCellModel
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblAmountValue: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    var item: AppDetailCellModel? {
        didSet {
            lblAmount.text = VCLiteral.AMOUNT.localized
            lblAmountValue.text = /item?.property?.model?.request?.extra_payment?.balance?.getFormattedPrice()
            lblDesc.text = /item?.property?.model?.request?.extra_payment?.description
        }
    }
}
