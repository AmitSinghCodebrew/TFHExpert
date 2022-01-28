//
//  SenderDocCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 15/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class SenderDocCell: BaseChatCell {
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblFileType: UILabel!
    
    var didTapUploadDocRetry: ((_ _message: Message?, _ _doc: Document?) -> Void)?

    
    override func setupData() {
        super.setupData()
        let obj = item?.property?.model
        lblTxt?.text = /obj?.imageUrl
        viewBack.roundCorners(with: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
        btnStatus.isHidden = obj?.status?.statusImage == nil
        btnStatus.setImage(obj?.status?.statusImage, for: .normal)
        btnStatus.tintColor = obj?.status?.tintColor
        lblFileType.cornerRadius = 6.0
        lblFileType.clipsToBounds = true
        lblFileType.text = "   \(/obj?.messageType?.rawValue.uppercased())   "
        lblTxt?.isUserInteractionEnabled = true
        lblTxt?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(openDoc(gesture:))))
    }
    
    @objc func openDoc(gesture: UITapGestureRecognizer) {
        switch item?.uploadStatus ?? .Default {
        case .UploadingFinished, .Default:
            let webLinkVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            webLinkVC.linkTitle = (Configuration.getValue(for: .APP_PDF) + /item?.property?.model?.imageUrl, VCLiteral.DOC_TITLE.localized)
            UIApplication.topVC()?.pushVC(webLinkVC)
        default:
            break
        }
    }
}
