//
//  ApptDetailVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ApptDetailVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(HomeHeaderView.identfier)
            #if NurseLynxExpert
            tableView.registerXIBForHeaderFooter(CarePlanHeaderView.identfier)
            #endif
        }
    }
    public var request: Requests? {
        didSet {
            requestID = request?.id
        }
    }
    var requestID: Int?
    private var items: [ApptDetailHeader]?
    private var dataSource: TableDataSource<ApptDetailHeader, AppDetailCellModel, ApptDetailData>?
    var requestUpdated: ((_ request: Requests?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.shared.connect(nil)
        lblTitle.text = VCLiteral.DETAILS.localized
        tableViewInit()
        LocationManager.shared.startTrackingUser()
        if let _ = requestID {
            getApptDetailAPI()
        }
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch /sender.title(for: .normal) {
        default: //Back
            popVC()
        }
    }
}

//MARK:- VCFuncs
extension ApptDetailVC {
    
    public func refreshViaNotification() {
        requestID = request?.id
        getApptDetailAPI()
    }
    
    private func tableViewInit() {
        
        tableView.contentInset.bottom = 16.0
        
        dataSource = TableDataSource<ApptDetailHeader, AppDetailCellModel, ApptDetailData>.init(.MultipleSection(items: ApptDetailHeader.getArray(request: request)), tableView, false)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? ApptShortCell)?.item = item
            (cell as? ApptShortCell)?.didReloadCell = { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                self?.requestUpdated?(item?.property?.model?.request)
            }
            (cell as? ApptShortCell)?.updateApptDetail = { [weak self] in
                self?.getApptDetailAPI()
            }
            (cell as? ApptShortCell)?.extraPaymentRequested = { [weak self] (extraPayment) in
                self?.request?.extra_payment = extraPayment
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: ApptDetailHeader.getArray(request: self?.request)), .FullReload)
            }
            (cell as? ExtraPaymentCell)?.item = item
            (cell as? ApptDetailCollCell)?.item = item
            (cell as? SymptomInfoCell)?.item = item
            (cell as? MedicalRecordCell)?.item = item
            #if CloudDocPro
            (cell as? QuestionAnswerCell)?.item = item
            #elseif NurseLynxExpert
            (cell as? ApptDetailCarePlanCell)?.item = item
            (cell as? ApptDetailCarePlanCell)?.reloadCell = { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            #endif
        }
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? HomeHeaderView)?.item2 = item
            #if NurseLynxExpert
            (view as? CarePlanHeaderView)?.item = item
            #endif
        }
    }
    
    private func getApptDetailAPI() {
        playLineAnimation()
        EP_Home.requestDetail(requestId: requestID).request { [weak self] (responseData) in
            self?.stopLineAnimation()
            self?.request = responseData as? Requests
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: ApptDetailHeader.getArray(request: self?.request)), .FullReload)
            self?.requestUpdated?(self?.request)
        } error: { [weak self] (error) in
            self?.stopLineAnimation()
        }
    }
}
