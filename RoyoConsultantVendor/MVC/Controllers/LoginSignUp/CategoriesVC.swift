//
//  CategoriesVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class CategoriesVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var navView: UIView!
    
    private var dataSource: CollectionDataSource?
    private var items: [Category]?
    public var comingFrom: AvailabilityDataType = .WhileLoginModule
    private var after: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        collectionViewInit()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
}

//MARK:- VCFuncs
extension CategoriesVC {
    private func localizedTextSetup() {
        navView.isHidden = true
        lblTitle.text = VCLiteral.CATEGORY_VC_TITLE.localized
        lblSubTitle.text = VCLiteral.CATEGORY_VC_SUBTITLE.localized
    }
    
    private func collectionViewInit() {
        
        let width = (UIScreen.main.bounds.width - (16 * 3)) / 2
        let height = width * 0.585
        
        let imageSize = CGSize.init(width: height - 16, height: height - 16)
        
        dataSource = CollectionDataSource.init(items, CategoryCell.identfier, collectionView, CGSize.init(width: width, height: height), UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16), 16, 16, .vertical)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? CategoryCell)?.imageSize = imageSize
            (cell as? CategoryCell)?.item = item
        }
        
        dataSource?.addPullToRefreshVertically({ [weak self] in
            self?.errorView.removeFromSuperview()
            self?.after = nil
            self?.getCategoriesAPI(isRefreshing: true)
        })
        
        dataSource?.addInfiniteScrollVertically = { [weak self] in
            if self?.after != nil {
                self?.getCategoriesAPI(isRefreshing: false)
            }
        }
        
        dataSource?.didSelectItem = { [weak self] (indexPath, item) in
            if /(item as? Category)?.is_subcategory {
                let destVC = Storyboard<SubCategoryVC>.LoginSignUp.instantiateVC()
                destVC.parentCat = item as? Category
                destVC.comingFrom = self?.comingFrom ?? .WhileLoginModule
                self?.pushVC(destVC)
            } else {
                if /(item as? Category)?.is_additionals {
                    let destVC = Storyboard<UploadDocsVC>.LoginSignUp.instantiateVC()
                    destVC.category = item as? Category
                    self?.pushVC(destVC)
                } else if /(item as? Category)?.is_filters {
                    let destVC = Storyboard<SetPreferencesVC>.LoginSignUp.instantiateVC()
                    destVC.categoryId = String(/(item as? Category)?.id)
                    destVC.comingFrom = self?.comingFrom ?? .WhileLoginModule
                    self?.pushVC(destVC)
                } else {
                    let destVC = Storyboard<ServicesVC>.LoginSignUp.instantiateVC()
                    destVC.categoryId = String(/(item as? Category)?.id)
                    destVC.comingFrom = self?.comingFrom ?? .WhileLoginModule
                    self?.pushVC(destVC)
                }
                
            }
        }
        
//        dataSource?.scrollDirection = { [weak self] (direction) in
//            if direction == .Down {
//                self?.navView.isHidden = true
//            }
//            self?.navigationBarAnimationHandling(direction: direction)
//        }
        
        dataSource?.refreshProgrammatically()
        
    }
    
    private func getCategoriesAPI(isRefreshing: Bool? = false) {
        EP_Home.categories(parentId: nil, after: /isRefreshing ? nil : after).request(success: { [weak self] (responseData) in
//            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            
            let response = responseData as? CategoryData
            self?.after = response?.after
            if /isRefreshing {
                self?.items = response?.classes_category
            } else {
                self?.items = (self?.items ?? []) + (response?.classes_category ?? [])
            }
            
            self?.dataSource?.stopInfiniteLoading(response?.after == nil ? .NoContentAnyMore : .FinishLoading)
            self?.dataSource?.updateData(self?.items)
            self?.stopLineAnimation()
//
//            let data = responseData as? CategoryData
//            self?.items = (data?.classes_category ?? [])
//            self?.dataSource?.updateData(self?.items)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            self?.stopLineAnimation()
            if /self?.items?.count == 0 {
                self?.showErrorView(error: /error, scrollView: self?.collectionView, tapped: {
                    self?.errorView.removeFromSuperview()
                    self?.dataSource?.refreshProgrammatically()
                })
            }
        }
    }
    
    //MARK:- Handling Animation for navigation bar
    private func navigationBarAnimationHandling(direction: ScrollDirection) {
        constraintTop.constant = direction == .Up ? -44 : 0
        UIView.transition(with: lblTitle, duration: 0.2, options: .curveLinear, animations: { [weak self] in
            self?.lblTitle.textAlignment = direction == .Up ? .center : .left
            self?.lblSubTitle.text = direction == .Up ? nil : VCLiteral.CATEGORY_VC_SUBTITLE.localized
        })
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.lblTitle?.transform = direction == .Up ? CGAffineTransform.init(scaleX: 0.7, y: 0.7) : CGAffineTransform.identity
            self?.view.layoutSubviews()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.navView.isHidden = (direction == .Down)
        }
    }
}
