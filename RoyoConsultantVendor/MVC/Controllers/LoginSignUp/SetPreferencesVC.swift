//
//  SetPreferencesVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class SetPreferencesVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(FilterHeaderView.identfier)
        }
    }
    @IBOutlet weak var btnDone: SKButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    public var categoryId: String? = String(/UserPreference.shared.data?.categoryData?.id)
    
    private var dataSource: TableDataSource<FilterHeaderProvider, FilterCellProvider, FilterCustomModel>?
    private var items: [FilterHeaderProvider]?
    public var comingFrom: AvailabilityDataType = .WhileLoginModule
    public var isUpdatingFiltersOnly: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        tableViewInit()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Done
            validateFilters()
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension SetPreferencesVC {
    private func validateFilters() {
        let filters = items.flatMap { (sectionItems) -> [Filter]? in
            let tempItems = (sectionItems.compactMap {$0.items}).flatMap { $0 }
            return tempItems.compactMap({$0.property?.model?.filter})
        }
        
        var isValidValues = true
        
        for filter in (filters ?? []) {
            if !(/filter.options?.contains(where: {/$0.isSelected})) {
                let alertMessage = String.init(format: filter.is_multi == .TRUE ? VCLiteral.SET_PREFERENCES_VALIDATION_ALERT_MULTI.localized : VCLiteral.SET_PREFERENCES_VALIDATION_ALERT_SINGLE.localized, /filter.filter_name?.lowercased())
                Toast.shared.showAlert(type: .validationFailure, message: alertMessage)
                isValidValues = false
                break
            }
            
        }
        
        if isValidValues {
            if isUpdatingFiltersOnly {
                hitAPIToUpdateFilters(filters: filters)
            } else {
                let destVC = Storyboard<ServicesVC>.LoginSignUp.instantiateVC()
                destVC.filters = filters
                destVC.categoryId = categoryId
                destVC.comingFrom = comingFrom
                pushVC(destVC)
            }
        }
    }
    
    private func hitAPIToUpdateFilters(filters: [Filter]?) {
        var filterToSend = [FilterToSend]()
        filters?.forEach({ (filter) in
            if /filter.options?.contains(where: {/$0.isSelected}) {
                let ids = ((filter.options)?.filter({/$0.isSelected}) ?? []).compactMap({/$0.id})
                filterToSend.append(FilterToSend.init(filter.id, ids))
            }
        })
        let jsonFilters = JSONHelper<[FilterToSend]>().toDictionary(model: filterToSend)
        
        btnDone.playAnimation()
        EP_Home.updateServices(categoryId: categoryId, filters: jsonFilters, category_services_type: nil).request(success: { [weak self] (responseData) in
            self?.btnDone.stop()
            self?.popVC()
        }) { [weak self] (_) in
            self?.btnDone.stop()
        }
    }
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.SET_PREFERENCES_TITLE.localized
        btnDone.setTitle(VCLiteral.DONE.localized, for: .normal)
    }
    
    private func tableViewInit() {
        
        dataSource = TableDataSource<FilterHeaderProvider, FilterCellProvider, FilterCustomModel>.init(.MultipleSection(items: items ?? []), tableView, true)
        
        dataSource?.addPullToRefresh = { [weak self] in
            self?.getFiltersAPI()
        }
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? FilterHeaderView)?.item = item
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? FilterCollectionViewCell)?.item = item
        }
        
        dataSource?.refreshProgrammatically()
    }
    
    private func getFiltersAPI() {
        EP_Home.getFilters(categoryId: categoryId, userId: String(/UserPreference.shared.data?.id)).request(success: { [weak self] (responseData) in
            let filters = (responseData as? FilterData)?.filters
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            self?.items = FilterHeaderProvider.getFilters(filters: filters)
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.items ?? []), .FullReload)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
        }
    }
}
