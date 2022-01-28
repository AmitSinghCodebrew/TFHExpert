//
//  ClassesVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 11/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ClassesVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    private var items: [ClassObj]?
    private var after: String?
    public var dataSource: TableDataSource<DefaultHeaderFooterModel<ClassObj>, DefaultCellModel<ClassObj>, ClassObj>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        tableViewInit()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        let destVC = Storyboard<AddClassVC>.Other.instantiateVC()
        destVC.didAddedClass = { [weak self] in
            self?.dataSource?.refreshProgrammatically()
        }
        pushVC(destVC)
    }
}

//MARK:- VCFuncs
extension ClassesVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.CLASSES.localized
        btnAdd.setTitle(VCLiteral.ADD_NEW.localized, for: .normal)
    }
    
    private func tableViewInit() {
        
        tableView.contentInset.top = 12
        
        dataSource = TableDataSource<DefaultHeaderFooterModel<ClassObj>, DefaultCellModel<ClassObj>, ClassObj>.init(.SingleListing(items: items ?? [], identifier: ClassCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, true)
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getClassesAPI(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getClassesAPI(isRefreshing: false)
            }
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? ClassCell)?.item = item
            (cell as? ClassCell)?.reloadCell = { [weak self] (classObj) in
                self?.items?[indexPath.row] = classObj!
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func getClassesAPI(isRefreshing: Bool? = false) {
        EP_Home.classes(type: .VENDOR_ADDED, categoryId: nil, after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
            let response = responseData as? ClassesData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.classes
            } else {
                self?.items = (self?.items ?? []) + (response?.classes ?? [])
            }
            /self?.items?.count == 0 ? self?.showVCPlaceholder(type: .NoClasses, scrollView: self?.tableView) : ()
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            self?.stopLineAnimation()
            if /self?.items?.count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
}
