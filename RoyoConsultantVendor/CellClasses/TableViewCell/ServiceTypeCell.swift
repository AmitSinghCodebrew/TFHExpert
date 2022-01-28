//
//  ServiceTypeCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 30/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ServiceTypeCell: UITableViewCell, ReusableCell {
    
    typealias T = ServiceCellProvider
    
    @IBOutlet weak var lblFeeTitle: UILabel!
    @IBOutlet weak var lblForTitle: UILabel!
    @IBOutlet weak var lblPriceType: UILabel!
    @IBOutlet weak var tfFee: UITextField!
    @IBOutlet weak var tfFor: UITextField!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var btnAddEditAvailability: UIButton!
    @IBOutlet weak var tfClinicAddress: UITextField!
    @IBOutlet weak var viewClinic: UIView!
    @IBOutlet weak var lblClinicAddress: UILabel!
    
    var categoryId: String?
    var address: Address?
    var reloadCell: (() -> Void)?
    
    var item: ServiceCellProvider? {
        didSet  {
            let service = item?.property?.model?.service
            lblFeeTitle.text = VCLiteral.CONSULTATION_FEE.localized
            lblForTitle.text = VCLiteral.FOR_UNIT.localized
            
            if item?.property?.model?.type == .WhileManaging {
                btnAddEditAvailability.setTitle(/item?.property?.model?.type?.addAvailabilityTitle.localized, for: .normal)
            } else if item?.property?.model?.timeSlots.first?.startTime == nil {
                btnAddEditAvailability.setTitle(VCLiteral.ADD_AVAILABILITY.localized, for: .normal)
            } else {
                btnAddEditAvailability.setTitle(VCLiteral.MANAGE_AVAILABILITY.localized, for: .normal)
            }
            lblCurrency.text = UserPreference.shared.getCurrencyAbbr()
            lblPriceType.text = /service?.price_type?.getRelatedText(model: service)
            btnAddEditAvailability.isHidden = /(service?.need_availability == .FALSE)
            tfFee.isUserInteractionEnabled = service?.price_type == .price_range
            tfFor.isUserInteractionEnabled = false
            tfFor.text = "\(UserPreference.shared.getCurrencyAbbr()) / \(getUnit(/Int(/service?.unit_price?.getDoubleValue)))"
            tfFee.text = service?.price_type == .price_range ? (/service?.price == 0.0 ? "" : /String(/service?.price)) : String(/service?.price_fixed?.getDoubleValue)
//            tfClinicAddress.placeholder = VCLiteral.CLINIC_ADDRESS.localized
            viewClinic.isHidden = !(/service?.isClinicAddress())
            tfClinicAddress.isEnabled = /service?.isClinicAddress()
            tfClinicAddress.text = /service?.clinic_address?.locationName
            tfClinicAddress.delegate = self
            #if HealthCarePrashantExpert
            viewClinic.isHidden = true
            #endif
        }
    }
    
    @IBAction func btnAddEditAvailabilityAction(_ sender: UIButton) {
        let destVC = Storyboard<SelectAvailabilityVC>.LoginSignUp.instantiateVC()
        if item?.property?.model?.type == .WhileManaging {
            item?.property?.model?.timeSlots = [TimeSlot]()
        }
        destVC.categoryID = categoryId
        destVC.serviceCustom = item?.property?.model
        destVC.didAddedAvailability = { [weak self] (model) in
            self?.item?.property?.model = model
            self?.reloadCell?()
        }
        UIApplication.topVC()?.pushVC(destVC)
    }
    
    @IBAction func tfFeeTextCahnged(_ sender: UITextField) {
        item?.property?.model?.service?.price = /sender.text?.toDouble()
    }
    
    @IBAction func tfForTextChanged(_ sender: UITextField) {
        
    }
    
    func getUnit(_ seconds: Int) -> String {
        if seconds == 60 {
            return VCLiteral.MINUTE.localized
        } else if seconds == 1 {
            return VCLiteral.SECOND.localized
        } else if seconds < 60 {
            return String.init(format: VCLiteral.SECONDS.localized, "\(seconds)")
        } else {
            return String.init(format: VCLiteral.MINUTES.localized, "\(seconds / 60)")
        }
    }
}

//MARK:- UITextFieldDelegate
extension ServiceTypeCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let destVC = Storyboard<AddAddressVC>.Other.instantiateVC()
        destVC.address = address
        destVC.didSelected = { [weak self] (address) in
            let clinicAddress = ClinicAddress()
            clinicAddress.locationName = /address?.name
            clinicAddress.lat = /address?.latitude
            clinicAddress.long = /address?.longitude
            self?.item?.property?.model?.service?.clinic_address = clinicAddress
            self?.tfClinicAddress.text = /address?.name
            self?.address = address
        }
        UIApplication.topVC()?.pushVC(destVC)
        return false
    }
}
