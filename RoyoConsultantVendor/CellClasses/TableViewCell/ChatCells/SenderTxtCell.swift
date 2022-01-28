//
//  SenderTxtCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 20/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class SenderTxtCell: BaseChatCell {

    @IBOutlet weak var btnStatus: UIButton!
    
    override func setupData() {
        super.setupData()
        let obj = item?.property?.model
        lblTxt?.text = /obj?.message
        viewBack.roundCorners(with: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
        btnStatus.isHidden = obj?.status?.statusImage == nil
        btnStatus.setImage(obj?.status?.statusImage, for: .normal)
        btnStatus.tintColor = obj?.status?.tintColor
    }
    
}
