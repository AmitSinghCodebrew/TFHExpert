//
//  RecieverTxtCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 20/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class RecieverTxtCell: BaseChatCell {

  override func setupData() {
      super.setupData()
      let obj = item?.property?.model
      lblTxt?.text = /obj?.message
      viewBack.roundCorners(with: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
  }

}
