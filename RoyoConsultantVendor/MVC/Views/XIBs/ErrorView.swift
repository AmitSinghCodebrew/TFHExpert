//
//  ErrorView.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 22/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import Lottie

enum NoDataType {
    case NoRequests
    case AccountNotApproved
    case AccountRejected
    case NoTransactions
    case NoChats
    case NoClasses
    case NoNotifications
    case NoQuestions
    case NoHistory
    case NoArticles
    case NoBlogs
    case NoMedicalHistory
    case NoContacts
    
    var property: (mainTitle: VCLiteral, desc: VCLiteral, img: UIImage) {
        switch self {
        case .NoRequests:
            return (.NO_REQUESTS, .NO_REQUESTS_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))
        case .AccountNotApproved:
            return (.ACCOUNT_NOT_APPROVED, .ACCOUNT_NOT_APPROVED_DESC, #imageLiteral(resourceName: "ic_profile_empty_state"))
        case .AccountRejected:
            return (.ACCOUNT_NOT_APPROVED, .ACCOUNT_REJECTED_DESC, #imageLiteral(resourceName: "ic_profile_empty_state"))
        case .NoTransactions:
            return (.WALLET_NO_DATA, .WALLET_NO_DATA_DESC, #imageLiteral(resourceName: "ic_wallet_empty"))
        case .NoChats:
            return (.CHAT_NO_DATA, .CHAT_NO_DATA_DESC, #imageLiteral(resourceName: "ic_chat_empty"))
        case .NoClasses:
            return (.NO_CLASSES_DATA, .NO_CLASSES_DATA_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))
        case .NoNotifications:
            return (.NOTIFICATION_NO_DATA, .NOTIFICATION_NO_DATA_DESC, #imageLiteral(resourceName: "ic_notifications_empty"))
        case .NoQuestions:
            return (.NO_QUESTIONS, .NO_QUESTIONS_DESC, #imageLiteral(resourceName: "ic_profile_empty_state"))
        case .NoHistory:
            return (.NO_HISTORY, .NO_HISTORY_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))
        case .NoArticles:
            return (.NO_ARTICLES, .NO_ARTICLES_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))
        case .NoBlogs:
            return (.NO_BLOGS, .NO_BLOGS_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))
        case .NoMedicalHistory:
            return (.NO_MEDICAL_HISTORY, .NO_MEDICAL_HISTORY_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))
        case .NoContacts:
            return (.NO_CONTACT, .NO_CONTACT_DESC, #imageLiteral(resourceName: "ic_requests_empty_state"))

        }
    }
}

class ErrorView: UIView {
    @IBOutlet weak var lottieView: UIView!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    private var btnTapped: (() -> Void)?
    private let animationView = AnimationView()
    
    private lazy var uploadingAnimation: AnimationView = {
        let anView = AnimationView()
        anView.backgroundColor = UIColor.clear
        anView.animation = Animation.named(LottieFiles.Uploading.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        anView.loopMode = .loop
        anView.contentMode = .scaleAspectFit
        return anView
    }()
    
    
    @IBAction func btnAction(_ sender: UIButton) {
        animationView.stop()
        animationView.removeFromSuperview()
        btnTapped?()
    }
    
    public func showNoDataWithImage(type: NoDataType) {
        btn.isHidden = true
        lottieView.isHidden = true
        imgView.isHidden = false
        lblText.isHidden = false
        lblTitle.isHidden = false
        lblTitle.text = type.property.mainTitle.localized
        lblText.text = type.property.desc.localized
        imgView.image = type.property.img
    }
    
    public func showNoDataWithImageCustomMessage(type: NoDataType, Message : String) {
        btn.isHidden = true
        lottieView.isHidden = true
        imgView.isHidden = false
        lblText.isHidden = false
        lblTitle.isHidden = false
        lblTitle.text = type.property.mainTitle.localized
        lblText.text =  Message
        imgView.image = type.property.img
    }
    
    
    public func handleErrorView(animation: LottieFiles, text: String?, btnTitle: String?, _btnTapped: (() -> Void)?) {
        lottieView.isHidden = false
        lblText.isHidden = false
        btn.isHidden = false
        lblTitle.isHidden = false
        imgView.isHidden = true
        
        btnTapped = _btnTapped
        lblText.text = /text
        btn.setTitle(/btnTitle, for: .normal)
        lottieView.backgroundColor = UIColor.clear
        lblTitle.text = VCLiteral.NETWORK_ERROR.localized
        
        lottieView.subviews.forEach({
            $0.removeFromSuperview()
        })
        
        animationView.backgroundColor = UIColor.clear
        animationView.animation = Animation.named(animation.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        
        let frameAnimation = self.lottieView.bounds
        let widthHeight = UIScreen.main.bounds.width - (80.0 * 2)
        animationView.frame = CGRect.init(x: frameAnimation.minX, y: frameAnimation.minY, width: widthHeight, height: widthHeight)
        let widthOfLottieView = UIScreen.main.bounds.width - (32.0 * 2)
        let heightOfLottieView = 0.75 * widthOfLottieView
        animationView.center = CGPoint.init(x: widthOfLottieView / 2, y: heightOfLottieView / 2)
        lottieView.addSubview(animationView)
        animationView.play()
    }
}
