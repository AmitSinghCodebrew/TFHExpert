//
//  FavouritesVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 25/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class FavouritesVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var feedType: FeedType?
    private var dataSource: CollectionDataSource?
    private var items: [Feed]?
    private var after: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedType = .blog
        lblTitle.text = VCLiteral.FAVOURITES.localized
        collectionViewInit()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension FavouritesVC {
    private func getListing(isRefreshing: Bool? = false) {
        EP_Home.getFeeds(feedType: feedType, consultant_id: nil, after: /isRefreshing ? nil : after, favourite: .TRUE).request(success: { [weak self] (responseData) in
            
            let response = responseData as? FeedsData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.feeds ?? []
            } else {
                self?.items = (self?.items ?? []) + (response?.feeds ?? [])
            }
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.dataSource?.updateData(self?.items)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            if /self?.items?.count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.collectionView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
    
    private func collectionViewInit() {
        
        let width = (UIScreen.main.bounds.width - (16 * 3)) / 2
        let height = width * (200 / 152)
        
        dataSource = CollectionDataSource.init(items, BlogCell.identfier, collectionView, CGSize.init(width: width, height: height), UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16), 16, 16, .vertical)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? BlogCell)?.item = item
            (cell as? BlogCell)?.didUnlike = { [weak self] in
                self?.items?.remove(at: indexPath.row)
                self?.dataSource?.items = self?.items
                self?.collectionView.deleteItems(at: [indexPath])
            }
        }
        
        dataSource?.addPullToRefreshVertically({ [weak self] in
            self?.errorView.removeFromSuperview()
            self?.getListing(isRefreshing: true)
        })
        
        dataSource?.addInfiniteScrollVertically = { [weak self] in
            if self?.after != nil {
                self?.getListing(isRefreshing: false)
            }
        }
        
        dataSource?.didSelectItem = { [weak self] (indexPath, item) in
            let destVC = Storyboard<BlogDetailVC>.Other.instantiateVC()
            destVC.feed = item as? Feed
            destVC.didUpdated = { (feed) in
                self?.items?[indexPath.row] = feed!
                self?.dataSource?.updateData(self?.items)
            }
            self?.pushVC(destVC)
        }
        
        dataSource?.refreshProgrammatically()
    }
}
