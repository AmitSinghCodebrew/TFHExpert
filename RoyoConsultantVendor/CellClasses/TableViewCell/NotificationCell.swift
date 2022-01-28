//
//  NotificationCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<NotificationModel>
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    var item: DefaultCellModel<NotificationModel>? {
        didSet {
            let obj = item?.property?.model
            lblTitle.text = /obj?.message
            imgView.setImageNuke(/obj?.form_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            lblTitle.setAtrributedText(original: (/obj?.message, Fonts.CamptonBook.ofSize(14.0), ColorAsset.txtMoreDark.color), toReplace: (/obj?.form_user?.name, Fonts.CamptonSemiBold.ofSize(14.0), ColorAsset.txtMoreDark.color))
            lblTime.text = /Date.init(timeIntervalSince1970: /obj?.sentAt / 1000.0).relativeTimeToString()
        }
    }
}
