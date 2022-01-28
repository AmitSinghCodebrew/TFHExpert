//
//  VerificationVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 12/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class VerificationVC: BaseVC {
    
    @IBOutlet weak var lblVerification: UILabel!
    @IBOutlet weak var lblCodeSentTo: UILabel!
    @IBOutlet weak var tfDigit1: OTPTextField!
    @IBOutlet weak var tfDigit2: OTPTextField!
    @IBOutlet weak var tfDigit3: OTPTextField!
    @IBOutlet weak var tfDigit4: OTPTextField!
    @IBOutlet weak var lblNotReceiveCode: UILabel!
    @IBOutlet weak var btnResend: SKLottieButton!
    @IBOutlet weak var otpStackView: UIStackView!

    var phone: (cc: String, number: String)?
    var email: String?
    var registerEP: EP_Login?
    var providerType: ProviderType = .phone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        
        nextBtnAccessory.didTapContinue = { [weak self] in
            let btn = UIButton.init()
            btn.tag = 2
            self?.btnAction(btn)
        }
        
        [tfDigit1, tfDigit2, tfDigit3, tfDigit4].forEach({ [weak self] in
            $0?.delegate = self
            $0?.didTapBackward = {
                self?.backwardTapped()
            }
        })
        
        tfDigit1.becomeFirstResponder()
        otpStackView.semanticContentAttribute = .forceLeftToRight

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
            popVC()
        case 1: //Resend Code
            btnResend.setAnimationType(.BtnAppTintLoader)
            btnResend.playAnimation()
            switch providerType {
            case .email:
                EP_Login.sendEmailOTP(email: /email).request { [weak self] (response) in
                    self?.btnResend.stop()
                } error: { [weak self] (error) in
                    self?.btnResend.stop()
                }
            case .apple, .google, .facebook, .phone, .updatePhone, .unknown:
                EP_Login.sendOTP(phone: /phone?.number, countryCode: "+\(/phone?.cc)").request(success: { [weak self] (responseData) in
                    self?.btnResend.stop()
                }) { [weak self] (error) in
                    self?.btnResend.stop()
                }
            }
        case 2: //Next
            verifyOTP()
        default:
            break
        }
    }
    
}

//MARK:- VCFuncs
extension VerificationVC {
    private func localizedTextSetup() {
        lblVerification.text = VCLiteral.VERIFICATION.localized
        lblCodeSentTo.text = String.init(format: VCLiteral.CODESENT.localized, providerType == .email ? /email : "+\(/phone?.cc)-\(/phone?.number)")
        lblNotReceiveCode.text = VCLiteral.CODE_NOT_RECEIVED.localized
        btnResend.setTitle(VCLiteral.RESEND_CODE.localized, for: .normal)
    }
    
    private func verifyOTP() {
        let otp = /tfDigit1.text?.trimmingCharacters(in: .whitespaces) + /tfDigit2.text?.trimmingCharacters(in: .whitespaces) + /tfDigit3.text?.trimmingCharacters(in: .whitespaces) + /tfDigit4.text?.trimmingCharacters(in: .whitespaces)
        if otp.count == 4 {
            switch providerType {
            case .phone:
                loginAPI(otp)
            case .facebook, .google:
                updateProfileAPI()
            case .email:
                view.isUserInteractionEnabled = false
                nextBtnAccessory.startAnimation()
                EP_Login.verifyEmailOTP(email: /email, otp: otp).request { [weak self] (response) in
                    self?.registerAPI()
                } error: { [weak self] (error) in
                    self?.view.isUserInteractionEnabled = true
                    self?.nextBtnAccessory.stopAnimation()
                }
            case .apple:
                view.isUserInteractionEnabled = false
                nextBtnAccessory.startAnimation()
                EP_Login.updatePhone(phone: /phone?.number, countryCode: "+\(/phone?.cc)", otp: otp).request(success: { [weak self] (response) in
                    self?.view.isUserInteractionEnabled = true
                    self?.nextBtnAccessory.stopAnimation()
                    let destVC = Storyboard<SignUpInterMediateVC>.LoginSignUp.instantiateVC()
                    destVC.isViaAppleSignUp = true
                    self?.pushVC(destVC)
                }) { [weak self] (error) in
                    self?.view.isUserInteractionEnabled = true
                    self?.nextBtnAccessory.stopAnimation()
                }
            case .updatePhone:
                view.isUserInteractionEnabled = false
                nextBtnAccessory.startAnimation()
                EP_Login.updatePhone(phone: /phone?.number, countryCode: "+\(/phone?.cc)", otp: otp).request(success: { [weak self] (response) in
                    self?.view.isUserInteractionEnabled = true
                    self?.nextBtnAccessory.stopAnimation()
                    self?.popTo(toControllerType: ProfileDetailVC.self)
                }) { [weak self] (error) in
                    self?.view.isUserInteractionEnabled = true
                    self?.nextBtnAccessory.stopAnimation()
                }
            case .unknown:
                break
            }
            
        }
    }
    
    private func registerAPI() {
        registerEP?.request(success: { [weak self] (response) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
            if /UserPreference.shared.data?.services?.count == 0 {
                let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
            } else {
                UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
            }
        }, error: { [weak self] (error) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
        })
    }
    
    private func loginAPI(_ otp: String) {
        view.isUserInteractionEnabled = false
        nextBtnAccessory.startAnimation()
        EP_Login.login(provider_type: .phone, provider_id: phone?.number, provider_verification: otp, user_type: .service_provider, country_code: "+\(/phone?.cc)", is_agreed: true).request(success: { [weak self] (responseData) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
            
            if /(responseData as? User)?.name == "" {
                let destVC = Storyboard<SignUpInterMediateVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
            } else if (responseData as? User)?.categoryData == nil { //Redirect to Home screen
                let destVC = Storyboard<SignUpInterMediateVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
            } else {
                UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
            }
        }) { [weak self] (error) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
        }
    }
    
    private func updateProfileAPI() {
        view.isUserInteractionEnabled = false
        nextBtnAccessory.startAnimation()
        EP_Login.profileUpdate(name: /UserPreference.shared.data?.name, email: UserPreference.shared.data?.email, phone: /phone?.number, country_code: "+\(/phone?.cc)", dob: UserPreference.shared.data?.profile?.dob, bio: nil, speciality: nil, call_price: nil, chat_price: nil, category_id: nil, experience: nil, profile_image: nil, workingSince: nil, namePrefix: nil, custom_fields: nil, master_preferences: nil, inviteCode: nil, is_agreed: true).request(success: { [weak self] (response) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
            if /UserPreference.shared.data?.services?.count == 0 {
                let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
            } else {
                UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
            }
        }) { [weak self] (error) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
        }
    }
}

//MARK:- UITextFieldDelegate
extension VerificationVC: UITextFieldDelegate {
    func backwardTapped() {
        if tfDigit2.isFirstResponder{
            tfDigit1.becomeFirstResponder()
        }
        if tfDigit3.isFirstResponder{
            tfDigit2.becomeFirstResponder()
        }
        if tfDigit4.isFirstResponder{
            tfDigit3.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var shouldProcess = false //default to reject
        var shouldMoveToNextField = false //default to remaining on the current field
        let  insertStrLength = string.count
        
        if insertStrLength == 0 {
            
            shouldProcess = true //Process if the backspace character was pressed
            
        } else {
            if /textField.text?.count <= 1 {
                shouldProcess = true //Process if there is only 1 character right now
            }
        }
        
        if shouldProcess {
            
            var mString = ""
            if mString.count == 0 {
                
                mString = string
                shouldMoveToNextField = true
                
            } else {
                //adding a char or deleting?
                if(insertStrLength > 0){
                    mString = string
                    
                } else {
                    //delete case - the length of replacement string is zero for a delete
                    mString = ""
                }
            }
            
            //set the text now
            textField.text = mString
            
            if (shouldMoveToNextField&&textField.text?.count == 1) {
                
                if (textField == tfDigit1) {
                    tfDigit2.becomeFirstResponder()
                    
                } else if (textField == tfDigit2){
                    tfDigit3.becomeFirstResponder()
                    
                } else if (textField == tfDigit3){
                    tfDigit4.becomeFirstResponder()
                    
                } else {
                    tfDigit4.resignFirstResponder()
                    verifyOTP()
                }
            }
            else{
                backwardTapped()
            }
        }
        return false
    }
}
