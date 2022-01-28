//
//  BaseChatCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 20/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import Lottie

class BaseChatCell: UITableViewCell, ReusableCell {
    
    typealias T = MessageProvider
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTxt: UILabel?
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewBack: UIView!
    
    lazy var uploadingAnimation: AnimationView = {
        let anView = AnimationView()
        anView.backgroundColor = UIColor.clear
        anView.animation = Animation.named(LottieFiles.Uploading.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        anView.loopMode = .loop
        anView.contentMode = .scaleAspectFit
        return anView
    }()
    
    lazy var errorAnimation: AnimationView = {
        let anView = AnimationView()
        anView.backgroundColor = UIColor.clear
        anView.animation = Animation.named(LottieFiles.Error.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        anView.loopMode = .playOnce
        anView.contentMode = .scaleAspectFit
        return anView
    }()
    
    var item: MessageProvider? {
        didSet {
            setupData()
        }
    }

    func setupData() {
        let obj = item?.property?.model
        lblTime.text = /Date.init(timeIntervalSince1970: /obj?.sentAt / 1000.0).toString(DateFormat.custom("h:mm a"), isForAPI: false)
        viewBack.layer.shadowColor = ColorAsset.shadow.color.cgColor
        viewBack.layer.shadowOffset = CGSize.init(width: 0, height: 1.2)
        viewBack.layer.shadowRadius = 1.0
        viewBack.layer.shadowOpacity = 1.0
    }
}
