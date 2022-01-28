//
//  PayOutVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 13/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class PayOutVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAvailbableBalanceTitle: UILabel!
    @IBOutlet weak var lblAvailableBalance: UILabel!
    @IBOutlet weak var btnPayOut: SKButton!
    @IBOutlet weak var lblAddBank: UILabel!
    @IBOutlet weak var tfAccountNumber: JVFloatLabeledTextField!
    @IBOutlet weak var tfAccountName: JVFloatLabeledTextField!
    @IBOutlet weak var tfIFSCCode: JVFloatLabeledTextField!
    @IBOutlet weak var tfBankName: JVFloatLabeledTextField!
    @IBOutlet weak var viewIFSC: UIView!
    
    var balance: Double?
    private var bankId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBanksAPI()
        localizedTextSetup()
        tfAccountNumber.addTarget(self, action: #selector(validateValues), for: .editingChanged)
        tfAccountName.addTarget(self, action: #selector(validateValues), for: .editingChanged)
        tfIFSCCode.addTarget(self, action: #selector(validateValues), for: .editingChanged)
        #if HomeDoctorKhalidExperts
        viewIFSC.isHidden = true
        #else
        viewIFSC.isHidden = false
        #endif
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Pay Out
            addBankAPI()
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension PayOutVC {
    @objc private func validateValues() {
        #if HomeDoctorKhalidExperts
        if /tfAccountName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || /tfAccountNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            btnPayOut.alpha = 0.5
            btnPayOut.isUserInteractionEnabled = false
        } else {
            btnPayOut.alpha = 1.0
            btnPayOut.isUserInteractionEnabled = true
        }
        #else
        if /tfAccountName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || /tfAccountNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || /tfIFSCCode.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            btnPayOut.alpha = 0.5
            btnPayOut.isUserInteractionEnabled = false
        } else {
            btnPayOut.alpha = 1.0
            btnPayOut.isUserInteractionEnabled = true
        }
        #endif
        

    }
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.PAYOUT.localized
        lblAvailbableBalanceTitle.text = VCLiteral.AVAILABLE_BALANCE.localized
        lblAvailableBalance.text = /balance?.getFormattedPrice()
        btnPayOut.setTitle(VCLiteral.PAYOUT.localized, for: .normal)
        lblAddBank.text = VCLiteral.BANK_DETAILS.localized
        tfAccountNumber.placeholder = VCLiteral.ACCOUNT_NUMBER.localized
        tfAccountName.placeholder = VCLiteral.ACCOUNT_NAME.localized
        tfIFSCCode.placeholder = VCLiteral.IFSC_CODE.localized
        tfBankName.placeholder = VCLiteral.BANK_NAME.localized
        
        validateValues()
    }
    
    private func setBankValues(_ data: Bank?) {
        tfAccountNumber.text = /data?.account_number
        tfAccountName.text = /data?.name
        tfBankName.text = /data?.bank_name
        tfIFSCCode.text = /data?.ifc_code
        validateValues()
    }
    
    private func getBanksAPI() {
        playLineAnimation()
        EP_Home.banks.request(success: { [weak self] (response) in
            let data = response as? BanksData
            self?.bankId = data?.bank_accounts?.first?.id
            self?.setBankValues(data?.bank_accounts?.first)
            self?.stopLineAnimation()
        }) { [weak self] (_) in
            self?.stopLineAnimation()
        }
    }
    
    private func addBankAPI() {
        playLineAnimation()
        EP_Home.addBank(country: nil, currency: /UserPreference.shared.clientDetail?.currency, account_holder_name: tfAccountName.text, account_holder_type: "individual", ifc_code: tfIFSCCode.text, account_number: tfAccountNumber.text, bank_name: tfBankName.text, bank_id: bankId).request(success: { [weak self] (response) in
            let data = response as? BanksData
            self?.bankId = data?.bank_accounts?.first?.id
            self?.setBankValues(data?.bank_accounts?.first)
            self?.stopLineAnimation()
            self?.payoutAPI()
        }) { [weak self] (_) in
            self?.stopLineAnimation()
        }
    }
    
    private func payoutAPI() {
        playLineAnimation()
        EP_Home.payouts(bankId: bankId, amount: String(/balance)).request(success: { [weak self] (response) in
            self?.stopLineAnimation()
            self?.popVC()
        }) { [weak self] (_) in
            self?.stopLineAnimation()
        }
    }
}
