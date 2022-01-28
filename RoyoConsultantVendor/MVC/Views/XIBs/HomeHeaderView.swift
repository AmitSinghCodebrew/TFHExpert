//
//  HomeHeaderView.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 07/08/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

enum HeaderActionType {
    case RequestViewAll
    case ArticleAdd
    case ArticleViewAll
    case BlogAddNew
    case BlogViewAll
}

class HomeHeaderView: UITableViewHeaderFooterView, ReusableHeaderFooter {
    
    typealias T = HomeSectionProvider
    
    @IBOutlet weak var lblTItleRegular: UILabel!
    @IBOutlet weak var lblTitleBold: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var collectionFilters: UICollectionView! {
        didSet {
            collectionFilters.registerXIB(FilterXIBCell.identfier)
        }
    }
    
    var didTapBtn: ((_ _actionType: HeaderActionType?) -> Void)?
    
    private var collectionDataSource: CollectionDataSource?
    public var services: [Service]? = UserPreference.shared.data?.services
    public var serviceSelected: ((_ forIndex: Int) -> Void)?
    
    var item: HomeSectionProvider? {
        didSet {
            lblTItleRegular.text = /item?.headerProperty?.model?.titleRegular?.localized
            
            lblTItleRegular.isHidden = /item?.headerProperty?.model?.titleRegular?.localized == ""
            btn.setTitle(/item?.headerProperty?.model?.btnText?.localized, for: .normal)
            btn.isHidden = /item?.headerProperty?.model?.isBtnHidden
            btnAdd.isHidden = item?.headerProperty?.model?.roundAddBtn?.isHidden ?? true
            
            if let extraPayment = item?.headerProperty?.model?.extraPayment {
                let text = VCLiteral.EXTRA_PAYMENT.localized + " " + "(\(/extraPayment.status?.title.localized))"
                lblTitleBold.setAtrributedText(original: (text, Fonts.CamptonSemiBold.ofSize(24), ColorAsset.txtMoreDark.color), toReplace: ("(\(/extraPayment.status?.title.localized))", Fonts.CamptonMedium.ofSize(18), (extraPayment.status?.color)!))
            } else {
                lblTitleBold.setAtrributedText(original: (/item?.headerProperty?.model?.titleBold?.localized, Fonts.CamptonSemiBold.ofSize(24), ColorAsset.txtMoreDark.color), toReplace: ("", Fonts.CamptonSemiBold.ofSize(24), ColorAsset.txtMoreDark.color))
            }
            
            #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert || AirDocExpert || TaraDocPro
            collectionFilters.isHidden = !(item?.headerProperty?.model?.titleRegular == .APPOINTMENT)
            collectionFiltersInit()
            #else
            collectionFilters.isHidden = true
            #endif
        }
    }
    
    //ApptDetail VC
    var item2: ApptDetailHeader? {
        didSet {
            item = HomeSectionProvider.init(item2?.headerProperty, nil, [])
        }
    }
    
    private func collectionFiltersInit() {
        collectionFilters.contentInset.right = 16 * (CGFloat(/services?.count) - 1)

        collectionDataSource = CollectionDataSource.init(services, FilterXIBCell.identfier, collectionFilters, CGSize.init(width: 88, height: 36), UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16), 16, 0, .horizontal)
        
        collectionDataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? FilterXIBCell)?.item = item
        }
        
        collectionDataSource?.didSelectItem = { [weak self] (indexPath, item) in
            self?.services?.forEach({$0.isSelected = false})
            self?.services?[indexPath.item].isSelected = true
            self?.serviceSelected?(indexPath.item)
            self?.collectionDataSource?.updateData(self?.services)
        }
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        didTapBtn?(item?.headerProperty?.model?.roundAddBtn?.action)
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        didTapBtn?(item?.headerProperty?.model?.action)
    }
}
