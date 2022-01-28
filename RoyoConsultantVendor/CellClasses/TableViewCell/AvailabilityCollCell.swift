//
//  AvailabilityCollCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class AvailabilityCollCell: UITableViewCell, ReusableCell {
    
    typealias T = AvailabilityCellProvider
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var dataSource: CollectionDataSource?
    public var hideUnhideSaveButton: ((_ isHidden: Bool) -> Void)?
    public var dateSelected: ((_ date: Date?) -> Void)?
    
    var item: AvailabilityCellProvider? {
        didSet {
            
            let obj = item?.property?.model
            
            dataSource = CollectionDataSource.init(obj?.collItems, /obj?.collectionCellId, collectionView, obj?.collSizeProvider?.cellSize, obj?.collSizeProvider?.edgeInsets, obj?.collSizeProvider?.lineSpacing, obj?.collSizeProvider?.interItemSpacing, .horizontal)
            
            dataSource?.configureCell = { (cell, item, indexPath) in
                (cell as? WeekDayCell)?.cornerRadiusForBackView = /obj?.collSizeProvider?.cellSize.width / 2.0
                (cell as? WeekDayCell)?.item = item
                (cell as? DateCell)?.item = item
            }
            
            dataSource?.didSelectItem = { [weak self] (indexPath, item) in
                switch /obj?.collectionCellId {
                case WeekDayCell.identfier:
                    (item as? WeekdayOrDate)?.isSelected = !(/(item as? WeekdayOrDate)?.isSelected)
                    self?.collectionView.reloadItems(at: [indexPath])
                    if /obj?.collectionCellId == WeekDayCell.identfier {
                        self?.hideUnhideSaveButton?(!(/self?.item?.property?.model?.collItems?.contains(where: {/$0.isSelected})))
                    }
                case DateCell.identfier:
                    if /(item as? WeekdayOrDate)?.isSelected {
                        return
                    }
                    obj?.collItems?.forEach({ $0.isSelected = false })
                    obj?.collItems?[indexPath.item].isSelected = true
                    self?.item?.property?.model?.collItems = obj?.collItems
                    self?.dateSelected?((item as? WeekdayOrDate)?.date)
                    self?.dataSource?.updateData(obj?.collItems)
                default:
                    break
                }
                
            }
        }
    }
    
}
