//
//  PaymentHeaderView.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 23/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class PaymentHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = PaymentHeaderProvider
    
    @IBOutlet weak var viewDot: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    public var didSelectHeader: ((_ model: PaymentHeaderModel?) -> Void)?
    
    var item: PaymentHeaderProvider? {
        didSet {
            let obj = item?.headerProperty?.model
            lblTitle.text = /obj?.type?.title
            viewDot.backgroundColor = ColorAsset.appTint.color
            viewDot.isHidden = !(/obj?.isSelected)
            isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(didSelectHeaderView))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            addGestureRecognizer(tapGesture)
        }
    }
    
    
    @objc private func didSelectHeaderView() {
        didSelectHeader?(item?.headerProperty?.model)
    }
}
