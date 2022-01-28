//
//  FilterCollectionViewCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 28/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UITableViewCell, ReusableCell {
    
    typealias T = FilterCellProvider
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: CollectionDataSource?
    
    var item: FilterCellProvider? {
        didSet {
            let filterOptions = item?.property?.model?.filter?.options
            let cellId = item?.property?.model?.filter?.is_multi == .TRUE ? FilterMultiSelectionCell.identfier : FilterSingleSelectionCell.identfier
            let collectionProperty = item?.property?.model?.collSizeProvider
            dataSource = CollectionDataSource.init(filterOptions, cellId, collectionView, collectionProperty?.cellSize, collectionProperty?.edgeInsets, collectionProperty?.lineSpacing, collectionProperty?.interItemSpacing, .vertical)
            
            dataSource?.configureCell = { (cell, item, indexPath) in
                (cell as? FilterSingleSelectionCell)?.item = item
                (cell as? FilterMultiSelectionCell)?.item = item
            }
            
            dataSource?.didSelectItem = { [weak self] (indexPath, item) in
                let options = self?.item?.property?.model?.filter?.options
                switch  self?.item?.property?.model?.filter?.is_multi ?? .FALSE {
                case .TRUE:
                    options?[indexPath.row].isSelected = !(/options?[indexPath.row].isSelected)
                    self?.dataSource?.updateData(options)
                case .FALSE:
                    options?.forEach({$0.isSelected = false})
                    options?[indexPath.row].isSelected = true
                    self?.item?.property?.model?.filter?.options = options
                    self?.dataSource?.updateData(options)
                }
            }
            
            collectionView.roundCorners(with: [.layerMaxXMaxYCorner, .layerMinXMaxYCorner], radius: 4.0)
            collectionView.clipsToBounds = true
        }
    }

}
