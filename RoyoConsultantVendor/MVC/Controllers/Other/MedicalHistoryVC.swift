//
//  MedicalHistoryVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 13/05/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit
import SZTextView

class MedicalHistoryVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btAddTop: SKLottieButton!
    @IBOutlet weak var btnSubmit: SKButton!
    @IBOutlet weak var btnCancel: SKButton!
    @IBOutlet weak var tvText: SZTextView!
    @IBOutlet weak var viewAddMedicalHistory: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(MedicalHistoryHeaderView.identfier)
            tableView.registerXIBForHeaderFooter(MedicalHistoryFooterView.identfier)
        }
    }

    private var dataSource: TableDataSource<MedicalHistoryHeaderFooterProvider, MedicalHistoryProvider, MedicalHistory>?
    public var requestID: Int?
    public var isHistoryAdded: Bool?
    private var after: String?
    public var didAddedHistory: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        toggleAddHistory(show: false)
        localizedSetup()
        tableViewInit()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //View add info section
            toggleAddHistory(show: true)
        case 2: //Submit
            if /tvText.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                btnSubmit.vibrate()
                return
            }
            addMedicalHistoryAPI()
        case 3: //Cancel
            toggleAddHistory(show: false)
            view.resignFirstResponder()
        default:
            break
        }
    }
}

//MARK: VCFuncs
extension MedicalHistoryVC {
    
    private func toggleAddHistory(show: Bool?) {
        if /isHistoryAdded {
            btAddTop.isHidden = true
            viewAddMedicalHistory.isHidden = true
        } else {
            btAddTop.isHidden = /show
            viewAddMedicalHistory.isHidden = !(/show)
            if /show == false {
                tvText.text = nil
            }
        }
    }

    private func addMedicalHistoryAPI() {
        btnSubmit.playAnimation()
        EP_Home.addMedicalHistory(id: requestID, comment: /tvText.text).request { [weak self] (response) in
            self?.btnSubmit.stop()
            self?.toggleAddHistory(show: false)
            self?.playLineAnimation()
            self?.getHistoryAPI(isRefreshing: true)
            self?.didAddedHistory?()
        } error: { (error) in
            self.btnSubmit.stop()
        }
    }
    
    private func getHistoryAPI(isRefreshing: Bool? = false) {
        errorView.removeFromSuperview()
        EP_Home.getMedicalHistory(request_id: requestID, after: /isRefreshing ? nil : after).request { [weak self] (response) in
            
            let newDoctors = (response as? MedicalHistoryData)?.doctors
            self?.after = (response as? MedicalHistoryData)?.after
            let newItems = MedicalHistoryHeaderFooterProvider.getArray(doctors: newDoctors)
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /isRefreshing {
                self?.errorView.removeFromSuperview()
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: newItems), .FullReload)
                /newItems.count == 0 ? self?.showVCPlaceholder(type: .NoMedicalHistory, scrollView: self?.tableView) : ()
            } else {
                let oldItems = self?.dataSource?.getMultipleSectionItems() ?? []
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: oldItems + newItems), .FullReload)
            }
            self?.dataSource?.stopInfiniteLoading(self?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.stopLineAnimation()
        } error: { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            self?.stopLineAnimation()
            if /self?.dataSource?.getMultipleSectionItems().count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
    
    private func localizedSetup() {
        btAddTop.setTitle(VCLiteral.ADD.localized, for: .normal)
        btnSubmit.setTitle(VCLiteral.SUBMIT.localized, for: .normal)
        btnCancel.setTitle(VCLiteral.CANCEL.localized, for: .normal)
        tvText.placeholder = VCLiteral.MEDICAL_HISTORY_PLACEHOLDER.localized
        lblTitle.text = VCLiteral.MEDICAL_HISTORY.localized
    }
    
    private func tableViewInit() {
        dataSource = TableDataSource<MedicalHistoryHeaderFooterProvider, MedicalHistoryProvider, MedicalHistory>.init(.MultipleSection(items: MedicalHistoryHeaderFooterProvider.getArray(doctors: [])), tableView, true)
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? MedicalHistoryHeaderView)?.item = item
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? MedicalHIstoryDescCell)?.item = item
        }
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getHistoryAPI(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getHistoryAPI(isRefreshing: false)
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
}
