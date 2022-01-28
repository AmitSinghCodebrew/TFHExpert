//
//  ChatTimeHeaderView.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 20/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ChatTimeHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = TimeStampProvider
    
    @IBOutlet weak var lblTime: UILabel!
    
    var item: TimeStampProvider? {
        didSet {
            lblTime.text = /item?.footerProperty?.model?.date?.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false)
        }
    }
}
