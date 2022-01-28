//
//  LanguageVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 26/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class LanguageVC: BaseVC {
    
    @IBOutlet weak var btnLanguage1: UIButton!
    @IBOutlet weak var btnLanguage2: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserPreference.shared.isLanguageScreenShown = true
        btnLanguage1.setTitle(VCLiteral.LANGUAGE_ENGLISH.localized, for: .normal)
        btnLanguage2.setTitle(VCLiteral.LANGUAGE_ARABIC.localized, for: .normal)
    }
    
    @IBAction func btnSkipAction(_ sender: UIButton) {
        furtherNavigation()
    }
    
    @IBAction func btnLanguageOption(_ sender: UIButton) {
        switch /sender.title(for: .normal) {
        case VCLiteral.LANGUAGE_ENGLISH.localized:
            L102Language.setAppleLanguage(to: .English)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        case VCLiteral.LANGUAGE_ARABIC.localized:
            L102Language.setAppleLanguage(to: .Arabic)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        default: break
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.apiToFetchPage()
        furtherNavigation()
        
    }
    
    private func furtherNavigation() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let navigationIntroVC = UINavigationController.init(rootViewController: Storyboard<IntroVC>.LoginSignUp.instantiateVC())
        navigationIntroVC.navigationBar.isHidden = true
        let loginNavigation = Storyboard<LoginSignUpNavVC>.LoginSignUp.instantiateVC()
        if /UserPreference.shared.isChooseAppScreenShown {
            appDelegate?.setRoot(for: /UserPreference.shared.isIntroScreensSeen ? loginNavigation : navigationIntroVC)
        } else {
            let navigationChooseAppVC = UINavigationController.init(rootViewController: Storyboard<ChooseAppVC>.LoginSignUp.instantiateVC())
            navigationChooseAppVC.navigationBar.isHidden = true
            appDelegate?.setRoot(for: navigationChooseAppVC)
        }
    }
    
}
