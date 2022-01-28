//
//  ApptDetailModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class ApptDetailHeader: HeaderFooterModelProvider {
    typealias CellModelType = AppDetailCellModel
    
    typealias HeaderModelType = HomeSectionModel
    
    typealias FooterModelType = Any
    
    var headerProperty: HeaderProperty?
    
    var footerProperty: FooterProperty?
    
    var items: [AppDetailCellModel]?
    
    required init(_ _header: HeaderProperty?, _ _footer: FooterProperty?, _ _items: [AppDetailCellModel]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getArray(request: Requests?) -> [ApptDetailHeader] {
        var items = [ApptDetailHeader]()
        let detail = ApptDetailHeader.init(nil, nil, [AppDetailCellModel.init((ApptShortCell.identfier, UITableView.automaticDimension, ApptDetailData.init(request)), nil, nil)])
        items.append(detail)
        
        if let extraPayment = request?.extra_payment { //Extra Payment Addition
            let cells = [AppDetailCellModel.init((ExtraPaymentCell.identfier, UITableView.automaticDimension, ApptDetailData.init(request)), nil, nil)]
            
            let section = ApptDetailHeader.init((HomeHeaderView.identfier, 40.0, HomeSectionModel.init(nil, .EXTRA_PAYMENT, .EXTRA_PAYMENT, true, .RequestViewAll, _roundAddBtn: nil)), nil, cells)
            section.headerProperty?.model?.extraPayment = extraPayment
            items.append(section)
        }
        
        #if CloudDocPro
        var question_answers = [AppDetailCellModel]()
        
        for (index, item) in (request?.question_answers ?? []).enumerated() {
            question_answers.append(AppDetailCellModel.init((QuestionAnswerCell.identfier, UITableView.automaticDimension, ApptDetailData.init(item, /index + 1)), nil, nil))
        }
        
        let question_answersSection = ApptDetailHeader.init((HomeHeaderView.identfier, 40.0, HomeSectionModel.init(nil, .PRE_ASSESMENT, .VIEW_ALL, true, .RequestViewAll, _roundAddBtn: nil)), nil, question_answers)
        
        if question_answers.count != 0 {
            items.append(question_answersSection)
        }
        #elseif NurseLynxExpert
        var carePlans = [AppDetailCellModel]()

        for (_, item) in (request?.tier_detail?.tier_options ?? []).enumerated() {
            carePlans.append(AppDetailCellModel.init((ApptDetailCarePlanCell.identfier, UITableView.automaticDimension, ApptDetailData.init(item, request)), nil, nil))
        }

        let sectionModel = HomeSectionModel.init(.CARE_PLAN, .CARE_PLAN, .CARE_PLAN, true, .BlogViewAll, _roundAddBtn: nil)
        sectionModel.tier = request?.tier_detail
        
        let carePlanSection = ApptDetailHeader.init((CarePlanHeaderView.identfier, 56.0, sectionModel), nil, carePlans)

        if carePlans.count != 0 {
            items.append(carePlanSection)
        }
        #endif

        let width = (((UIScreen.main.bounds.width - 32) - (16 * 2)) / 3) - 0.1
        
        let sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: width, height: 36), interItemSpacing: 16, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 8, left: 16, bottom: 16, right: 16))
        
        let symptoms = ApptDetailHeader.init((HomeHeaderView.identfier, 40.0, HomeSectionModel.init(nil, .SYMPTOMS, .VIEW_ALL, true, .RequestViewAll, _roundAddBtn: nil)), nil, [AppDetailCellModel.init((SymptomInfoCell.identfier, UITableView.automaticDimension, ApptDetailData.init(request)), nil, nil), AppDetailCellModel.init((ApptDetailCollCell.identfier, sizeProvider.getHeightOfTableViewCell(for: /request?.symptoms?.count, gridCount: 3), ApptDetailData.init(sizeProvider, request?.symptoms, VendorFilterCell.identfier)), nil, nil)])
        
        let widthMedia = ((((UIScreen.main.bounds.width - 32) - (16 * 3)) / 4) - 0.1)
        let mediaSizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: widthMedia, height: widthMedia), interItemSpacing: 16, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 0, left: 16, bottom: 8, right: 16))
        
        if /request?.symptom_images?.count != 0 {
            let symptomMediaCell = AppDetailCellModel.init((ApptDetailCollCell.identfier, mediaSizeProvider.getHeightOfTableViewCell(for: /request?.symptom_images?.count, gridCount: 4), ApptDetailData.init(mediaSizeProvider, request?.symptom_images, AddImageCell.identfier)), nil, nil)
            symptoms.items?.insert(symptomMediaCell, at: 1)
        }
        
     
        if /request?.symptoms?.count != 0 || /request?.symptom_details != "" {
            items.append(symptoms)
        }
        
        if let secondOpinion = request?.second_oponion {
            
            let widthSecondOP = (((UIScreen.main.bounds.width - 32) - (16 * 3)) / 4) - 0.1

            let secondOPSize = CollectionSizeProvider.init(cellSize: CGSize.init(width: widthSecondOP, height: widthSecondOP), interItemSpacing: 16, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 8, left: 16, bottom: 0, right: 16))
            let images = secondOpinion.images?.replacingOccurrences(of: " ", with: "").components(separatedBy: ",") ?? []
            let medicalRecord = ApptDetailHeader.init((HomeHeaderView.identfier, 40.0, HomeSectionModel.init(nil, .MEDICAL_RECORD, .VIEW_ALL, true, .RequestViewAll, _roundAddBtn: nil)), nil, [AppDetailCellModel.init((MedicalRecordCell.identfier, UITableView.automaticDimension, ApptDetailData.init(request)), nil, nil), AppDetailCellModel.init((ApptDetailCollCell.identfier, secondOPSize.getHeightOfTableViewCell(for: images.count, gridCount: 4), ApptDetailData.init(secondOPSize, images, ImageCell.identfier)), nil, nil)])
            items.append(medicalRecord)
        }
        
        return request == nil ? [] : items
    }
}


class AppDetailCellModel: CellModelProvider {
    
    typealias CellModelType = ApptDetailData

    var property: Property?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: Property?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}

class ApptDetailData {
    var request: Requests?
    
    var collProvider: CollectionSizeProvider?
    var collectionItems: [Any]?
    var identifier: String?
    
    #if CloudDocPro
    var questionAnswer: QuestionAnswer?
    var index: Int?
    
    init(_ _question: QuestionAnswer?, _ _index: Int?) {
        questionAnswer = _question
        index = _index
    }
    #elseif NurseLynxExpert
    var tierOption: TierOption?
    
    init(_ _option: TierOption?, _ _request: Requests?) {
        tierOption = _option
        request = _request
    }
    #endif

    init(_ request: Requests?) {
        self.request = request
    }
    
    init(_ _collSize: CollectionSizeProvider?, _ _items: [Any]?, _ _identifier: String?) {
        collProvider = _collSize
        collectionItems = _items
        identifier = _identifier
    }
}
