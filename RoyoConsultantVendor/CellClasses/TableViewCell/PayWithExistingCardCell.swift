//
//  PayWithExistingCardCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 23/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class PayWithExistingCardCell: UITableViewCell, ReusableCell {
    
    typealias T = PaymentCellProvider
    
    @IBOutlet weak var btnPay: SKButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    var cardDeleted: (() -> Void)?
    
    var item: PaymentCellProvider? {
        didSet {
            let priceDouble = /item?.property?.model?.priceToPay?.toDouble()
            let priceString = /priceDouble.getFormattedPrice()
            btnPay.setTitle(String.init(format: VCLiteral.PAY_AMOUNT.localized, priceDouble == 0.0 ? "" : priceString), for: .normal)
            btnEdit.setTitle(VCLiteral.EDIT.localized, for: .normal)
            btnDelete.setTitle(VCLiteral.DELETE.localized, for: .normal)
        }
    }
    
    @IBAction func btnPayAction(_ sender: SKLottieButton) {
        if /item?.property?.model?.isValidForPayment() {
            addMoneyAPI()
        } else {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.INVALID_AMOUNT.localized)
            sender.vibrate()
        }
    }
    
    @IBAction func btnEditAction(_ sender: UIButton) {
        var card: PaymentCard?
        switch item?.property?.model?.type ?? .CreditCard {
        case .WithCard(let model):
            card = model
        default:
            break
        }
        let alertVC = UIAlertController.init(title: VCLiteral.EDIT_CARD.localized, message: /item?.property?.model?.type?.title, preferredStyle: .alert)
        
        alertVC.addTextField { (tf) in
            tf.placeholder = VCLiteral.CARD_EXP_PLACEHOLDER.localized
            tf.keyboardType = .numberPad
            tf.delegate = self
        }
        
        alertVC.addAction(UIAlertAction.init(title: VCLiteral.CANCEL.localized, style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction.init(title: VCLiteral.UPDATE.localized, style: .default, handler: { [weak self] (_) in
            if /alertVC.textFields?.first?.text?.count == 5 {
                //API Hit
                let expComponents = (/alertVC.textFields?.first?.text).components(separatedBy: "/")
                self?.updateCardAPI(id: String(/card?.id), expMonth: expComponents.first, expYear: expComponents.last)
            }
        }))
        UIApplication.topVC()?.presentVC(alertVC)
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        var cardID: String?
        switch item?.property?.model?.type ?? .CreditCard {
        case .WithCard(let model):
            cardID = String(/model?.id)
        default:
            break
        }
        
        UIApplication.topVC()?.alertBoxOKCancel(title: VCLiteral.DELETE.localized, message: VCLiteral.DELETE_CARD_MESSAGE.localized, tapped: { [weak self] in
            self?.deleteCardAPI(id: cardID)
            }, cancelTapped: nil)
    }
    
    private func deleteCardAPI(id: String?) {
        btnPay.playAnimation()
        EP_Home.deleteCard(cardId: id).request(success: { [weak self] (responseData) in
            self?.btnPay.stop()
            self?.cardDeleted?()
        }) { [weak self] (_) in
            self?.btnPay.stop()
        }
    }
    
    private func updateCardAPI(id: String?, expMonth: String?, expYear: String?) {
        btnPay.playAnimation()
        EP_Home.updateCard(cardId: id, name: nil, expMonth: expMonth, expYear: expYear).request(success: { [weak self] (_) in
            self?.btnPay.stop()
        }) { [weak self] (_) in
            self?.btnPay.stop()
        }
    }
    
    private func addMoneyAPI() {
        btnPay.playAnimation()
        var cardId = ""
        switch item?.property?.model?.type ?? .CreditCard {
        case .WithCard(let model):
            cardId = String(/model?.id)
        default:
            break
        }
        EP_Home.addMoney(balance: item?.property?.model?.priceToPay, cardId: cardId).request(success: { [weak self] (responseData) in
            self?.btnPay.stop()
            let response = responseData as? StripeData
            if /response?.requires_source_action {
                UIApplication.topVC()?.presentSafariVC(urlString: /response?.url)
            } else {
                UIApplication.topVC()?.popTo(toControllerType: WalletVC.self)
            }
        }) { [weak self] (_) in
            self?.btnPay.stop()
        }
    }
    
}

//MARK:- Edit Card Textfield Delegate
extension PayWithExistingCardCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        let currentCharacterCount = updatedText.count
        if string == "" {
            if currentCharacterCount == 3 {
                textField.text = "\(updatedText.prefix(1))"
                return false
            }
            return true
        } else if updatedText.count == 5 {
            //            expDateValidation(dateStr: updatedText)
            return true
        } else if updatedText.count > 5 {
            
            return false
        } else if updatedText.count == 1 {
            
            if updatedText > "1" {
                return false
            }
        } else if updatedText.count == 2 { //Prevent user to not enter month more than 12
            if updatedText > "12" {
                return false
            }
        }
        if updatedText.count == 2 {
            textField.text = "\(updatedText)/" //This will add "/" when user enters 2nd digit of month
        } else {
            textField.text = updatedText
        }
        return false
    }
}
