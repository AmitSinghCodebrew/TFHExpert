//
//  AvailabilityTimeSlotCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AvailabilityTimeSlotCell: UITableViewCell, ReusableCell {
    
    typealias T = AvailabilityCellProvider
    
    @IBOutlet weak var lblFrom: UILabel!
    @IBOutlet weak var tfFrom: UITextField!
    @IBOutlet weak var lblTo: UILabel!
    @IBOutlet weak var tfTo: UITextField!
    @IBOutlet weak var btnDelete: UIButton!
    
    public var didTapDelete: (() -> Void)?
    
    var item: AvailabilityCellProvider? {
        didSet {
            let slot = item?.property?.model?.timeSlot
            lblFrom.text = VCLiteral.FROM.localized
            lblTo.text = VCLiteral.TO.localized
            tfFrom.text = /slot?.startTime?.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
            tfTo.text = /slot?.endTime?.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
            
            let interVal = /Int(/UserPreference.shared.clientDetail?.slot_duration)
            
            tfFrom.inputView = SKDatePicker.init(frame: CGRect.zero, mode: .time, maxDate: nil, minDate: nil, interval: interVal, configureDate: { [weak self] (date) in
                self?.tfFrom.text = date.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
                self?.item?.property?.model?.timeSlot?.startTime = date
                (self?.tfTo.inputView as? SKDatePicker)?.minimumDate = date
            })

            tfTo.inputView = SKDatePicker.init(frame: CGRect.zero, mode: .time, maxDate: nil, minDate: nil, interval: interVal, configureDate: { [weak self] (date) in
                self?.tfTo.text = date.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
                self?.item?.property?.model?.timeSlot?.endTime = date
                (self?.tfFrom.inputView as? SKDatePicker)?.maximumDate = date
            })
            
            btnDelete.isHidden = /slot?.isFirstItem
        }
    }
    
    @IBAction func btnDeleteAction(_ sender: UIButton) {
        didTapDelete?()
    }
    
}
