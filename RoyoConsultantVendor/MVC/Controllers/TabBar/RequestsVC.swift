//
//  RequestsVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class RequestsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionFilters: UICollectionView!
    
    public var dataSource: TableDataSource<HomeSectionProvider, HomeCellProvider, HomeCellModel>?
    private var items: [Requests]?
    private var after: String?
    private var currentSelectedDate: Date?
    public var isSecondOpinion: Bool = false
    private var services: [Service]? = UserPreference.shared.data?.services
    private var collectionDataSource: CollectionDataSource?
    private var serviceId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        services?.insert(Service.init(VCLiteral.All_SMALL.localized), at: 0)
        localizedTextSetup()
        tableViewInit()
        collectionFiltersInit()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func btnDateAction(_ sender: UIButton) {
        var datePickerDate = currentSelectedDate
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        let datePicker = SKDatePicker.init(frame: CGRect.zero, maxDate: nil, minDate: nil, configureDate: { (selectedDate) in
            datePickerDate = selectedDate
        })
        datePicker.date = currentSelectedDate ?? Date()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        actionSheet.view.addSubview(datePicker)
        actionSheet.view.heightAnchor.constraint(equalToConstant: 400).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: actionSheet.view.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: actionSheet.view.trailingAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: actionSheet.view.topAnchor, constant: 10).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: actionSheet.view.bottomAnchor, constant: -100).isActive = true
        actionSheet.addAction(UIAlertAction.init(title: VCLiteral.DONE.localized, style: UIDevice.current.userInterfaceIdiom == .pad ? .default : .cancel, handler: { [weak self] (_) in
            self?.currentSelectedDate = datePickerDate ?? Date()
            self?.btnDate.setTitle(/self?.currentSelectedDate?.toString(DateFormat.custom("MMM dd, yyyy"), timeZone: .local, isForAPI: false), for: .normal)
            self?.dataSource?.refreshProgrammatically()
        }))
        actionSheet.addAction(UIAlertAction.init(title: VCLiteral.RESET_DATE.localized, style: .destructive, handler: { [weak self] (_) in
            self?.currentSelectedDate = nil
            self?.btnDate.setTitle(VCLiteral.SELECT_DATE.localized, for: .normal)
            self?.dataSource?.refreshProgrammatically()
        }))
        actionSheet.popoverPresentationController?.sourceView = sender
        
        presentVC(actionSheet)
    }
}

//MARK:- VCFuncs
extension RequestsVC {
    
    private func localizedTextSetup() {
        lblTitle.text = isSecondOpinion ? VCLiteral.SECOND_OPINION.localized : VCLiteral.REQUESTS.localized
        btnDate.setTitle(VCLiteral.SELECT_DATE.localized, for: .normal)
    }
    
    private func collectionFiltersInit() {
        collectionFilters.contentInset.right = 16 * (CGFloat(/services?.count) - 1)
        
        collectionDataSource = CollectionDataSource.init(services, FilterCell.identfier, collectionFilters, CGSize.init(width: 88, height: 36), UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16), 16, 0, .horizontal)
        
        collectionDataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? FilterCell)?.item = item
        }
        
        collectionDataSource?.didSelectItem = { [weak self] (indexPath, item) in
            self?.services?.forEach({$0.isSelected = false})
            self?.services?[indexPath.item].isSelected = true
            self?.serviceId = (item as? Service)?.service_id
            self?.collectionDataSource?.updateData(self?.services)
            self?.playLineAnimation()
            self?.errorView.removeFromSuperview()
            self?.getRequestsAPI(isRefreshing: true)
        }
    }
    
    private func tableViewInit() {
        
        tableView.contentInset.top = -16.0
        
        dataSource = TableDataSource<HomeSectionProvider, HomeCellProvider, HomeCellModel>.init(.MultipleSection(items: []), tableView, true)
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getRequestsAPI(isRefreshing: true)
        }
        
        dataSource?.addInfiniteScrolling = { [weak self] in
            if self?.after != nil {
                self?.getRequestsAPI()
            }
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? AppointmentCell)?.item = item
            (cell as? AppointmentCell)?.reloadTable = { [weak self] in
                self?.items?[indexPath.row] = (item?.property?.model?.request)!
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        dataSource?.didSelectRow = { [weak self] (indexPath, item) in
            let destVC = Storyboard<ApptDetailVC>.Other.instantiateVC()
            destVC.request = item?.property?.model?.request
            destVC.requestUpdated = { (request) in
                self?.items?[indexPath.row] = request!
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: HomeSectionProvider.getApptsWithoutHeader(requests: self?.items ?? [])), .FullReload)
            }
            self?.pushVC(destVC)
        }
        dataSource?.refreshProgrammatically()
    }
    
    private func getRequestsAPI(isRefreshing: Bool? = false) {
        let date = currentSelectedDate == nil ? nil : currentSelectedDate?.toString(DateFormat.custom("yyyy-MM-dd"), timeZone: .local, isForAPI: true)
        EP_Home.requests(date: date, after: /isRefreshing ? nil : after, secondOpinion: String(/isSecondOpinion), service_id: serviceId, status: .all).request(success: { [weak self] (responseData) in
            let response = responseData as? RequestData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.requests ?? []
            } else {
                self?.items = (self?.items ?? []) + (response?.requests ?? [])
            }
            /self?.items?.count == 0 ? self?.showVCPlaceholder(type: .NoRequests, scrollView: self?.tableView) : ()
            self?.stopLineAnimation()
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: HomeSectionProvider.getApptsWithoutHeader(requests: self?.items ?? [])), .FullReload)
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
