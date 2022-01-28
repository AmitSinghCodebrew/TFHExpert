//
//  HistoryCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 25/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AddContactCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<Contacts>
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    public var delete: (() -> Void)?

    var item: DefaultCellModel<Contacts>? {
        didSet {
            let obj = item?.property?.model
            
            lblName.text = /obj?.name
            
            let no = NSMutableString()
            for co in obj?.phone_numbers ?? [] {
                no.append("\(/co.type_label): \(/co.phone)\n")
            }
            lblNumber.text = /String(no)
        }
    }
    @IBAction func actionDelete(_ sender: UIButton) {
        delete?()
    }
}
