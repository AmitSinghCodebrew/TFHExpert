//
//  BankDetailVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 13/05/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

import UIKit
import JVFloatLabeledTextField

class BankDetailVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfName: JVFloatLabeledTextField!
    @IBOutlet weak var tfBankName: JVFloatLabeledTextField!
    @IBOutlet weak var tfIBAN: JVFloatLabeledTextField!
    @IBOutlet weak var btnUpdate: SKButton!
    
    private var bank: Bank?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBanksAPI()
        localizedSetup()
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: // Update
            let isValid = Validation.shared.validate(values: (.NAME, /tfName.text), (.BANK_NAME, /tfBankName.text), (.IBAN, /tfIBAN.text))
            switch isValid {
            case .success:
                addBankAPI()
            case .failure(let alert, let message):
                btnUpdate.vibrate()
                Toast.shared.showAlert(type: alert, message: message.localized)
            }
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension BankDetailVC {
    private func addBankAPI() {
        btnUpdate.playAnimation()
     
        EP_Home.addBank(country: nil, currency: /UserPreference.shared.clientDetail?.currency, account_holder_name: /tfName.text, account_holder_type: "individual", ifc_code: nil, account_number: tfIBAN.text, bank_name: tfBankName.text, bank_id: bank?.id).request { [weak self] (responseData) in
            self?.btnUpdate.stop()
            self?.popVC()
        } error: { [weak self] (error) in
            self?.btnUpdate.stop()
        }

    }
    
    private func getBanksAPI() {
        playLineAnimation()
        EP_Home.banks.request { [weak self] (responseData) in
            self?.stopLineAnimation()
            let bank = (responseData as? BanksData)?.bank_accounts?.first
            self?.bank = bank
            self?.setData(for: bank)
        } error: { [weak self] (error) in
            self?.stopLineAnimation()
        }
    }
    
    private func setData(for bank: Bank?) {
        tfName.text = /bank?.name
        tfIBAN.text = /bank?.account_number
        tfBankName.text = /bank?.bank_name
    }
    
    private func localizedSetup() {
        lblTitle.text = VCLiteral.BANK_DETAILS.localized
        tfName.placeholder = VCLiteral.NAME_PLACEHOLDER.localized
        tfBankName.placeholder = VCLiteral.BANK_NAME.localized
        tfIBAN.placeholder = VCLiteral.ACCOUNT_NUMBER.localized
        btnUpdate.setTitle(VCLiteral.UPDATE.localized, for: .normal)
    }
}
