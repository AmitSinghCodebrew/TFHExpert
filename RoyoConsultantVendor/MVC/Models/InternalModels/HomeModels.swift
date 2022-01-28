//
//  HomeModels.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 06/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class HomeSectionProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = HomeCellProvider
    
    typealias HeaderModelType = HomeSectionModel
    
    typealias FooterModelType = Any
    
    var headerProperty: (identifier: String?, height: CGFloat?, model: HomeSectionModel?)?
    
    var footerProperty: (identifier: String?, height: CGFloat?, model: Any?)?
    
    var items: [HomeCellProvider]?
    
    required init(_ _header: (identifier: String?, height: CGFloat?, model: HomeSectionModel?)?, _ _footer: (identifier: String?, height: CGFloat?, model: Any?)?, _ _items: [HomeCellProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getApptsWithoutHeader(requests: [Requests]) -> [HomeSectionProvider] {
        var cells = [HomeCellProvider]()
        requests.forEach({
            cells.append(HomeCellProvider.init((AppointmentCell.identfier, UITableView.automaticDimension, HomeCellModel.init($0)), nil, nil))
        })
        
        return [HomeSectionProvider.init(("", 0.0, nil), nil, cells)]
    }
    
    class func getAppointments(requests: [Requests]) -> [HomeSectionProvider] {
        
        #if HealthCarePrashantExpert || HomeDoctorKhalidExperts || AirDocExpert || TaraDocPro || NurseLynxExpert
        //Only Requests on home with paging
        let prefixedArray = requests
        let viewAllIsHidden = true
        #else
        let prefixedArray = Array(requests.prefix(5))
        let viewAllIsHidden = requests.count <= 5
        #endif

        
        var cells = [HomeCellProvider]()
        
        prefixedArray.forEach({
            cells.append(HomeCellProvider.init((AppointmentCell.identfier, UITableView.automaticDimension, HomeCellModel.init($0)), nil, nil))
        })
        var secionheight: CGFloat = 72
        #if HealExpert || HomeDoctorKhalidExperts || AirDocExpert || NurseLynxExpert || TaraDocPro//Show service type filters in requests
        secionheight = 72 + 36 + 16
        #elseif HealthCarePrashantExpert
        secionheight = 0.001
        #endif
        
        return cells.count == 0 ? [] : [HomeSectionProvider.init((HomeHeaderView.identfier, secionheight, HomeSectionModel.init(.APPOINTMENT, .REQUESTS, .VIEW_ALL, viewAllIsHidden, .RequestViewAll, _roundAddBtn: nil)), nil, cells)]
    }

    class func getArticles(articles: [Feed]?) -> HomeSectionProvider {
        let width = UIScreen.main.bounds.width * 0.4
        let height = width * (200 / 152)
        
        
        let sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: width, height: height), interItemSpacing: 0, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16))
        
        let heightOfTV_Cell = height + sizeProvider.edgeInsets.bottom + sizeProvider.edgeInsets.top
        
        let cells = [HomeCellProvider.init((HomeCollCell.identfier, heightOfTV_Cell, HomeCellModel.init(sizeProvider, .horizontal, articles ?? [Feed](), BlogCell.identfier)), nil, nil)]
        
        let section = HomeSectionProvider.init((HomeHeaderView.identfier, 48.0, HomeSectionModel.init(nil, .ARTICLES, .VIEW_ALL, /articles?.count < 5, .ArticleViewAll, _roundAddBtn: (false, .ArticleAdd))), nil, cells)
        
        return section
    }
    
    class func getBlogs(blogs: [Feed]?) -> HomeSectionProvider {
        let width = UIScreen.main.bounds.width * 0.4
        let height = width * (200 / 152)
        
        
        let sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: width, height: height), interItemSpacing: 0, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16))
        
        let heightOfTV_Cell = height + sizeProvider.edgeInsets.bottom + sizeProvider.edgeInsets.top
        
        let cells = [HomeCellProvider.init((HomeCollCell.identfier, heightOfTV_Cell, HomeCellModel.init(sizeProvider, .horizontal, blogs ?? [Feed](), BlogCell.identfier)), nil, nil)]
        
        let section = HomeSectionProvider.init((HomeHeaderView.identfier, 48.0, HomeSectionModel.init(nil, .BLOGS, .VIEW_ALL, /blogs?.count < 5, .BlogViewAll, _roundAddBtn: (false, .BlogAddNew))), nil, /blogs?.count == 0 ? [] : cells)
        
        return section
    }
    
    class func getHealthTools() -> HomeSectionProvider {
        let width = (UIScreen.main.bounds.width - (16 * 3)) / 2
        let height = width * (112 / 168)
        
        let sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: width, height: height), interItemSpacing: 16, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16))
        
        return HomeSectionProvider.init((HomeHeaderView.identfier, 48.0, HomeSectionModel.init(nil, .HEALTH_TOOL, .VIEW_ALL, true, .RequestViewAll, _roundAddBtn: nil)), nil, [HomeCellProvider.init((HomeCollCell.identfier, sizeProvider.getHeightOfTableViewCell(for: 4, gridCount: 2), HomeCellModel.init(sizeProvider, .vertical, HealthTool.getTools(), HealthToolCell.identfier)), nil, nil)])
    }
}

class HomeSectionModel {
    var titleRegular: VCLiteral?
    var titleBold: VCLiteral?
    var btnText: VCLiteral?
    var isBtnHidden: Bool?
    var action: HeaderActionType?
    var roundAddBtn: (isHidden: Bool, action: HeaderActionType)?
    var extraPayment: ExtraPayment?
    #if NurseLynxExpert
    var tier: Tier?
    #endif
    
    init(_ titleR: VCLiteral?, _ titleB: VCLiteral?, _ _btnText: VCLiteral, _ _isBtnHidden: Bool, _ _action: HeaderActionType, _roundAddBtn: (isHidden: Bool, action: HeaderActionType)?, _ _extraPayment: ExtraPayment? = nil) {
        titleRegular = titleR
        titleBold = titleB
        btnText = _btnText
        isBtnHidden = _isBtnHidden
        action = _action
        roundAddBtn = _roundAddBtn
        extraPayment = _extraPayment
    }
}

class HomeCellProvider: CellModelProvider {
    
    typealias CellModelType = HomeCellModel

    var property: (identifier: String, height: CGFloat, model: HomeCellModel?)?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: (identifier: String, height: CGFloat, model: HomeCellModel?)?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}

class HomeCellModel {
    var collProvider: CollectionSizeProvider?
    var scrollDirection: UICollectionView.ScrollDirection?
    var collectionItems: [Any]?
    var identifier: String?
    
    var request: Requests?
    
    init(_ _collProvider: CollectionSizeProvider, _ _scrollDirection: UICollectionView.ScrollDirection, _ _collectionItems: [Any]?, _ _identifier: String?) {
        collProvider = _collProvider
        scrollDirection = _scrollDirection
        collectionItems = _collectionItems
        identifier = _identifier
    }
    
    init(_ _request: Requests?) {
        request = _request
    }
}

class CustomService {
    var image: UIImage?
    var title: String?
    
    init(_ _image: UIImage?, _ _title: String?) {
        image = _image
        title = _title
    }
}

class HealthTool {
    var image: UIImage?
    var title: VCLiteral?
    var subtitle: VCLiteral?
    
    init(_ _image: UIImage?, _ _title: VCLiteral, _ _subtitle: VCLiteral) {
        image = _image
        title = _title
        subtitle = _subtitle
    }
    
    class func getTools() -> [HealthTool] {
        return [HealthTool(#imageLiteral(resourceName: "ic_bmi"), .HEALTH_TOOL_01_TITLE, .HEALTH_TOOL_01_SUBTITLE),
                HealthTool(#imageLiteral(resourceName: "ic_water"), .HEALTH_TOOL_02_TITLE, .HEALTH_TOOL_02_SUBTITLE),
                HealthTool(#imageLiteral(resourceName: "ic_protein"), .HEALTH_TOOL_03_TITLE, .HEALTH_TOOL_03_SUBTITLE),
                HealthTool(#imageLiteral(resourceName: "ic_pregnancy"), .HEALTH_TOOL_04_TITLE, .HEALTH_TOOL_04_SUBTITLE)]
    }
}
