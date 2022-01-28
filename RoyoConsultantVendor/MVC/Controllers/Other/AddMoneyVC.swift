//
//  AddMoneyVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 24/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

import UIKit

class AddMoneyVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInputAmount: UILabel!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var btnAmount1: UIButton!
    @IBOutlet weak var btnAmount2: UIButton!
    @IBOutlet weak var btnAmount3: UIButton!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(PaymentHeaderView.identfier)
        }
    }
    
    private var dataSource: TableDataSource<PaymentHeaderProvider, PaymentCellProvider, PaymentCellModel>?
    private var items: [PaymentHeaderProvider] = PaymentHeaderProvider.getInitialItems()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        tableViewInit()
        getCardsAPI()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Proceed to payment
            break
        case 2: //Amount 1
            tfAmount.text = "\(AddMoneyAmounts.Amount1.rawValue)"
            updatePriceInsideCell(price: /tfAmount.text)
        case 3: //Amount 2
            tfAmount.text = "\(AddMoneyAmounts.Amount2.rawValue)"
            updatePriceInsideCell(price: /tfAmount.text)
        case 4: //Amount 3
            tfAmount.text = "\(AddMoneyAmounts.Amount3.rawValue)"
            updatePriceInsideCell(price: /tfAmount.text)
        default:
            break
        }
    }
    
    @IBAction func tfTxtChangeAction(_ sender: UITextField) {
        updatePriceInsideCell(price: /sender.text)
    }
}

//MARK:- VCFuncs
extension AddMoneyVC {
    
    private func updatePriceInsideCell(price: String) {
        if let selectedSectionIndex: Int = items.firstIndex(where: {/$0.headerProperty?.model?.isSelected}) {
            items[selectedSectionIndex].items?.first?.property?.model?.priceToPay = price.trimmingCharacters(in: .whitespacesAndNewlines)
            dataSource?.updateAndReload(for: .MultipleSection(items: items), .Reload(indexPaths: [IndexPath.init(row: 0, section: selectedSectionIndex)], animation: .none))
        }
    }
    
    private func getCardsAPI() {
        EP_Home.cards.request(success: { [weak self] (responseData) in
            let cards = (responseData as? CardsData)?.cards
            self?.items = PaymentHeaderProvider.getCardItems(cards) + (self?.items ?? [])
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.items ?? []), .FullReload)
        }) { (error) in
            
        }
    }
    
    private func tableViewInit() {
        
        tableView.contentInset.top = 16.0
        
        dataSource = TableDataSource<PaymentHeaderProvider, PaymentCellProvider, PaymentCellModel>.init(.MultipleSection(items: items), tableView)
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? PaymentHeaderView)?.item = item
            (view as? PaymentHeaderView)?.didSelectHeader = { [weak self] (headerModel) in
                self?.handleHeaderTap(headerModel, section: section)
            }
        }
        
        dataSource?.configureCell = { [weak self] (cell, item, indexPath) in
            (cell as? PayWithExistingCardCell)?.item = item
            (cell as? PayWithExistingCardCell)?.cardDeleted = {
                self?.items.remove(at: indexPath.section)
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.items ?? []), .DeleteSection(indexSet: IndexSet.init(integer: indexPath.section), animation: .automatic))
            }
            (cell as? PayWithNewCardCell)?.item = item
        }
        
    }
    
    private func handleHeaderTap(_ model: PaymentHeaderModel?, section: Int?) {
        if /model?.isSelected { return }
        
        items.forEach({$0.headerProperty?.model?.isSelected = false})
        items[/section].headerProperty?.model?.isSelected = true
        
        if let sectionIndexOpened: Int = self.items.firstIndex(where: {/$0.items?.count != 0 }) {
            items[sectionIndexOpened].items = []
            dataSource?.updateAndReload(for: .MultipleSection(items: items), .DeleteRowsAt(indexPaths: [IndexPath(row: 0, section: sectionIndexOpened)], animation: .none))
        }
        
        let type = model?.type ?? .CreditCard
        switch type {
        case .CreditCard, .DebitCard:
            items[/section].items = [PaymentCellProvider.init((PayWithNewCardCell.identfier, UITableView.automaticDimension, PaymentCellModel.init(type, /tfAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines))), nil, nil)]
            dataSource?.updateAndReload(for: .MultipleSection(items: items), .FullReload)
        case .GooglePay, .BhimUPI:
            items.forEach({$0.headerProperty?.model?.isSelected = false})
            dataSource?.updateAndReload(for: .MultipleSection(items: items), .FullReload)
        case .WithCard(_):
            items[/section].items = [PaymentCellProvider.init((PayWithExistingCardCell.identfier, UITableView.automaticDimension, PaymentCellModel.init(type, /tfAmount.text?.trimmingCharacters(in: .whitespacesAndNewlines))), nil, nil)]
            dataSource?.updateAndReload(for: .MultipleSection(items: items), .FullReload)
        }
    }
    
    private func localizedTextSetup() {
        tfAmount.becomeFirstResponder()
        lblTitle.text = VCLiteral.ADD_MONEY.localized
        lblInputAmount.text = VCLiteral.INPUT_AMOUNT.localized
        lblCurrency.text = UserPreference.shared.getCurrencyAbbr()
        btnAmount1.setTitle(AddMoneyAmounts.Amount1.formattedText, for: .normal)
        btnAmount2.setTitle(AddMoneyAmounts.Amount2.formattedText, for: .normal)
        btnAmount3.setTitle(AddMoneyAmounts.Amount3.formattedText, for: .normal)
    }
}
