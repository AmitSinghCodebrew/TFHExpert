//
//  ApptDetailCollCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class ApptDetailCollCell: UITableViewCell, ReusableCell {
    
    typealias T = AppDetailCellModel
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerXIB(ImageCell.identfier)
        }
    }
    
    private var collectionDataSource: CollectionDataSource?

    var item: AppDetailCellModel? {
        didSet {
            
            collectionView.isScrollEnabled = false
            let obj = item?.property?.model
            
            collectionDataSource = CollectionDataSource.init(obj?.collectionItems, /obj?.identifier, collectionView, obj?.collProvider?.cellSize, obj?.collProvider?.edgeInsets, obj?.collProvider?.lineSpacing, obj?.collProvider?.interItemSpacing, .vertical)
            
            collectionDataSource?.configureCell = { (cell, item, indexPath) in
                (cell as? VendorFilterCell)?.symptom = item as? Symptom
                (cell as? ImageCell)?.item = item
                (cell as? AddImageCell)?.media = item as? MediaObj
            }
            
            collectionDataSource?.didSelectItem = { (indexPath, item) in
                if let obj = item as? MediaObj {
                    if obj.type == .pdf {
                        let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
                        destVC.linkTitle = (Configuration.getValue(for: .APP_PDF) + /obj.image, VCLiteral.DOC_TITLE.localized)
                        UIApplication.topVC()?.pushVC(destVC)
                    } else {
                        let destVC = Storyboard<MediaPreviewVC>.Other.instantiateVC()
                        destVC.item = ([obj], 0)
                        UIApplication.topVC()?.pushVC(destVC)
                    }
         
                } else if let obj = item as? String {
                    let destVC = Storyboard<MediaPreviewVC>.Other.instantiateVC()
                    destVC.item = ([MediaObj.init(obj, .image)], 0)
                    UIApplication.topVC()?.pushVC(destVC)
                }
            }
        }
    }
}
