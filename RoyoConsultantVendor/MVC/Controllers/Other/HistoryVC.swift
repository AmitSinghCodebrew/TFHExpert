//
//  HistoryVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 25/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HistoryVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
        }
    }
    
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<Payment>, DefaultCellModel<Payment>, Payment>?
    private var items = [Payment]()
    private var after: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        tableViewInit()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
}

//MARK:- VCFuncs
extension HistoryVC {
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.HISTORY.localized
    }
    
    private func tableViewInit() {
        dataSource = TableDataSource<DefaultHeaderFooterModel<Payment>, DefaultCellModel<Payment>, Payment>.init(.SingleListing(items: items, identifier: HistoryCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, true)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? HistoryCell)?.item = item
        }
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getTransactionHistoryAPI(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getTransactionHistoryAPI()
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func getTransactionHistoryAPI(isRefreshing: Bool? = false) {
        EP_Home.transactionHistory(transactionType: .deposit, after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
            let response = responseData as? TransactionData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.payments ?? []
            } else {
                self?.items = (self?.items ?? []) + (response?.payments ?? [])
            }
            /self?.items.count == 0 ? self?.showVCPlaceholder(type: .NoHistory, scrollView: self?.tableView) : ()
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
}
