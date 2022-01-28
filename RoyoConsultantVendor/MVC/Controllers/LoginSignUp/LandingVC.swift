//
//  LandingVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 11/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class LandingVC: BaseVC {
    
    @IBOutlet weak var lblFacebook: UILabel!
    @IBOutlet weak var lblGoogle: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var appleBtn: AppleSignInButton!
    @IBOutlet weak var lblCreateContinue: UILabel!
    @IBOutlet weak var lblByContinue: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var lblAnd: UILabel!
    @IBOutlet weak var lblAlreadyAccount: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var viewForLottie: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        appleBtn.didCompletedSignIn = { (data) in
            self.loginAPI(providerType: .apple, loginData: data)
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Facebook
            FBLogin.shared.login { [weak self] (loginData) in
                self?.loginAPI(providerType: .facebook, loginData: loginData)
            }
        case 1: //Google
            GoogleSignIn.shared.openGoogleSigin { [weak self] (loginData) in
                self?.loginAPI(providerType: .google, loginData: loginData)
            }
        case 2: //SignUp using Email
            let destVC = Storyboard<SignUpVC>.LoginSignUp.instantiateVC()
            pushVC(destVC)
        case 3: //SignUp using Mobile Number
            let destVC = Storyboard<LoginMobileVC>.LoginSignUp.instantiateVC()
            destVC.isLogin = true
            destVC.providerType = .phone
            pushVC(destVC)
        case 4: //Terms Of Service
            let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(APIConstants.termsConditions)", VCLiteral.TERMS_AND_CONDITIONS.localized)
            pushVC(destVC)
        case 5: //Privacy Policy
            let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(APIConstants.privacyPolicy)", VCLiteral.PRIVACY.localized)
            pushVC(destVC)
        case 6: //Login
            let destVC = Storyboard<LoginMobileVC>.LoginSignUp.instantiateVC()
            destVC.providerType = .phone
            pushVC(destVC)
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension LandingVC {
    
    private func loginAPI(providerType: ProviderType, loginData: GoogleAppleFBUserData?) {
        startAnimation()
        EP_Login.login(provider_type: providerType, provider_id: nil, provider_verification: /loginData?.accessToken, user_type: .service_provider, country_code: nil, is_agreed: nil).request(success: { [weak self] (response) in

            self?.stopAnimation()
            if /(response as? User)?.services?.count == 0 {
                if providerType == .apple{
                    #if NurseLynxExpert
                     UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
                    #endif
                    let destVC = Storyboard<LoginMobileVC>.LoginSignUp.instantiateVC()
                    destVC.providerType = providerType
                    self?.pushVC(destVC)
                }else{
                    let destVC = Storyboard<LoginMobileVC>.LoginSignUp.instantiateVC()
                    destVC.providerType = providerType
                    self?.pushVC(destVC)
                }
                
            } else {
               UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
            }
        }) { [weak self] (error) in
            self?.stopAnimation()
        }
    }
    
    private func localizedTextSetup() {
        lblFacebook.text = VCLiteral.FACEBOOK.localized
        lblGoogle.text = VCLiteral.GOOGLE.localized
        lblEmail.text = VCLiteral.SIGNUP_WITH_EMAIL.localized
        lblMobileNumber.text = VCLiteral.SIGNUP_WITH_PHONE.localized
        let fullText = String.init(format: VCLiteral.CREATE_ACCOUNT_TO_CONTINUE.localized, Configuration.appName())
        lblCreateContinue.setAttributedText(original: (fullText, Fonts.CamptonMedium.ofSize(16), ColorAsset.txtMoreDark.color), toReplace: (Configuration.appName(), Fonts.CamptonSemiBold.ofSize(16), ColorAsset.appTint.color))
        
        lblByContinue.text = VCLiteral.BY_CONTINUE.localized
        btnTerms.setTitle(VCLiteral.TERMS.localized, for: .normal)
        btnPrivacy.setTitle(VCLiteral.PRIVACY.localized, for: .normal)
        lblAnd.text = VCLiteral.AND.localized
        lblAlreadyAccount.text = VCLiteral.ALREADY_ACCOUNT.localized
        btnLogin.setTitle(VCLiteral.LOGIN.localized, for: .normal)
        lblTitle.text = VCLiteral.LANDING_TITLE.localized
        lblSubTitle.text = VCLiteral.LANDING_SUBTITLE.localized
    }
    
    private func startAnimation() {
        view.isUserInteractionEnabled = false
        lineAnimation.removeFromSuperview()
        let width = UIScreen.main.bounds.width
        let height = width * (5 / 450)
        lineAnimation.frame = CGRect.init(x: 0, y: 0, width: width, height: height - 2.0)
        viewForLottie.addSubview(lineAnimation)
        lineAnimation.clipsToBounds = true
        lineAnimation.play()
    }
    
    private func stopAnimation() {
        lineAnimation.stop()
        lineAnimation.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
}
