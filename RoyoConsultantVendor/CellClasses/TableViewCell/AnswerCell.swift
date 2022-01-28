//
//  AnswerCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 13/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AnswerCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<Answer>
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblComment: UILabel!
    
    var item: DefaultCellModel<Answer>? {
        didSet {
            imgView.setImageNuke(item?.property?.model?.user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            lblName.text = /item?.property?.model?.user?.name
            lblComment.text = /item?.property?.model?.answer
            let date = Date.init(fromString: /item?.property?.model?.created_at, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
            lblTime.text = /date.getChatTimeStamp()
        }
    }
}
