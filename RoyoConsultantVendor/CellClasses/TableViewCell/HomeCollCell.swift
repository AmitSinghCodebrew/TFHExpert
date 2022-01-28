//
//  HomeCollCell.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 06/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HomeCollCell: UITableViewCell, ReusableCell {
    
    typealias T = HomeCellProvider
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    public var isClassesScreen: Bool? = false
    private var collectionDataSource: CollectionDataSource?
    lazy var errorView: ErrorView = {
        let eView: ErrorView = .fromNib()
        return eView
    }()
    
    var item: HomeCellProvider? {
        didSet {
            let obj = item?.property?.model

            
//            collectionView.isPagingEnabled = /obj?.identifier == BannerCell.identfier
//            pageControl.isHidden = !(/obj?.identifier == BannerCell.identfier)
            
            if /obj?.identifier == BlogCell.identfier {
                if /obj?.collectionItems?.count == 0 {
                    if self.contentView.subviews.contains(errorView) {
                        errorView.showNoDataWithImage(type: .NoArticles)
                    } else {
                        errorView.frame = self.bounds
                        self.addSubview(errorView)
                        errorView.showNoDataWithImage(type: .NoArticles)
                    }
                } else {
                    errorView.removeFromSuperview()
                }
            } else {
                errorView.removeFromSuperview()
            }
            
            pageControl.isHidden = true
            
            pageControl.isUserInteractionEnabled = false
            pageControl.numberOfPages = /obj?.collectionItems?.count
            pageControl.currentPage = 0
            
            collectionDataSource = CollectionDataSource.init(obj?.collectionItems, /obj?.identifier, collectionView, obj?.collProvider?.cellSize, obj?.collProvider?.edgeInsets, obj?.collProvider?.lineSpacing, obj?.collProvider?.interItemSpacing, obj?.scrollDirection ?? .vertical)
                    
            collectionDataSource?.configureCell = { (cell, item, indexPath) in
                (cell as? BlogCell)?.item = item
                (cell as? HealthToolCell)?.item = item
            }
            
            collectionDataSource?.didSelectItem = { [weak self] (indexPath, item) in
                switch /obj?.identifier {
                case BlogCell.identfier:
                    let destVC = Storyboard<BlogDetailVC>.Other.instantiateVC()
                    destVC.feed = item as? Feed
                    destVC.didUpdated = { (feed) in
                        self?.item?.property?.model?.collectionItems?[indexPath.row] = feed!
                        self?.collectionDataSource?.updateData(self?.item?.property?.model?.collectionItems)
                    }
                    UIApplication.topVC()?.pushVC(destVC)
                case HealthToolCell.identfier:
                    switch (item as? HealthTool)?.title ?? .HEALTH_TOOL_01_TITLE {
                    case .HEALTH_TOOL_01_TITLE: //BMI
                        let destVC = Storyboard<BMI_CalVC>.Other.instantiateVC()
                        UIApplication.topVC()?.pushVC(destVC)
                    case .HEALTH_TOOL_02_TITLE: //Water Intake
                        let destVC = Storyboard<WaterIntakeCalVC>.Other.instantiateVC()
                        UIApplication.topVC()?.pushVC(destVC)
                    case .HEALTH_TOOL_03_TITLE: //Protien Intake
                        let destVC = Storyboard<ProtienIntakeVC>.Other.instantiateVC()
                        UIApplication.topVC()?.pushVC(destVC)
                    case .HEALTH_TOOL_04_TITLE: //Pregnancy
                        let destVC = Storyboard<PregnancyCalculatorVC>.Other.instantiateVC()
                        UIApplication.topVC()?.pushVC(destVC)
                    default:
                        break
                    }
                default:
                    break
                }
            }
            
            collectionDataSource?.didChangeCurrentIndex = { [weak self] (indexPath) in
                self?.pageControl.currentPage = indexPath.item
            }
        }
    }
}
