//
//  LoginMobileVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 11/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class LoginMobileVC: BaseVC {
    
    @IBOutlet weak var lblEnterMobNo: UILabel!
    @IBOutlet weak var lblEnterMobNoDesc: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var tfMobileNumber: UITextField!
    @IBOutlet weak var lblByContinue: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var lblAnd: UILabel!
    @IBOutlet weak var lblLoginWith: UILabel!
    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var viewLoginWithEmail: UIView!
    @IBOutlet weak var viewTick: UIView!
    @IBOutlet weak var viewTerms: UIStackView!
    @IBOutlet weak var viewTickBack: UIView!
    @IBOutlet weak var tickBtn: UIButton!
    
    private var countryPicker: CountryManager?
    private var currentCountry: CountryISO?
    public var providerType: ProviderType = .phone
    public var isLogin: Bool = false

    private var isTermsAgreed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCountryCode.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(presentCountryPicker)))
        countryPicker = CountryManager()
        currentCountry = countryPicker?.currentCountry
        localizedTextSetup()
        
        nextBtnAccessory.didTapContinue = { [weak self] in
            let btn = UIButton.init()
            btn.tag = 1
            self?.btnAction(btn)
        }
        
        tfResponder = TFResponder()
        tfResponder?.addResponders([TVTF.TF(tfMobileNumber)])
        tfMobileNumber.becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return nextBtnAccessory
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            if /navigationController?.viewControllers.contains(where: {$0.isKind(of: LandingVC.self)}) {
                popTo(toControllerType: LandingVC.self)
            } else {
                popVC()
            }
            
        case 1: //Next
            switch Validation.shared.validate(values: (.PHONE, /tfMobileNumber.text)) {
            case .success:
                if isTermsAgreed {
                    loginAPI()
                } else {
                    Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.TERMS_ALERT.localized)
                }
            case .failure(let alertType, let message):
                Toast.shared.showAlert(type: alertType, message: message.localized)
            }
        case 2: //Terms of service
            let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(APIConstants.termsConditions)", VCLiteral.TERMS_AND_CONDITIONS.localized)
            pushVC(destVC)
        case 3: //Privacy Policy
            let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(APIConstants.privacyPolicy)", VCLiteral.PRIVACY.localized)
            pushVC(destVC)
        case 4: //Login Email
            let destVC = Storyboard<LoginEmailVC>.LoginSignUp.instantiateVC()
            pushVC(destVC)
        case 5: //Tick Terms
            isTermsAgreed = !(isTermsAgreed)
            tickBtn.backgroundColor = isTermsAgreed ? ColorAsset.appTint.color : .clear
            tickBtn.setImage(isTermsAgreed ? #imageLiteral(resourceName: "ic_tick") : nil, for: .normal)
        default:
            break
        }
    }
    
}

//MARK:- VCFuncs
extension LoginMobileVC {
    
    private func loginAPI() {
        view.isUserInteractionEnabled = false
        nextBtnAccessory.startAnimation()
        
        EP_Login.sendOTP(phone: /tfMobileNumber.text, countryCode: "+\(/currentCountry?.CC)").request(success: { [weak self] (responseData) in
            self?.nextBtnAccessory.stopAnimation()
            self?.view.isUserInteractionEnabled = true
            let destVC = Storyboard<VerificationVC>.LoginSignUp.instantiateVC()
            destVC.phone = (/self?.currentCountry?.CC, /self?.tfMobileNumber.text)
            destVC.providerType = self?.providerType ?? .phone
            self?.pushVC(destVC)
        }) { [weak self] (error) in
            self?.nextBtnAccessory.stopAnimation()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    
    @objc private func presentCountryPicker() {
        countryPicker?.openCountryPicker({ [weak self] (country) in
            self?.currentCountry = country
            self?.lblCountryCode.text = "\(/self?.currentCountry?.Flag) \(/self?.currentCountry?.ISO) +\(/self?.currentCountry?.CC)"
        })
    }
    
    private func localizedTextSetup() {
        lblEnterMobNo.text = providerType == .updatePhone ? VCLiteral.UPDATE_PHONE_NUMBER.localized : VCLiteral.LOGIN_USING_MOBILE.localized
        lblEnterMobNoDesc.text = VCLiteral.LOGIN_USING_MOBILE_DESC.localized
        tfMobileNumber.placeholder = VCLiteral.MOBILE_PACEHOLDER.localized
        lblCountryCode.text = "\(/self.currentCountry?.Flag) \(/self.currentCountry?.ISO) +\(/self.currentCountry?.CC)"
        lblByContinue.text = VCLiteral.BY_CONTINUE.localized
        btnTerms.setTitle(VCLiteral.TERMS.localized, for: .normal)
        btnPrivacy.setTitle(VCLiteral.PRIVACY.localized, for: .normal)
        lblAnd.text = VCLiteral.AND.localized
        lblLoginWith.text = VCLiteral.LOGIN_WITH.localized
        btnEmail.setTitle(VCLiteral.EMAIL_PLACEHOLDER.localized, for: .normal)
        if providerType == .updatePhone {
            viewTerms.isHidden = true
            viewLoginWithEmail.isHidden = true
        }
        viewLoginWithEmail.isHidden = isLogin
        viewTerms.isHidden = !isLogin
        tickBtn.setImage(isTermsAgreed ? #imageLiteral(resourceName: "ic_tick") : nil, for: .normal)
        tickBtn.backgroundColor = isTermsAgreed ? ColorAsset.appTint.color : .clear
        
        if !isLogin {
            isTermsAgreed = true
        }
    }
}
