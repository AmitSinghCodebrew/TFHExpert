//
//  SubCategoryVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class SubCategoryVC: BaseVC {
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: CollectionDataSource?
    private var items: [Category]?
    public var parentCat: Category?
    public var comingFrom: AvailabilityDataType = .WhileLoginModule
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        collectionInit()
    }
    
    @IBAction func btnBacAction(_ sender: UIButton) {
        popVC()
    }
}
//MARK:- VCFuncs
extension SubCategoryVC {
    private func localizedTextSetup() {
        navView.isHidden = true
        lblTitle.text = VCLiteral.SUBCATEGORY_TITLE.localized
        lblSubTitle.text = VCLiteral.CATEGORY_VC_SUBTITLE.localized
    }
    
    private func collectionInit() {
        var identifier = SubcategoryCell.identfier
        var sizeProvider: CollectionSizeProvider!
        
        #if HealthCarePrashantExpert || HealExpert
        identifier = SubCategoryCenterCell.identfier
        let width = (UIScreen.main.bounds.width - (16 * 3)) / 2
        let height = width * 0.585
        sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: width, height: height), interItemSpacing: 16, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16))
        #else
        identifier = SubcategoryCell.identfier
        sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: UIScreen
            .main.bounds.width, height: 64), interItemSpacing: 0, lineSpacing: 0, edgeInsets: UIEdgeInsets.init(top: 16, left: 0, bottom: 16, right: 0))
        #endif
        
        dataSource = CollectionDataSource.init(items, identifier, collectionView, sizeProvider.cellSize, sizeProvider.edgeInsets, sizeProvider.lineSpacing, sizeProvider.interItemSpacing, .vertical)
        
        dataSource?.addPullToRefreshVertically({ [weak self] in
            self?.getSubCategoriesAPI()
        })
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? SubcategoryCell)?.item = item
            (cell as? SubCategoryCenterCell)?.item = item
        }
        
        dataSource?.didSelectItem = { [weak self] (indexPath, item) in
            let obj = item as? Category
            if /obj?.is_subcategory {
                let destVC = Storyboard<SubCategoryVC>.LoginSignUp.instantiateVC()
                destVC.comingFrom = self?.comingFrom ?? .WhileLoginModule
                destVC.parentCat = obj
                self?.pushVC(destVC)
            } else {
                if /obj?.is_additionals {
                    let destVC = Storyboard<UploadDocsVC>.LoginSignUp.instantiateVC()
                    destVC.category = obj
                    self?.pushVC(destVC)
                } else if /obj?.is_filters {
                    let destVC = Storyboard<SetPreferencesVC>.LoginSignUp.instantiateVC()
                    destVC.comingFrom = self?.comingFrom ?? .WhileLoginModule
                    destVC.categoryId = String(/obj?.id)
                    self?.pushVC(destVC)
                } else {
                    let destVC = Storyboard<ServicesVC>.LoginSignUp.instantiateVC()
                    destVC.comingFrom = self?.comingFrom ?? .WhileLoginModule
                    destVC.categoryId = String(/obj?.id)
                    self?.pushVC(destVC)
                }
            }
            
        }
        
        dataSource?.refreshProgrammatically()
        
        dataSource?.scrollDirection = { [weak self] (direction) in
            if direction == .Down {
                self?.navView.isHidden = true
            }
            self?.navigationBarAnimationHandling(direction: direction)
        }
    }
    
    private func getSubCategoriesAPI() {
        EP_Home.categories(parentId: String(/parentCat?.id), after: nil).request(success: { [weak self] (responseData) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
            let data = responseData as? CategoryData
            self?.items = (data?.classes_category ?? [])
            self?.dataSource?.updateData(self?.items)
        }) { [weak self] (error) in
            self?.dataSource?.stopInfiniteLoading(.FinishLoading)
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
