//
//  BlogCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 31/07/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class BlogCell: UICollectionViewCell, ReusableCellCollection {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    var didUnlike: (() -> Void)?
    
    var item: Any? {
        didSet {
            imgView.backgroundColor = ColorAsset.appTint.color
            let obj = item as? Feed
            imgView.setImageNuke(obj?.image)
            lblTitle.text = /obj?.title
            let date = Date.init(fromString: /obj?.created_at, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
            lblDate.text = /date.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false)
            lblViews.text = /obj?.views == 1 ? "\(/obj?.views) \(VCLiteral.VIEW.localized)" : "\(/obj?.views) \(VCLiteral.VIEWS.localized)"
            btnLike.tintColor = /obj?.is_favorite ? ColorAsset.requestStatusFailed.color : UIColor.white
        }
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        btnLike.isUserInteractionEnabled = false
        (item as? Feed)?.is_favorite = !(/(item as? Feed)?.is_favorite)
        UIView.transition(with: btnLike, duration: 0.25, options: [.transitionFlipFromRight], animations: {
            
        }) { (_) in
            self.btnLike.tintColor = /(self.item as? Feed)?.is_favorite ? ColorAsset.requestStatusFailed.color : UIColor.white
        }
        EP_Home.addFav(feedId: (item as? Feed)?.id, favorite: /(item as? Feed)?.is_favorite ? .TRUE : .FALSE).request(success: { [weak self] (response) in
            self?.btnLike.isUserInteractionEnabled = true
        }) { [weak self] (_) in
            self?.btnLike.isUserInteractionEnabled = true
        }
        if /(item as? Feed)?.is_favorite == false {
            didUnlike?()
        }
    }
}
