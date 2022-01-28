//
//  SelectAvailabilityVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 30/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class SelectAvailabilityVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(AvailabilityHeaderView.identfier)
            tableView.registerXIBForHeaderFooter(AvailabilityFooterView.identfier)
        }
    }
    @IBOutlet weak var btnAllWeekDays: SKBorderButton!
    @IBOutlet weak var btnAllSpecificDate: SKBorderButton!
    @IBOutlet weak var btnAllSpecificDay: SKBorderButton!
    @IBOutlet weak var btnSave: SKButton!
    
    private var dataSource: TableDataSource<AvailibilityHeaderFooterProvider, AvailabilityCellProvider, AvailabilityCellModel>?
    private var items = [AvailibilityHeaderFooterProvider]()
    public var serviceCustom: ServiceCellModel?
    public var didAddedAvailability: ((_ _model: ServiceCellModel?) -> Void)?
    public var categoryID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        items = AvailibilityHeaderFooterProvider.getItems(model: serviceCustom)
        tableViewInit()
        localizedTextSetup()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1, 2, 3, 4: //1-AllWeekdays, 2-All Speocfic date, 3-All Specific day, 4-Save weekwise login time
            let slots = (items[1].items ?? []).compactMap({ $0.property?.model?.timeSlot})
            if slots.first?.startTime == nil || slots.first?.endTime == nil {
                Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.SLOT_ALERT_SAVE.localized)
                return
            }
            serviceCustom?.timeSlots = slots
            switch sender.tag {
            case 1:
                serviceCustom?.applyOption = .weekdays
            case 2:
                serviceCustom?.applyOption = .specific_date
            case 3:
                serviceCustom?.applyOption = .specific_day
            case 4:
                serviceCustom?.applyOption = .weekwise
            default:
                break
            }
            serviceCustom?.weekDays = items.first?.items?.first?.property?.model?.collItems ?? []
            didAddedAvailability?(serviceCustom)
            popVC()
        default:
            break
        }
    }
    
    
}

//MARK:- VCFuncs
extension SelectAvailabilityVC {
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.SELECT_AVAILABILITY.localized
        setTitles(for: Date())
        btnSave.setTitle(VCLiteral.SAVE.localized, for: .normal)
        
        switch serviceCustom?.type ?? .WhileLoginModule {
        case .WhileLoginModule:
            btnAllWeekDays.isHidden = true
            btnAllSpecificDate.isHidden = true
            btnAllSpecificDay.isHidden = true
            btnSave.isHidden = !(/serviceCustom?.weekDays.contains(where: {/$0.isSelected}))
        case .WhileManaging:
            btnAllWeekDays.isHidden = false
            btnAllSpecificDate.isHidden = false
            btnAllSpecificDay.isHidden = false
            btnSave.isHidden = true
            if let dateSelected = (items.first?.items?.first?.property?.model?.collItems ?? []).first(where: {/$0.isSelected})?.date {
                //Get slots api for selected date
                getSlotsAPI(date: dateSelected)
            } else {
                items.first?.items?.first?.property?.model?.collItems?.first?.isSelected = true
                dataSource?.updateAndReload(for: .MultipleSection(items: items), .Reload(indexPaths: [IndexPath.init(row: 0, section: 0)], animation: .none))
                //Get slots api
                getSlotsAPI(date: Date())
            }
        }
    }
    
    private func getSlotsAPI(date: Date?) {
        playLineAnimation()
        view.isUserInteractionEnabled = false
        EP_Home.getSlots(vendor_id: String(/UserPreference.shared.data?.id), date: date?.toString(DateFormat.custom("yyyy-MM-dd"), timeZone: .local, isForAPI: true), service_id: String(/serviceCustom?.service?.service_id), category_id: categoryID).request(success: { [weak self] (responseData) in
            self?.stopLineAnimation()
            var timeSlots = [AvailabilityCellProvider]()
            let slots = (responseData as? SlotsData)?.slots
            if /slots?.count != 0 {
                for (index, slot) in (slots ?? []).enumerated() {
                    timeSlots.append(AvailabilityCellProvider.init((AvailabilityTimeSlotCell.identfier, UITableView.automaticDimension, AvailabilityCellModel.init(TimeSlot.init(slot, index == 0))), nil, nil))
                }
            } else {
                timeSlots.append(AvailabilityCellProvider.init((AvailabilityTimeSlotCell.identfier, UITableView.automaticDimension, AvailabilityCellModel.init(TimeSlot.init(true))), nil, nil))
            }
            self?.items[1].items = timeSlots
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: self?.items ?? []), .ReloadSectionAt(indexSet: IndexSet(integer: 1), animation: .automatic))
            self?.view.isUserInteractionEnabled = true
        }) { [weak self] (error) in
            self?.stopLineAnimation()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    private func setTitles(for date: Date?) {
        btnAllWeekDays.setTitle(VCLiteral.ALL_WEEKDAYS.localized, for: .normal)
        btnAllSpecificDate.setTitle(String.init(format: VCLiteral.FOR_DATE.localized, /date?.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false)), for: .normal)
        btnAllSpecificDay.setTitle(String.init(format: VCLiteral.FOR_DAY.localized, /date?.weekdayToString()), for: .normal)
    }
    
    private func tableViewInit() {
        
        dataSource = TableDataSource<AvailibilityHeaderFooterProvider, AvailabilityCellProvider, AvailabilityCellModel>.init(.MultipleSection(items: items), tableView)
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? AvailabilityHeaderView)?.item = item
            (view as? AvailabilityFooterView)?.item = item
            (view as? AvailabilityFooterView)?.didTapAdd = { [weak self] in
                self?.addNewInterval(section: section)
            }
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? AvailabilityCollCell)?.item = item
            (cell as? AvailabilityCollCell)?.hideUnhideSaveButton = { [weak self] (isHidden) in
                self?.btnSave.isHidden = isHidden
            }
            (cell as? AvailabilityCollCell)?.dateSelected = { [weak self] (date) in
                self?.getSlotsAPI(date: date)
                self?.setTitles(for: date)
            }
            (cell as? AvailabilityTimeSlotCell)?.item = item
            (cell as? AvailabilityTimeSlotCell)?.didTapDelete = { [weak self] in
                self?.deleteInterval(indexPath: indexPath)
            }
        }
    }
    
    private func addNewInterval(section: Int) {
        let previousSlot = items[section].items?.last?.property?.model?.timeSlot
        if previousSlot?.startTime == nil || previousSlot?.endTime == nil {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.NEW_INTERVAL_ALERT.localized)
            return
        }
        
        let newSlot = AvailabilityCellProvider((AvailabilityTimeSlotCell.identfier, UITableView.automaticDimension, AvailabilityCellModel.init(TimeSlot.init(false))), nil, nil)
        items[section].items?.append(newSlot)
        dataSource?.updateAndReload(for: .MultipleSection(items: items), .AddRowsAt(indexPaths: [IndexPath.init(row: /items[section].items?.count - 1, section: section)], animation: .bottom, moveToLastIndex: false))
    }
    
    private func deleteInterval(indexPath: IndexPath) {
        items[indexPath.section].items?.remove(at: indexPath.row)
        dataSource?.updateAndReload(for: .MultipleSection(items: items), .DeleteRowsAt(indexPaths: [indexPath], animation: .automatic))
    }
}
