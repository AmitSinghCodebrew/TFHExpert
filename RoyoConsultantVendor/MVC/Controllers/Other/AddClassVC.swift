//
//  AddClassVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 12/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class AddClassVC: BaseVC {
    //MARK:- IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfClassName: JVFloatLabeledTextField!
    @IBOutlet weak var tfClassDate: JVFloatLabeledTextField!
    @IBOutlet weak var tfClassTime: JVFloatLabeledTextField!
    @IBOutlet weak var tfPrice: JVFloatLabeledTextField!
    @IBOutlet weak var btnAdd: SKButton!
    
    //MARK:- Properties
    private var selectedDate: Date?
    private var selectedTime: Date?
    
    public var didAddedClass: (() -> Void)?
    
    //MARK:- VC-Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
    }
    
    //MARK:- IBActions
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Back
            popVC()
        case 1: // Add
            view.endEditing(true)
            let isValid = Validation.shared.validate(values: (.CLASS_NAME, /tfClassName.text),
                                                     (.SELECT_DATE, /tfClassDate.text),
                                                     (.SELECT_TIME, /tfClassTime.text),
                                                     (.CLASS_PRICE, /tfPrice.text))
            switch isValid {
            case .success:
                addClassAPI()
            case .failure(let type, let message):
                btnAdd.vibrate()
                Toast.shared.showAlert(type: type, message: message.localized)
            }
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension AddClassVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.ADD_CLASS.localized
        tfClassName.setPlaceholder(VCLiteral.CLASS_NAME.localized, floatingTitle: VCLiteral.CLASS_NAME.localized)
        tfClassDate.setPlaceholder(VCLiteral.SELECT_DATE.localized, floatingTitle: VCLiteral.SELECT_DATE.localized)
        tfClassTime.setPlaceholder(VCLiteral.SELECT_TIME.localized, floatingTitle: VCLiteral.SELECT_TIME.localized)
        tfPrice.setPlaceholder(VCLiteral.PRICE_OF_CLASS.localized, floatingTitle: VCLiteral.PRICE_OF_CLASS.localized)
        btnAdd.setTitle(VCLiteral.ADD_CLASS.localized, for: .normal)
    
        tfClassDate.inputView = SKDatePicker.init(frame: CGRect.zero, mode: .date, maxDate: nil, minDate: Date().dateByAddingMinutes(30), configureDate: { [weak self] (selectedDate) in
            self?.selectedDate = selectedDate
            self?.tfClassDate.text = selectedDate.toString(DateFormat.custom("MMM d, yyyy"), timeZone: .local, isForAPI: false)
        })
        
        tfClassTime.inputView = SKDatePicker.init(frame: CGRect.zero, mode: .time, maxDate: nil, minDate: nil, configureDate: { [weak self] (selectedTime) in
            self?.selectedTime = selectedTime
            self?.tfClassTime.text = selectedTime.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
        })
    }
    
    private func addClassAPI() {
        btnAdd.playAnimation()
        EP_Home.addClass(categoryId: String(/UserPreference.shared.data?.categoryData?.id), price: tfPrice.text, date: selectedDate?.toString(DateFormat.custom("yyyy-MM-dd"), timeZone: .utc, isForAPI: true), time: selectedTime?.toString(DateFormat.custom("HH:mm"), timeZone: .utc, isForAPI: true), name: tfClassName.text).request(success: { [weak self] (responseData) in
            self?.btnAdd.stop()
            self?.didAddedClass?()
            self?.popVC()
        }) { [weak self] (_) in
            self?.btnAdd.stop()
        }
    }
}
