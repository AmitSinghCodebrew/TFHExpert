//
//  CarePlanHeaderView.swift
//  NurseLynxExpert
//
//  Created by Sandeep Kumar on 27/04/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class CarePlanHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = ApptDetailHeader

    @IBOutlet weak var lblTitle: UILabel!
    
    var item: ApptDetailHeader? {
        didSet {
            lblTitle.numberOfLines = 0
            let text = "\(VCLiteral.CARE_PLAN.localized)\n\(/item?.headerProperty?.model?.tier?.title)"
            lblTitle.setAttributedText(original: (text, Fonts.CamptonSemiBold.ofSize(16), ColorAsset.txtMoreDark.color), toReplace: (/item?.headerProperty?.model?.tier?.title, Fonts.CamptonMedium.ofSize(12), ColorAsset.txtDark.color))
        }
    }
}
