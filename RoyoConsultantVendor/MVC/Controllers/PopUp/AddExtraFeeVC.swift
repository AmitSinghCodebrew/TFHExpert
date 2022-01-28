//
//  AddExtraFeeVC.swift
//  HomeDoctorKhalidExperts
//
//  Created by Sandeep Kumar on 09/02/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class AddExtraFeeVC: BaseVC {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfAmount: JVFloatLabeledTextField!
    @IBOutlet weak var tfDesc: JVFloatLabeledTextField!
    @IBOutlet weak var btnAdd: SKLottieButton!
    
    public var request: Requests?
    public var didRequestedExtraPayment: ((_ extraPayment: ExtraPayment) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.unhideVisualEffectView()
        }
        tfAmount.placeholder = VCLiteral.INPUT_AMOUNT.localized
        tfDesc.placeholder = VCLiteral.DESC.localized
        lblTitle.text = VCLiteral.REQUEST_FOR_PAYMENT.localized
        btnAdd.setTitle(VCLiteral.REQUEST_FOR_PAYMENT.localized, for: .normal)
    }

    @IBAction func btnBackAction(_ sender: UIButton) {
        hideVisulEffectView(withSuccess: false)
    }

    @IBAction func btnAddAction(_ sender: UIButton) {
        if Double(/tfAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines)) == 0.0 || /tfDesc.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            btnAdd.vibrate()
        } else {
            addExtraAmountAPI()
        }
    }
}

//MARK:- VCFuncs
extension AddExtraFeeVC {
    private func addExtraAmountAPI() {
        btnAdd.playAnimation()
        EP_Home.extraPayment(requestId: request?.id, balance: tfAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines), description: tfDesc.text).request { [weak self] (responsneData) in
            self?.btnAdd.stop()
            self?.hideVisulEffectView(withSuccess: true)
        } error: { [weak self] (error) in
            self?.btnAdd.stop()
        }
    }
    
    private func unhideVisualEffectView() {
        visualEffectView.alpha = 0
        visualEffectView.isHidden = false
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.visualEffectView.alpha = 1.0
        }
    }
    
    private func hideVisulEffectView(withSuccess: Bool) {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.visualEffectView.alpha = 0.0
        }) { [weak self] (finished) in
            self?.visualEffectView.isHidden = true
            self?.dismiss(animated: true, completion: {
                if withSuccess {
                    self?.didRequestedExtraPayment?(.init(Double(/self?.tfAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines)), .pending, self?.tfDesc.text))
                }
            })
        }
    }
}
