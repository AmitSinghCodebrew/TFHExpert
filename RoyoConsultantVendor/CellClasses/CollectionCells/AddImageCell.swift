//
//  AddImageCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 08/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import Lottie

class AddImageCell: UICollectionViewCell, ReusableCellCollection {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewDelete: UIVisualEffectView!
    @IBOutlet weak var visualEffecVIewForLottie: UIVisualEffectView!
    @IBOutlet weak var btnDocImage: UIButton?

    public var didTapDelete: (() -> Void)?
    
    lazy var uploadingAnimation: AnimationView = {
        let anView = AnimationView()
        anView.backgroundColor = UIColor.clear
        anView.animation = Animation.named(LottieFiles.Uploading.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        anView.loopMode = .loop
        anView.animationSpeed = 2.0
        anView.contentMode = .scaleAspectFit
        return anView
    }()
    
    var item: Any? {
        didSet {
            let obj = item as? AddMedia
            if let tempIMage = obj?.url {
                viewDelete.isHidden = false
                imgView.setImageNuke(tempIMage)
            } else {
                viewDelete.isHidden = true
                imgView.image = nil
                uploadingAnimation.removeFromSuperview()
                visualEffecVIewForLottie.isHidden = true
            }
            
            if /obj?.isUploading {
                visualEffecVIewForLottie.isHidden = false
                uploadingAnimation.removeFromSuperview()
                uploadingAnimation.frame = visualEffecVIewForLottie.bounds
                visualEffecVIewForLottie.contentView.addSubview(uploadingAnimation)
                uploadingAnimation.play()
            } else {
                visualEffecVIewForLottie.isHidden = true
                uploadingAnimation.removeFromSuperview()
            }
            btnDocImage?.isHidden = !(obj?.type == .pdf)
        }
    }
    
    var media: MediaObj? {
        didSet {
            btnDocImage?.isHidden = !(media?.type == .pdf)
            imgView.setImageNuke(media?.image)
        }
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        didTapDelete?()
    }
}
