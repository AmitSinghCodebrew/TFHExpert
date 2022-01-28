//
//  ChooseAppVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 25/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ChooseAppVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDoctor: UILabel!
    @IBOutlet weak var lblPatient: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = VCLiteral.CHOOSE_APP_TITLE.localized
        lblDoctor.text = VCLiteral.CHOOSE_APP_OPTION_DOCTOR.localized
        lblPatient.text = VCLiteral.CHOOSE_APP_OPTION_PATIENT.localized
        UserPreference.shared.isChooseAppScreenShown = true
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        switch /sender.tag {
        case 0: //Patient
            let otherAppURL = "https://itunes.apple.com/app/id\(Configuration.getValue(for: .RELATED_OTHER_APPLE_APP_ID))"
            UIApplication.shared.open(URL.init(string: otherAppURL)!, options: [:], completionHandler: nil)
        case 1: //Doctor
            let navigationIntroVC = UINavigationController.init(rootViewController: Storyboard<IntroVC>.LoginSignUp.instantiateVC())
            navigationIntroVC.navigationBar.isHidden = true
            let loginVC = Storyboard<LoginSignUpNavVC>.LoginSignUp.instantiateVC()
            appDelegate?.setRoot(for: /UserPreference.shared.isIntroScreensSeen ? loginVC : navigationIntroVC)
        default: break
        }
    }
}
