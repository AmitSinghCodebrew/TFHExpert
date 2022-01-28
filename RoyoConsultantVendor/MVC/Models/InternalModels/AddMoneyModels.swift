//
//  AddMoneyModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 24/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class PaymentHeaderProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = PaymentCellProvider
    
    typealias HeaderModelType = PaymentHeaderModel
    
    typealias FooterModelType = Any
    
    var headerProperty: (identifier: String?, height: CGFloat?, model: PaymentHeaderModel?)?
    
    var footerProperty: (identifier: String?, height: CGFloat?, model: Any?)?
    
    var items: [PaymentCellProvider]?
    
    required init(_ _header: (identifier: String?, height: CGFloat?, model: PaymentHeaderModel?)?, _ _footer: (identifier: String?, height: CGFloat?, model: Any?)?, _ _items: [PaymentCellProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getInitialItems() -> [PaymentHeaderProvider] {
        return [PaymentHeaderProvider.init((PaymentHeaderView.identfier, 48.0, PaymentHeaderModel.init(.CreditCard)), nil, [PaymentCellProvider]())]
//
//        return [PaymentHeaderProvider.init((PaymentHeaderView.identfier, 48.0, PaymentHeaderModel.init(.DebitCard)), nil, [PaymentCellProvider]()),
//                PaymentHeaderProvider.init((PaymentHeaderView.identfier, 48.0, PaymentHeaderModel.init(.CreditCard)), nil, [PaymentCellProvider]()),
//                PaymentHeaderProvider.init((PaymentHeaderView.identfier, 48.0, PaymentHeaderModel.init(.GooglePay)), nil, [PaymentCellProvider]()),
//                PaymentHeaderProvider.init((PaymentHeaderView.identfier, 48.0, PaymentHeaderModel.init(.BhimUPI)), nil, [PaymentCellProvider]())]
    }
    
    class func getCardItems(_ cards: [PaymentCard]?) -> [PaymentHeaderProvider] {
        var cardHeaders = [PaymentHeaderProvider]()
        cards?.forEach {
            cardHeaders.append(PaymentHeaderProvider.init((PaymentHeaderView.identfier, 48.0, PaymentHeaderModel.init(.WithCard(model: $0))), nil, [PaymentCellProvider]()))
        }
        cardHeaders.first?.headerProperty?.model?.isSelected = true
        cardHeaders.first?.items = [PaymentCellProvider.init((PayWithExistingCardCell.identfier, UITableView.automaticDimension, PaymentCellModel.init(.WithCard(model: cards?.first))), nil, nil)]
        return cardHeaders
    }
}

class PaymentCellProvider: CellModelProvider {
    
    typealias CellModelType = PaymentCellModel

    var property: (identifier: String, height: CGFloat, model: PaymentCellModel?)?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: (identifier: String, height: CGFloat, model: PaymentCellModel?)?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}

class PaymentHeaderModel {
    var type: PaymentType?
    var isSelected: Bool = false
    
    init(_ _type: PaymentType, _ _isSelected: Bool? = false) {
        type = _type
        isSelected = /_isSelected
    }
}

class PaymentCellModel {
    var type: PaymentType?
    var priceToPay: String?
    
    var newCard: NewCard?
    
    init(_ _type: PaymentType, _ _priceToPay: String? = nil) {
        type = _type
        priceToPay = _priceToPay
        newCard = NewCard()
    }
    
    func isValidForPayment() -> Bool {
        switch type ?? .CreditCard {
        case .WithCard(_):
            if /priceToPay?.toDouble() <= 0.0 {
                return false
            }
            return true
        case .CreditCard, .DebitCard:
            if /priceToPay?.toDouble() <= 0.0 {
                return false
            }
            return /newCard?.isValidCardDetails()
        default:
            return true
        }
    }
}

class NewCard {
    var cardNumber: String?
    var expiry: String?
    var cvv: String?
    
    func isValidCardDetails() -> Bool {
        let cardFormatter = DECardNumberFormatter()
        if cardFormatter.isValidLuhnCardNumber(/cardNumber) && /expiry?.count == 5 && /cvv?.count == 3 {
            return true
        }
        return false
    }
}

enum PaymentType {
    case WithCard(model: PaymentCard?)
    case DebitCard
    case CreditCard
    case GooglePay
    case BhimUPI
    
    var title: String {
        switch self {
        case .WithCard(let model):
            return String.init(format: VCLiteral.CARD_ENDING_WITH.localized, /model?.card_brand, /model?.last_four_digit)
        case .DebitCard:
            return VCLiteral.DEBIT_CARD.localized
        case .CreditCard:
            return VCLiteral.CREDIT_CARD.localized
        case .GooglePay:
            return VCLiteral.GPAY.localized
        case .BhimUPI:
            return VCLiteral.BHIM.localized
        }
    }
}
