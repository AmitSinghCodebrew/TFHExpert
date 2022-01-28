//
//  PayWithNewCardCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 23/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class PayWithNewCardCell: UITableViewCell, ReusableCell {
    
    typealias T = PaymentCellProvider
    
    @IBOutlet weak var lblEnterCardDetails: UILabel!
    @IBOutlet weak var lblExpiry: UILabel!
    @IBOutlet weak var lblCVV: UILabel!
    @IBOutlet weak var btnPay: SKButton!
    @IBOutlet weak var tfCardNumber: DECardNumberTextField!
    @IBOutlet weak var tfExpiry: CardExpiryTF!
    @IBOutlet weak var tfCVV: CvvTF!
    
    var item: PaymentCellProvider? {
        didSet {
            let obj = item?.property?.model
            tfCardNumber.setup()
            tfExpiry.setup()
            tfCVV.setup()
            let priceDouble = /obj?.priceToPay?.toDouble()
            let priceString = /priceDouble.getFormattedPrice()
            btnPay.setTitle(String.init(format: VCLiteral.PAY_AMOUNT.localized, priceDouble == 0.0 ? "" : priceString), for: .normal)
            tfCardNumber.text = /obj?.newCard?.cardNumber
            tfExpiry.text = /obj?.newCard?.expiry
            tfCVV.text = /obj?.newCard?.cvv
        }
    }
    
    @IBAction func tfAction(_ sender: UITextField) {
        switch sender.tag {
        case 0: //Card Number
            item?.property?.model?.newCard?.cardNumber = /sender.text
        case 1: //Expiry
            item?.property?.model?.newCard?.expiry = /sender.text
        case 2: //CVV
            item?.property?.model?.newCard?.cvv = /sender.text
        default:
            break
        }
        
    }
    
    @IBAction func btnPayAction(_ sender: SKLottieButton) {
        if /item?.property?.model?.isValidForPayment() {
            if /item?.property?.model?.priceToPay?.toDouble() <= 0.0 {
                Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.INVALID_AMOUNT.localized)
            } else {
                addCardAPI()
            }
        } else {
            sender.vibrate()
            if /item?.property?.model?.priceToPay?.toDouble() <= 0.0 {
                Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.INVALID_AMOUNT.localized)
            }
        }
    }
    
    private func addCardAPI() {
        btnPay.playAnimation()
        let cardDetails = item?.property?.model?.newCard
        let cardNumber = /cardDetails?.cardNumber?.trimmingCharacters(in: .whitespaces)
        let expiryMonthAndYear = (/cardDetails?.expiry).components(separatedBy: "/")
        
        let last4Digits = String(cardNumber.suffix(4))
        
        
        EP_Home.addCard(cardNumber: cardNumber, expMonth: expiryMonthAndYear.first, expYear: /expiryMonthAndYear.last, cvv: cardDetails?.cvv).request(success: { [weak self] (responseData) in
            let cards = (responseData as? CardsData)?.cards
            let selectedCard = cards?.first(where: {/$0.last_four_digit == last4Digits})
            self?.addMoneyAPI(cardId: String(/selectedCard?.id))
        }) { [weak self] (_) in
            self?.btnPay.stop()
        }
    }
    
    private func addMoneyAPI(cardId: String?) {
        EP_Home.addMoney(balance: item?.property?.model?.priceToPay, cardId: cardId).request(success: { [weak self] (responseData) in
            self?.btnPay.stop()
            UIApplication.topVC()?.popTo(toControllerType: WalletVC.self)
        }) { [weak self] (_) in
            self?.btnPay.stop()
        }
    }
}
