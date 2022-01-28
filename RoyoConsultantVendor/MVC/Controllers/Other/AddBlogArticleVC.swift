//
//  AddBlogArticleVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AddBlogArticleVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblUpload: UILabel!
    @IBOutlet weak var lblTitleTF: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tvTextView: UITextView!
    @IBOutlet weak var btnSubmit: SKButton!
    
    public var feedType: FeedType?
    private var image_URL: String?
    public var didAddFeed: ((_ _feed: Feed?) -> Void)?
    private var isUploading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(selectImage)))
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Submit
            if isUploading {
                Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOC_UPLOADING_ALERT.localized)
                return
            }
            switch Validation.shared.validate(values: (ValidationType.TITLE, /tfTitle.text), (ValidationType.DESC, /tvTextView.text)) {
            case .success:
                addArticleBlogAPI()
            case .failure(let type, let message):
                Toast.shared.showAlert(type: type, message: message.localized)
            }
        default:
            break
        }
    }
    
}

//MARK:- VCFuncs
extension AddBlogArticleVC {
    
    @objc func selectImage() {
        view.endEditing(true)
        mediaPicker.presentPicker({ [weak self] (image) in
            self?.imgView.image = image
            self?.uploadImageAPI()
            }, nil, nil)
    }
    
    private func uploadImageAPI() {
        playUploadAnimation(on: imgView)
        isUploading = true
        EP_Home.uploadMedia(image: (imgView.image)!, type: .image, doc: nil, localAudioPath: nil).request(success: { [weak self] (responseData) in
            self?.stopUploadAnimation()
            self?.image_URL = (responseData as? ImageUploadData)?.image_name
            self?.isUploading = false
        }) { [weak self] (error) in
            self?.stopUploadAnimation()
            self?.isUploading = false
            self?.alertBox(title: VCLiteral.UPLOAD_ERROR.localized, message: error, btn1: VCLiteral.CANCEL.localized, btn2: VCLiteral.RETRY_SMALL.localized, tapped1: {
                self?.imgView.image = nil
            }, tapped2: {
                self?.uploadImageAPI()
            })
        }
    }
    
    private func addArticleBlogAPI() {
        btnSubmit.playAnimation()
        EP_Home.addFeed(title: tfTitle.text, desc: tvTextView.text, type: feedType, image: image_URL).request(success: { [weak self] (responseData) in
            self?.btnSubmit.stop()
            self?.didAddFeed?(responseData as? Feed)
            self?.popVC()
        }) { [weak self] (_) in
            self?.btnSubmit.stop()
        }
    }
    
    private func localizedTextSetup() {
        lblTitle.text = /feedType?.title
        lblTitleTF.text = VCLiteral.TITLE.localized
        lblDesc.text = VCLiteral.DESC.localized
        lblUpload.text = VCLiteral.UPLOAD_BANNER.localized
        btnSubmit.setTitle(VCLiteral.SUBMIT.localized, for: .normal)
    }
}
