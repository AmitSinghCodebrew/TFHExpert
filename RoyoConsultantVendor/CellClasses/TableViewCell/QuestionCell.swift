//
//  QuestionCell.swift
//  RoyoConsultantExpert
//
//  Created by Sandeep Kumar on 12/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<Question>

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblQuestion: UILabel!
    
    var item: DefaultCellModel<Question>? {
        didSet {
            imgView.setImageNuke(item?.property?.model?.created_by?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            lblName.text = /item?.property?.model?.created_by?.name
            lblQuestion.text = /item?.property?.model?.title
        }
    }

}
