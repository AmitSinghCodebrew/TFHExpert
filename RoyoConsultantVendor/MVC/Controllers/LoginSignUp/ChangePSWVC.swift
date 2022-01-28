//
//  ChangePSWVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 26/10/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class ChangePSWVC: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfOldPsw: JVFloatLabeledTextField!
    @IBOutlet weak var tfNewPsw: JVFloatLabeledTextField!
    @IBOutlet weak var tfConfirmPsw: JVFloatLabeledTextField!
    @IBOutlet weak var btnSubmit: SKLottieButton!
 
    var didSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func btnSubmitAction(_ sender: SKLottieButton) {
        let isValid = Validation.shared.validate(values: (.OLD_PSW, /tfOldPsw.text), (.NEW_PSW, /tfOldPsw.text), (.OLD_PSW, /tfOldPsw.text))
        switch isValid {
        case .success:
            if /tfNewPsw.text == /tfConfirmPsw.text {
                //Hit API
                changePswAPI()
            } else {
                btnSubmit.vibrate()
            }
        case .failure(let alertType, let message):
            Toast.shared.showAlert(type: alertType, message: message.localized)
            btnSubmit.vibrate()
        }
    }
}

//MARK:- VCFuncs
extension ChangePSWVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.CHANGE_PASSWORD.localized
        tfOldPsw.placeholder = VCLiteral.OLD_PSW.localized
        tfNewPsw.placeholder = VCLiteral.NEW_PSW.localized
        tfConfirmPsw.placeholder = VCLiteral.CONFIRM_PSW.localized
        btnSubmit.setTitle(VCLiteral.SUBMIT.localized, for: .normal)
    }
    
    private func changePswAPI() {
        view.endEditing(true)
        btnSubmit.playAnimation()
        EP_Login.changePassword(currentPSW: tfOldPsw.text, newPSW: tfNewPsw.text).request { [weak self] (response) in
            self?.btnSubmit.stop()
            self?.popVC()
            self?.didSuccess?()
        } error: { [weak self] (error) in
            self?.btnSubmit.vibrate()
            self?.btnSubmit.stop()
        }

    }
}
