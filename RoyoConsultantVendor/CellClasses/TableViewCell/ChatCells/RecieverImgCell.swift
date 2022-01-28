//
//  RecieverImgCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 20/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class RecieverImgCell: BaseChatCell {
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var viewTimeSubView: UIView!
    
    override func setupData() {
        super.setupData()
        let obj = item?.property?.model
        imgView.setImageNuke(/obj?.imageUrl, placeHolder: nil)
        viewBack.roundCorners(with: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
        imgView.roundCorners(with: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 16.0)
        imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(openImage)))
        viewTime.roundCorners(with: [.layerMinXMaxYCorner], radius: 16.0)
        viewTimeSubView.roundCorners(with: [.layerMaxXMinYCorner], radius: 8.0)
    }
    
    @objc private func openImage() {
        let destVC = Storyboard<MediaPreviewVC>.Other.instantiateVC()
        destVC.item = ([MediaObj.init(item?.property?.model?.imageUrl, .image)], 0)
        UIApplication.topVC()?.pushVC(destVC)
    }
}
