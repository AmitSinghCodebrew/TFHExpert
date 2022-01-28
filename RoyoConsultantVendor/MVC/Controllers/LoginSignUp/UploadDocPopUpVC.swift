//
//  UploadDocPopUpVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 04/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class UploadDocPopUpVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tfTitle: JVFloatLabeledTextField!
    @IBOutlet weak var tfDescription: JVFloatLabeledTextField!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var btnAdd: SKButton!
    
    var didTapAdd: ((_ model: Doc?) -> Void)?
    private var image_URL: String?
    public var doc: Doc?
    private var isUploading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(selectImage)))
        localizedTextSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.unhideVisualEffectView()
        }
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        if isUploading {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOC_UPLOADING_ALERT.localized)
            return
        }
        switch Validation.shared.validate(values: (.IMAGE_DOC, /image_URL), (.TITLE_DOC, /tfTitle.text), (.DESC_DOC, /tfDescription.text)) {
        case .success:
            hideVisulEffectView(callAdd: true)
        case .failure(let type, let message):
            Toast.shared.showAlert(type: type, message: /message.localized)
        }
        
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        hideVisulEffectView()
    }
}

//MARK:- VCFuncs
extension UploadDocPopUpVC {
    
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
    
    private func localizedTextSetup() {
        visualEffectView.alpha = 0
        visualEffectView.isHidden = true
        lblTitle.text = VCLiteral.UPLOAD_DOCS.localized
        btnAdd.setTitle(VCLiteral.ADD.localized, for: .normal)
        tfTitle.placeholder = VCLiteral.TITLE.localized
        tfDescription.placeholder = VCLiteral.DESC.localized
        
        if let document = doc {
            image_URL = document.file_name
            imgView.setImageNuke(document.file_name)
            lblTitle.text = VCLiteral.EDIT.localized
            tfTitle.text = /document.title
            tfDescription.text = /document.description
            btnAdd.setTitle(VCLiteral.SAVE.localized, for: .normal)
        }
    }
    
    private func hideVisulEffectView(callAdd: Bool? = false) {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.visualEffectView.alpha = 0.0
        }) { [weak self] (finished) in
            self?.doc = Doc.init(self?.tfTitle.text, self?.tfDescription.text, self?.image_URL)
            self?.visualEffectView.isHidden = true
            self?.dismiss(animated: true, completion: {
                /callAdd ? self?.didTapAdd?(self?.doc) : ()
            })
        }
    }
    
    private func unhideVisualEffectView() {
        visualEffectView.alpha = 0
        visualEffectView.isHidden = false
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.visualEffectView.alpha = 1.0
        }
    }
}
