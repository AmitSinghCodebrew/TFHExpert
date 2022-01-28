//
//  ServiceModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 30/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ServiceHeaderProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = ServiceCellProvider
    
    typealias HeaderModelType = ServiceHeaderModel
    
    typealias FooterModelType = Any
    
    var headerProperty: (identifier: String?, height: CGFloat?, model: ServiceHeaderModel?)?
    
    var footerProperty: (identifier: String?, height: CGFloat?, model: Any?)?
    
    var items: [ServiceCellProvider]?
    
    required init(_ _header: (identifier: String?, height: CGFloat?, model: ServiceHeaderModel?)?, _ _footer: (identifier: String?, height: CGFloat?, model: Any?)?, _ _items: [ServiceCellProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getSectionWiseArray(_ services: [Service]?, comingFrom: AvailabilityDataType?) -> [ServiceHeaderProvider]  {
        var sections =  [ServiceHeaderProvider]()
        
        services?.forEach {
            var cellItems = [ServiceCellProvider]()
            if $0.available == .TRUE {
                cellItems.append(ServiceCellProvider.init((ServiceTypeCell.identfier, UITableView.automaticDimension, ServiceCellModel.init($0, comingFrom)), nil, nil))
            }
            let section = ServiceHeaderProvider.init((ServiceTypeHeaderView.identfier, 48.0, ServiceHeaderModel.init($0)), nil, cellItems)
            sections.append(section)
        }
        
        return sections
    }
}


class ServiceHeaderModel {
    var service: Service?
    
    init(_ _service: Service?) {
        service = _service
    }
}

class ServiceCellProvider: CellModelProvider {
    
    typealias CellModelType = ServiceCellModel
    
    var property: (identifier: String, height: CGFloat, model: ServiceCellModel?)?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: (identifier: String, height: CGFloat, model: ServiceCellModel?)?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
    
}

class ServiceCellModel {
    var service: Service?
    var weekDays = [WeekdayOrDate]()
    var timeSlots: [TimeSlot] = [TimeSlot.init(true)]
    var type: AvailabilityDataType? = .WhileLoginModule
    var applyOption: AvailabilityOptionType?
    
    init(_ _service: Service?, _ _type: AvailabilityDataType?) {
        service = _service
        type = _type
        switch type ?? .WhileLoginModule {
        case .WhileLoginModule:
            weekDays = [WeekdayOrDate(VCLiteral.SUN.localized),
                        WeekdayOrDate(VCLiteral.MON.localized),
                        WeekdayOrDate(VCLiteral.TUE.localized),
                        WeekdayOrDate(VCLiteral.WED.localized),
                        WeekdayOrDate(VCLiteral.THU.localized),
                        WeekdayOrDate(VCLiteral.FRI.localized),
                        WeekdayOrDate(VCLiteral.SAT.localized)]
        case .WhileManaging:
            let datesArray = Date.dates(from: Date(), to: Date().dateByAddingDays(100))
            datesArray.forEach{ weekDays.append(WeekdayOrDate.init($0)) }
        }
    }
}
