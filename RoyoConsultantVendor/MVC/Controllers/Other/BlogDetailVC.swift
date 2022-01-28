//
//  BlogDetailVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 19/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class BlogDetailVC: BaseVC {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    var feed: Feed?
    var didUpdated: ((_ feed: Feed?) -> Void)?
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<Feed>, DefaultCellModel<Feed>, Feed>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        tableViewInit()
        increaseViewCountAPI()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Like Unlike
            btnLike.isUserInteractionEnabled = false
            feed?.is_favorite = !(/feed?.is_favorite)
            didUpdated?(feed)
            UIView.transition(with: btnLike, duration: 0.25, options: [.transitionFlipFromRight], animations: {
                
            }) { (_) in
                self.btnLike.tintColor = /self.feed?.is_favorite ? ColorAsset.requestStatusFailed.color : UIColor.white
            }
            EP_Home.addFav(feedId: feed?.id, favorite: /feed?.is_favorite ? .TRUE : .FALSE).request(success: { [weak self] (response) in
                self?.btnLike.isUserInteractionEnabled = true
            }) { [weak self] (_) in
                self?.btnLike.isUserInteractionEnabled = true
            }
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension BlogDetailVC {
    private func initialSetup() {
        let cornerRadius: CGFloat = 24.0
        tableView.contentInset.top = (UIScreen.main.bounds.width * 0.65) - (44 + UIApplication.statusBarHeight + cornerRadius)
        headerView.roundCorners(with: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: cornerRadius)
        imgView.setImageNuke(feed?.image)
        lblAuthor.text = /feed?.user_data?.profile?.title + " " + /feed?.user_data?.name
        let date = Date.init(fromString: /feed?.created_at, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
        lblDate.text = /date.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false)
        btnLike.tintColor = /feed?.is_favorite ? ColorAsset.requestStatusFailed.color : UIColor.white
    }
    
    private func tableViewInit() {
        guard let item = feed else {
            return
        }
        
        dataSource = TableDataSource<DefaultHeaderFooterModel<Feed>, DefaultCellModel<Feed>, Feed>.init(.SingleListing(items: [item], identifier: BlogDetailCell.identfier, height: UITableView.automaticDimension, leadingSwipe: nil, trailingSwipe: nil), tableView)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? BlogDetailCell)?.item = item
        }
    }
    
    private func increaseViewCountAPI() {
        EP_Home.viewFeed(id: feed?.id).request(success: { [weak self] (responseData) in
            self?.feed = (responseData as? FeedsData)?.feed
            self?.initialSetup()
        })
    }
}

