//
//  TransactionCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<Payment>
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblFromTo: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblFailedMessage: UILabel!
    
    var item: DefaultCellModel<Payment>? {
        didSet {
            let obj = item?.property?.model
            lblFromTo.text = /obj?.type?.transactionText.localized
            let transactionDate = Date.init(fromString: /obj?.created_at, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
            lblDate.text = /transactionDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false)
            lblTime.text = /transactionDate.toString(DateFormat.custom("hh:mm a"), isForAPI: false)
            let amount = /obj?.amount?.getFormattedPrice()
            lblFailedMessage.text = /obj?.payout_message
            
            if /obj?.status == "failed" {
                lblFromTo.textColor = ColorAsset.requestStatusFailed.color
                lblName.textColor = ColorAsset.requestStatusFailed.color
                lblFailedMessage.textColor = ColorAsset.requestStatusFailed.color
            } else {
                lblFromTo.textColor = ColorAsset.txtGrey.color
                lblName.textColor = ColorAsset.txtGrey.color
                lblFailedMessage.textColor = ColorAsset.txtGrey.color
            }
            
            switch obj?.type ?? .all {
            case .withdrawal:
                lblAmount.text = "-\(amount)"
                lblName.text = /obj?.from?.name
            case .payouts:
                lblAmount.text = "-\(amount)"
                lblName.text = "(\(/obj?.status?.capitalizingFirstLetter()))"
            case .deposit:
                lblName.text = /obj?.from?.name
                lblAmount.text = "+\(amount)"
            case .add_money:
                lblName.text = ""
                lblAmount.text = "+\(amount)"
            case .all:
                lblName.text = /obj?.from?.name
                lblAmount.text = "+\(amount)"
            }
        }
    }
    
}
