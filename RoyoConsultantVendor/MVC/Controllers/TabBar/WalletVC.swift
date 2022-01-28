//
//  WalletVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class WalletVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAvailBalanceTitle: UILabel!
    @IBOutlet weak var lblAvailBalanceValue: UILabel!
    @IBOutlet weak var lblTransactionHistory: UILabel!
    @IBOutlet weak var btnAddMoney: UIButton!
    @IBOutlet weak var tableView: UITableView! 
    @IBOutlet weak var btnPayOut: SKButton!
    
    public var dataSource: TableDataSource<DefaultHeaderFooterModel<Payment>, DefaultCellModel<Payment>, Payment>?
    private var items = [Payment]()
    private var walletBalance: Double?
    private var after: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        tableViewInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getWalletBalanceAPI()
        if /items.count > 0 {
            getTransactionHistoryAPI(isRefreshing: true)
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 1: //Pay-Out
            let destVC = Storyboard<PayOutVC>.Other.instantiateVC()
            destVC.balance = walletBalance
            pushVC(destVC)
        case 2: //Add Money
            pushVC(Storyboard<AddMoneyVC>.Other.instantiateVC())
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension WalletVC {
    
    private func tableViewInit() {
        dataSource = TableDataSource<DefaultHeaderFooterModel<Payment>, DefaultCellModel<Payment>, Payment>.init(.SingleListing(items: items, identifier: TransactionCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, true)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? TransactionCell)?.item = item
        }
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getTransactionHistoryAPI(isRefreshing: true)
            self?.getWalletBalanceAPI()
        }
    
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getTransactionHistoryAPI()
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.WALLET.localized
        lblAvailBalanceTitle.text = VCLiteral.AVAILABLE_BALANCE.localized
        lblAvailBalanceValue.text = /(0.0).getFormattedPrice()
        lblTransactionHistory.text = VCLiteral.TRANSACTION_HISTORY.localized
        btnPayOut.setTitle(VCLiteral.PAYOUT.localized, for: .normal)
        btnAddMoney.setTitle(VCLiteral.ADD_MONEY.localized, for: .normal)
        #if HealthCarePrashantExpert || AirDocExpert || CloudDocPro || HomeDoctorKhalidExperts
        btnAddMoney.isHidden = true
        #else
        btnAddMoney.isHidden = false
        #endif
    }
    
    private func getTransactionHistoryAPI(isRefreshing: Bool? = false) {
        EP_Home.transactionHistory(transactionType: .all, after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
            let response = responseData as? TransactionData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.payments ?? []
            } else {
                self?.items = (self?.items ?? []) + (response?.payments ?? [])
            }
            /self?.items.count == 0 ? self?.showVCPlaceholder(type: .NoTransactions, scrollView: self?.tableView) : ()
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /self?.items.count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
    
    private func getWalletBalanceAPI() {
        EP_Home.wallet.request(success: { [weak self] (responseData) in
            self?.walletBalance = (responseData as? WalletBalance)?.balance
            self?.lblAvailBalanceValue.text = /self?.walletBalance?.getFormattedPrice()
        }) { (error) in

        }
    }
}
