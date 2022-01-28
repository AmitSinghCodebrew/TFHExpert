//
//  NotificationsVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class NotificationsVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<NotificationModel>, DefaultCellModel<NotificationModel>, NotificationModel>?
    private var items: [NotificationModel]?
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
extension NotificationsVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.NOTIFICATIONS.localized
    }
    
    private func tableViewInit() {
        dataSource = TableDataSource<DefaultHeaderFooterModel<NotificationModel>, DefaultCellModel<NotificationModel>, NotificationModel>.init(.SingleListing(items: items ?? [], identifier: NotificationCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView, true)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? NotificationCell)?.item = item
        }
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getNotificationsAPI(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getNotificationsAPI()
            }
        }
        
        dataSource?.didSelectRow = { [weak self] (indexPath, item) in
            switch item?.property?.model?.pushType ?? .UNKNOWN {
            case .chat:
                let destVC = Storyboard<ChatVC>.Other.instantiateVC()
                destVC.thread = ChatThread.init(item?.property?.model)
                self?.pushVC(destVC)
            case .NEW_REQUEST,
                 .REQUEST_COMPLETED,
                 .CANCELED_REQUEST,
                 .REQUEST_FAILED,
                 .RESCHEDULED_REQUEST,
                 .UPCOMING_APPOINTMENT,
                 .PATIENT_ADDED_SYMPTOMS,
                 .PAID_EXTRA_PAYMENT,
                 .USER_AVAILABLE,
                 .REQUEST_EXTRA_PAYMENT:
                let destVC = Storyboard<ApptDetailVC>.Other.instantiateVC()
                destVC.requestID = item?.property?.model?.module_id
                self?.pushVC(destVC)
            case .PROFILE_APPROVED:
                break
            case .PROFILE_REJECTED:
                let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
                
            case .DOCUMENT_REJECTED:
                let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
                
            case .AMOUNT_RECEIVED,
                 .PAYOUT_PROCESSED,
                 .PAYOUT_FAILED,
                 .BALANCE_ADDED,
                 .BALANCE_FAILED:
                self?.popTo(toControllerType: NavigationTabVC.self)
                self?.tabBarController?.selectedIndex = 1
                ((self?.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: WalletVC.self)}) as? WalletVC)?.dataSource?.refreshProgrammatically()
            case .ASSINGED_USER:
                self?.pushVC(Storyboard<ClassesVC>.Other.instantiateVC())
            case .UNKNOWN:
                break
            case .CALL_CANCELED, .CALL_ACCEPTED, .CALL_RINGING, .BOOKING_REQUEST:
                break
            }
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func getNotificationsAPI(isRefreshing: Bool? = false) {
        
        EP_Home.notifications(after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
            let response = (responseData as? NotificationData)
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.notifications
            } else {
                self?.items = (self?.items ?? []) + (response?.notifications ?? [])
            }
            /self?.items?.count == 0 ? self?.showVCPlaceholder(type: .NoNotifications, scrollView: self?.tableView) : ()
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.dataSource?.updateAndReload(for: .SingleListing(items: self?.items ?? []), .FullReload)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /self?.items?.count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.tableView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
}
