//
//  RecieverDocCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 15/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
 
class RecieverDocCell: BaseChatCell {
    @IBOutlet weak var lblDocType: UILabel!
    
    override func setupData() {
        super.setupData()
        let obj = item?.property?.model
        lblTxt?.text = /obj?.imageUrl
        viewBack.roundCorners(with: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
        lblDocType.cornerRadius = 6.0
        lblDocType.clipsToBounds = true
        lblDocType.text = "   \(/obj?.messageType?.rawValue.uppercased())   "
        lblTxt?.isUserInteractionEnabled = true
        lblTxt?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(openDoc(gesture:))))
    }
    
    @objc func openDoc(gesture: UITapGestureRecognizer) {
        let webLinkVC = Storyboard<WebLinkVC>.Other.instantiateVC()
        webLinkVC.linkTitle = (Configuration.getValue(for: .APP_PDF) + /item?.property?.model?.imageUrl, VCLiteral.DOC_TITLE.localized)
        UIApplication.topVC()?.pushVC(webLinkVC)
    }
}
