//
//  PregnancyCalulator.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 09/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class PregnancyCalculatorVC: BaseVC {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCalculationMethod: UILabel!
    @IBOutlet weak var btnLastPeriod: UIButton!
    @IBOutlet weak var btnConceptionDate: UIButton!
    @IBOutlet weak var btnIVF: UIButton!
    @IBOutlet weak var btnUltrasound: UIButton!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var lblCycleLength: UILabel!
    @IBOutlet weak var tfCycleLength: UITextField!
    @IBOutlet weak var lblIVFTransferDate: UILabel!
    @IBOutlet weak var btn3Day: UIButton!
    @IBOutlet weak var btn5Day: UIButton!
    @IBOutlet weak var tfWeeks: UITextField!
    @IBOutlet weak var tfDays: UITextField!
    @IBOutlet weak var viewUltrasound: UIView!
    @IBOutlet weak var viewIVF: UIView!
    @IBOutlet weak var viewLastPeriod: UIView!
    @IBOutlet weak var btnCalculate: SKButton!
    
    private var calculationType: CalculationMethod = .LastPeriod
    private var transferDateType: IVF_TransferDateType = .ThreeDays
    private var commonDate: Date?
    private var ultrasoundWeek: UltrasoundWeek? = .One
    private var ultrasoundDays: UltrasoundDay? = .Zero
    private var cycleLength: CycleLength? = .NA
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //BACK
            popVC()
        case 1, 2, 3, 4: //CalculationMethod
            calculationType = CalculationMethod(rawValue: sender.tag) ?? .LastPeriod
            selectCalculationType(sender: sender)
        case 5, 6: //IVF 3 Days // 5 Days
            transferDateType = sender.tag == 5 ? .ThreeDays : .FiveDays
            selectIVFDayType(sender: sender)
        case 7: //Calculate
            if commonDate == nil {
                btnCalculate.vibrate()
                return
            }
            var pregnancyDueDate: Date?
            switch calculationType {
            case .LastPeriod:
                pregnancyDueDate = calculateViaLastPeriod()
            case .ConceptionDate:
                pregnancyDueDate = calculateViaConceptionDate()
            case .IVF:
                pregnancyDueDate = calculateViaIVF()
            case .Ultrasound:
                pregnancyDueDate = calculateViaUltrasound()
            }
            let destVC = Storyboard<PregnantSuccessPopUpVC>.PopUp.instantiateVC()
            destVC.modalPresentationStyle = .overFullScreen
            destVC.dueDate = pregnancyDueDate
            presentVC(destVC)
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension PregnancyCalculatorVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.HEALTH_TOOL_04_TITLE.localized
        lblCalculationMethod.text = VCLiteral.CALCULATION_METHOD.localized
        btnLastPeriod.setTitle(VCLiteral.LAST_PERIOD.localized, for: .normal)
        btnConceptionDate.setTitle(VCLiteral.CONCEPTION_DATE.localized, for: .normal)
        btnIVF.setTitle(VCLiteral.IVF.localized, for: .normal)
        btnUltrasound.setTitle(VCLiteral.ULTRASOUND.localized, for: .normal)
        selectCalculationType(sender: btnLastPeriod)
        tfDate.placeholder = VCLiteral.DATE_ONLY_PLACEHOLDER.localized
        lblCycleLength.text = VCLiteral.CYCLE_LENGTH.localized
        tfCycleLength.placeholder = VCLiteral.CYCLE_LENGTH.localized
        lblIVFTransferDate.text = VCLiteral.IVF_TRANSFER_DATE.localized
        btn3Day.setTitle(VCLiteral.IVF_3_DAY.localized, for: .normal)
        btn5Day.setTitle(VCLiteral.IVF_5_DAY.localized, for: .normal)
        tfWeeks.placeholder = VCLiteral.ULTRASOUND_WEEKS.localized
        tfDays.placeholder = VCLiteral.ULTRASOUND_DAYS.localized
        btnCalculate.setTitle(VCLiteral.CALUCLATE_DUE_DATE.localized, for: .normal)
        tfDate.inputView = SKDatePicker.init(frame: CGRect.zero, maxDate: nil, minDate: nil, configureDate: { [weak self] (date) in
            self?.commonDate = date
            self?.tfDate.text = date.toString(DateFormat.custom("MMM d, yyyy"), isForAPI: false)
        })
        tfWeeks.inputView = SKGenericPicker<UltraWeek>.init(frame: CGRect.zero, items: UltraWeek.getArray(), configureItem: { [weak self] (week) in
            self?.ultrasoundWeek = week?.model
            self?.tfWeeks.text = /week?.model?.title.localized
        })
        
        tfDays.inputView = SKGenericPicker<UltraDay>.init(frame: CGRect.zero, items: UltraDay.getArray(), configureItem: { [weak self] (day) in
            self?.ultrasoundDays = day?.model
            self?.tfDays.text = /day?.model?.title.localized
        })
        
        tfCycleLength.inputView = SKGenericPicker<PeriodCycle>.init(frame: CGRect.zero, items: PeriodCycle.getArray(), configureItem: { (periodCycle) in
            self.cycleLength = periodCycle?.model
            self.tfCycleLength.text = /periodCycle?.model?.title.localized
        })
    }
    
    private func selectCalculationType(sender: UIButton) {
        commonDate = nil
        tfDate.text = nil
        [btnLastPeriod, btnConceptionDate, btnIVF, btnUltrasound].forEach { (btn) in
            btn?.backgroundColor = .clear
            btn?.borderColor = ColorAsset.appTint.color
            btn?.borderWidth = 1.0
            btn?.setTitleColor(ColorAsset.appTint.color, for: .normal)
        }
        sender.backgroundColor = ColorAsset.appTint.color
        sender.setTitleColor(ColorAsset.txtWhite.color, for: .normal)
        
        switch calculationType {
        case .ConceptionDate:
            viewLastPeriod.isHidden = true
            viewIVF.isHidden = true
            viewUltrasound.isHidden = true
            lblDateTitle.text = VCLiteral.DATE_OF_CONCEPTION.localized
        case .LastPeriod:
            cycleLength = .NA
            tfCycleLength.text = /cycleLength?.title.localized
            viewLastPeriod.isHidden = false
            viewIVF.isHidden = true
            viewUltrasound.isHidden = true
            lblDateTitle.text = VCLiteral.FIRST_DAY_OF_LAST_PERIOD.localized
        case .IVF:
            viewLastPeriod.isHidden = true
            viewIVF.isHidden = false
            viewUltrasound.isHidden = true
            lblDateTitle.text = VCLiteral.DATE_OF_TRANSFER.localized
            transferDateType = .ThreeDays
            selectIVFDayType(sender: btn3Day)
        case .Ultrasound:
            ultrasoundWeek = .One
            tfWeeks.text = /ultrasoundWeek?.title.localized
            ultrasoundDays = .Zero
            tfDays.text = /ultrasoundDays?.title.localized
            viewLastPeriod.isHidden = true
            viewIVF.isHidden = true
            viewUltrasound.isHidden = false
            lblDateTitle.text = VCLiteral.DATE_OF_ULTRSOUND.localized
        }
    }
    
    private func selectIVFDayType(sender: UIButton) {
        [btn3Day, btn5Day].forEach { (btn) in
            btn?.backgroundColor = .clear
            btn?.borderColor = ColorAsset.appTint.color
            btn?.borderWidth = 1.0
            btn?.setTitleColor(ColorAsset.appTint.color, for: .normal)
        }
        sender.backgroundColor = ColorAsset.appTint.color
        sender.setTitleColor(ColorAsset.txtWhite.color, for: .normal)
    }
    
    private func calculateViaLastPeriod() -> Date? {
        let firstDayOfLastPeriod = commonDate
        //Adding 40weeks or 280 days
        let afterAdding280Days = firstDayOfLastPeriod?.dateByAddingWeeks(40)
        switch cycleLength {
        case .NA: //Period cycle not known
            return afterAdding280Days
        case .Days_21:
            //Default menstural cycle 21 days then subtract 7 days
            let newDate = afterAdding280Days?.dateBySubtractingDays(7)
            return newDate
        default: //Period Cycle Range 22 to 35 days
            //if mestural cycle is more than 21 days than subtract your menstural cycle days count by 21 (default menstural cycle)
            //And add it to date generated by adding 40 weeks
            let daysToAdd = /cycleLength?.rawValue - 21
            let newDate = afterAdding280Days?.dateBySubtractingDays(7)
            let finalDate = newDate?.dateByAddingDays(daysToAdd)
            return finalDate
        }
    }
    
    private func calculateViaConceptionDate() -> Date? {
        //Add 266 days to conception date
        return commonDate?.dateByAddingDays(266)
    }
    
    private func calculateViaIVF() -> Date? {
        switch transferDateType {
        case .ThreeDays: //Embryo Age 3 days
            return commonDate?.dateByAddingDays(266).dateBySubtractingDays(3)
        case .FiveDays: //Embryo Age 5 days
            return commonDate?.dateByAddingDays(266).dateBySubtractingDays(5)
        }
    }
    
    private func calculateViaUltrasound() -> Date? {
        let pregnancyDays = 280
        let ultrasoundDate = commonDate
        let embryoAge = (/ultrasoundWeek?.rawValue * 7) + (/ultrasoundDays?.rawValue)
        let daysToAdd = pregnancyDays - embryoAge
        let predictedDate = ultrasoundDate?.dateByAddingDays(daysToAdd)
        return predictedDate
    }
}
