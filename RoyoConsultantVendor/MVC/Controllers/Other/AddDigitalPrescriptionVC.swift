//
//  AddDigitalPrescriptionVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 07/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class AddDigitalPrescriptionVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.registerXIBForHeaderFooter(DosageFooterView.identfier)
            tableView.registerXIBForHeaderFooter(MedicineHeaderView.identfier)
        }
    }
    @IBOutlet weak var lblPatient: UILabel!
    @IBOutlet weak var imgVIewPatient: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPatientInfo: UILabel!
    @IBOutlet weak var lblAppt: UILabel!
    @IBOutlet weak var lblApptDate: UILabel!
    @IBOutlet weak var tfMedicineName: JVFloatLabeledTextField!
    @IBOutlet weak var tfDuration: JVFloatLabeledTextField!
    @IBOutlet weak var tfDosageType: JVFloatLabeledTextField!
    @IBOutlet weak var lblDosageTimings: UILabel!
    @IBOutlet weak var lblPrescriptionNotes: UILabel!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var btnDone: SKButton!
    
    public var didAddedPrescription: (() -> Void)?
    public var appt: Requests?
    private var dataSource: TableDataSource<DigitalPresHeaderFooterProvider, DigitalPresCellProvider, DigitalPresCellModel>?

    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        apptDataSetup()
        tableViewInit()
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Back
            popVC()
        case 1: // Done
            if /dataSource?.getMultipleSectionItems().filter({$0.footerProperty == nil}).first?.items?.count == 0 {
                Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.MEDICINCE_DONE_ALERT.localized)
                btnDone.vibrate()
                return
            }
            addPrescriptionAPI()
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension AddDigitalPrescriptionVC {
    private func localizedTextSetup() {
        lblTitle.text = /appt?.pre_scription?.medicines?.count == 0 ? VCLiteral.ADD_DIGITAL_PRESC.localized : VCLiteral.EDIT_DIGITAL_PRESC.localized
        lblPatient.text = VCLiteral.PATIENT.localized
        lblAppt.text = VCLiteral.APPOINTMENT.localized
        btnDone.setTitle(VCLiteral.DONE.localized, for: .normal)
        tfMedicineName.placeholder = VCLiteral.MEDICINE_NAME.localized
        tfDuration.placeholder = VCLiteral.DURATION.localized
        tfDosageType.placeholder = VCLiteral.DOSAGE_TYPE.localized
        lblDosageTimings.text = VCLiteral.DOSAGE_TIMINGS.localized
        lblPrescriptionNotes.text = VCLiteral.PRESCRIPTION_NOTES.localized
        tvNotes.text = /appt?.pre_scription?.pre_scription_notes
    }
    
    private func apptDataSetup() {
        lblName.text = /appt?.from_user?.name
        let utcDate = Date(fromString: /appt?.bookingDateUTC, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
        lblApptDate.text = utcDate.toString(DateFormat.custom("dd MMM yyyy · hh:mm a"), timeZone: .local, isForAPI: false)
        imgVIewPatient.setImageNuke(/appt?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        if /appt?.from_user?.phone != "" {
            lblPatientInfo.text = /appt?.from_user?.country_code + "-" + /appt?.from_user?.phone
        } else {
            lblPatientInfo.text = /appt?.from_user?.email
        }
        
        tfDuration.inputView = SKGenericPicker<DurationDay>.init(frame: CGRect.zero, items: DurationDay.getArray(), configureItem: { [weak self] (day) in
            self?.tfDuration.text = /day?.model
        })
        
        tfDosageType.inputView = SKGenericPicker<DosageType>.init(frame: CGRect.zero, items: DosageType.getDosageTypes(), configureItem: { [weak self] (dosageType) in
            self?.tfDosageType.text = /dosageType?.model?.localized
            let tempItems = self?.dataSource?.getMultipleSectionItems()
            tempItems?.first?.items?.forEach({ (cell) in
                cell.property?.model?.dosageType = dosageType
                cell.property?.model?.doseTime?.dose_value = /dosageType?.getRelatedDosageValues().first?.title
            })
            self?.dataSource?.updateAndReload(for: .MultipleSection(items: tempItems ?? []), .FullReload)
        })
    }
    
    private func tableViewInit() {
        dataSource = TableDataSource<DigitalPresHeaderFooterProvider, DigitalPresCellProvider, DigitalPresCellModel>.init(.MultipleSection(items: DigitalPresHeaderFooterProvider.getArray(request: appt)), tableView, false)
        
        dataSource?.configureHeaderFooter = { (section, item, view) in
            (view as? DosageFooterView)?.item = item
            (view as? DosageFooterView)?.didTapAdd = { [weak self] in
                self?.addMedicine(indexPath: item.footerProperty?.model?.indexPath)
            }
            (view as? DosageFooterView)?.didReset = { [weak self] in
                self?.resetData()
            }
            (view as? MedicineHeaderView)?.item = item
        }
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? DosageTypeCell)?.item = item
            (cell as? DosageTypeCell)?.reloadCell = { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            (cell as? MedicineCell)?.item = item
            (cell as? MedicineCell)?.didTapEdit = { [weak self] in
                self?.setupEditMedicineData(item?.property?.model?.prescription, indexPath: indexPath)
            }
            (cell as? MedicineCell)?.didTapDelete = { [weak self] in
                let oldItems = self?.dataSource?.getMultipleSectionItems()
                var cells = oldItems?[indexPath.section].items
                cells?.remove(at: indexPath.row)
                oldItems?[indexPath.section].items = cells
                self?.dataSource?.updateAndReload(for: .MultipleSection(items: oldItems ?? []), .DeleteRowsAt(indexPaths: [indexPath], animation: .automatic))
            }
        }
    }
    
    private func addMedicine(indexPath: IndexPath?) {
        // if indexpath is not nil then user is editing medicine
        
        if /tfMedicineName.text?.trimmingCharacters(in: .whitespaces) == "" {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.MEDICINE_ALERT.localized)
            return
        } else if /tfDuration.text?.trimmingCharacters(in: .whitespaces) == "" {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DURATION_ALERT.localized)
            return
        } else if /tfDosageType.text?.trimmingCharacters(in: .whitespaces) == "" {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOSAGE_ALERT.localized)
            return
        }
        
        var oldItems = self.dataSource?.getMultipleSectionItems() ?? []
        
        let timings = oldItems.first?.items?.compactMap({$0.property?.model?.doseTime}).filter({/$0.isSelected})
        
        if /timings?.count == 0 {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOSAGE_TIMING_ALERT.localized)
            return
        }

        let prescription = Prescription.init(tfMedicineName.text, tfDuration.text, tfDosageType.text, timings: timings)
        
        if let index = indexPath {
            oldItems.last?.items?[index.row].property?.model?.prescription = prescription
            dataSource?.updateAndReload(for: .MultipleSection(items: oldItems), .Reload(indexPaths: [index], animation: .automatic))
        } else if /oldItems.count == 2 {
            oldItems.last?.items?.append(DigitalPresCellProvider.init((MedicineCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(nil, prescription, nil)), nil, nil))
            dataSource?.updateAndReload(for: .MultipleSection(items: oldItems), .FullReload)
        } else {
            let section = DigitalPresHeaderFooterProvider.init((MedicineHeaderView.identfier, 48.0, DigitalHeaderModel.init(.PRESCRIPTIONS)), nil, [DigitalPresCellProvider.init((MedicineCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(nil, prescription, nil)), nil, nil)])
            oldItems.append(section)
            dataSource?.updateAndReload(for: .MultipleSection(items: oldItems), .FullReload)
        }
        resetData()
    }
    
    private func setupEditMedicineData(_ presecription: Prescription?, indexPath: IndexPath) {
        tfMedicineName.text = /presecription?.medicine_name
        tfDuration.text = /presecription?.duration
        tfDosageType.text = /presecription?.dosage_type
        
        var oldItems = dataSource?.getMultipleSectionItems()
        oldItems?[0] = DigitalPresHeaderFooterProvider.getDosageTimeSection(for: presecription, indexPath: indexPath)
        dataSource?.updateAndReload(for: .MultipleSection(items: oldItems ?? []), .FullReload)
    }
    
    private func resetData() {
        tfDuration.text = nil
        tfMedicineName.text = nil
        tfDosageType.text = nil
        
        var oldItems = self.dataSource?.getMultipleSectionItems() ?? []
        oldItems[0] = (DigitalPresHeaderFooterProvider.getArray(request: nil))[0]
        dataSource?.updateAndReload(for: .MultipleSection(items: oldItems), .FullReload)
    }
    
    private func addPrescriptionAPI() {
        btnDone.playAnimation()
    
        let prescriptions = dataSource?.getMultipleSectionItems().last?.items?.compactMap({$0.property?.model?.prescription}) ?? []
        let json = JSONHelper<[Prescription]>().toDictionary(model: prescriptions)
        
        EP_Home.addPrescriptions(request_id: appt?.id, type: .digital, pre_scription_notes: /tvNotes.text, title: nil, image: nil, pre_scriptions: json).request(success: { [weak self] (responseData) in
            self?.btnDone.stop()
            self?.didAddedPrescription?()
            self?.popVC()
        }) { [weak self] (error) in
            self?.btnDone.stop()
        }
    }
}
