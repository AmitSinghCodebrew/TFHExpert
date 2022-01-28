//
//  QuestionAnswerCell.swift
//  CloudDocPro
//
//  Created by Sandeep Kumar on 19/04/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit


class QuestionAnswerCell: UITableViewCell, ReusableCell {
    typealias T = AppDetailCellModel
    
    @IBOutlet weak var lblText: UILabel!
    
    var item: AppDetailCellModel? {
        didSet {
            lblText.text = "\(/item?.property?.model?.index). \(/item?.property?.model?.questionAnswer?.question)\n\(String.init(format: VCLiteral.ANSWER_SHORT.localized, /item?.property?.model?.questionAnswer?.answer))"
        }
    }
    
}
