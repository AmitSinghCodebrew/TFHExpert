//
//  ServiceTypeHeaderView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 30/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ServiceTypeHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = ServiceHeaderProvider
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var switchToggle: UISwitch!
    
    var didSwitchToggled: ((_ value: CustomBool, _ service: Service?) -> Void)?
    
    var item: ServiceHeaderProvider?  {
        didSet {
            lblTitle.text = /item?.headerProperty?.model?.service?.name
            switchToggle.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
            switchToggle.setOn(/(item?.headerProperty?.model?.service?.available == .TRUE), animated: false)
        }
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        item?.headerProperty?.model?.service?.available = sender.isOn ? .TRUE : .FALSE
        didSwitchToggled?(sender.isOn ? .TRUE : .FALSE, item?.headerProperty?.model?.service)
    }
}
