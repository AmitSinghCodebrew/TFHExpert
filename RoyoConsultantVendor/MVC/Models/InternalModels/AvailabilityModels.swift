//
//  AvailabilityModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 31/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

enum AvailabilityDataType {
    case WhileLoginModule
    case WhileManaging
    
    var addAvailabilityTitle: VCLiteral {
        switch self {
        case .WhileLoginModule:
            return .ADD_AVAILABILITY
        case .WhileManaging:
            return .MANAGE_AVAILABILITY
        }
    }
}

class AvailibilityHeaderFooterProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = AvailabilityCellProvider
    
    typealias HeaderModelType = AvailabilityHeaderModel
    
    typealias FooterModelType = AvailabilityFooterModel
    
    var headerProperty: (identifier: String?, height: CGFloat?, model: AvailabilityHeaderModel?)?
    
    var footerProperty: (identifier: String?, height: CGFloat?, model: AvailabilityFooterModel?)?
    
    var items: [AvailabilityCellProvider]?
    
    required init(_ _header: (identifier: String?, height: CGFloat?, model: AvailabilityHeaderModel?)?, _ _footer: (identifier: String?, height: CGFloat?, model: AvailabilityFooterModel?)?, _ _items: [AvailabilityCellProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getItems(model: ServiceCellModel?) -> [AvailibilityHeaderFooterProvider] {
        //MARK:--------WEEKDAYS
        let spacesBetweenWeeksdayCells: CGFloat = 8.0 * 16.0
        let cellWidth = (UIScreen.main.bounds.width - spacesBetweenWeeksdayCells) / 7.0
        let weekDaySizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: cellWidth, height: cellWidth), interItemSpacing: 0.0, lineSpacing: 16.0, edgeInsets: UIEdgeInsets.init(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0))
        let sectionWeekDaysCellHeight = cellWidth + weekDaySizeProvider.edgeInsets.top + weekDaySizeProvider.edgeInsets.bottom
        
        let sectionWeekDays = AvailibilityHeaderFooterProvider.init((AvailabilityHeaderView.identfier, 40.0, AvailabilityHeaderModel(VCLiteral.WEEK_DAYS.localized)), nil,
                                                                    [AvailabilityCellProvider.init(
                                                                        (AvailabilityCollCell.identfier, sectionWeekDaysCellHeight,
                                                                         AvailabilityCellModel.init(model?.weekDays, weekDaySizeProvider, WeekDayCell.identfier)),
                                                                        nil, nil)]
        )
        
        //MARK:--------DATES
        let dateCellSizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: 112.0, height: 56.0), interItemSpacing: 0.0, lineSpacing: 16.0, edgeInsets: UIEdgeInsets.init(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0))
        let sectionDateCellHeight = dateCellSizeProvider.cellSize.height + dateCellSizeProvider.edgeInsets.top + dateCellSizeProvider.edgeInsets.bottom
        
        let sectionDates = AvailibilityHeaderFooterProvider.init((AvailabilityHeaderView.identfier, 40.0, AvailabilityHeaderModel.init("Select date")), nil, [AvailabilityCellProvider.init((AvailabilityCollCell.identfier, sectionDateCellHeight, AvailabilityCellModel.init(model?.weekDays, dateCellSizeProvider, DateCell.identfier)), nil, nil)])
        
        //MARK:---------TIME_SLOTS
        var timeSlots = [AvailabilityCellProvider]()
        
        model?.timeSlots.forEach({ (slot) in
            timeSlots.append(AvailabilityCellProvider.init((AvailabilityTimeSlotCell.identfier, UITableView.automaticDimension, AvailabilityCellModel.init(slot)), nil, nil))
        })
        
        let sectionSlots = AvailibilityHeaderFooterProvider.init((AvailabilityHeaderView.identfier, 40.0, AvailabilityHeaderModel.init(VCLiteral.ADD_AVAILABILITY.localized)), (AvailabilityFooterView.identfier, 40.0, AvailabilityFooterModel.init(VCLiteral.NEW_INTERVAL.localized)), timeSlots)
        
        switch model?.type ?? .WhileLoginModule {
        case .WhileLoginModule:
            return [sectionWeekDays, sectionSlots]
        case .WhileManaging:
            return [sectionDates, sectionSlots]
        }
    }
}

class AvailabilityCellProvider: CellModelProvider {
    
    typealias CellModelType = AvailabilityCellModel
    
    var property: (identifier: String, height: CGFloat, model: AvailabilityCellModel?)?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: (identifier: String, height: CGFloat, model: AvailabilityCellModel?)?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}

class AvailabilityHeaderModel {
    var title: String?
    
    init(_ _title: String?) {
        title = _title
    }
}

class AvailabilityFooterModel {
    var btnTitle: String?
    
    init(_ _btnTitle: String?) {
        btnTitle = _btnTitle
    }
}

class AvailabilityCellModel {
    var collectionCellId: String?
    var collItems: [WeekdayOrDate]?
    var collSizeProvider: CollectionSizeProvider?
    var timeSlot: TimeSlot?
    
    init(_ _items: [WeekdayOrDate]?, _ collSize: CollectionSizeProvider?, _ _collectionCellId: String?) {
        collItems = _items
        collSizeProvider = collSize
        collectionCellId = _collectionCellId
    }
    
    init(_ _timeSlot: TimeSlot?) {
        timeSlot = _timeSlot
    }
}

class TimeSlot {
    var startTime: Date?
    var endTime: Date?
    
    var isFirstItem: Bool? = false
    
    init(_ _isFirstItem: Bool? = false) {
        isFirstItem = _isFirstItem
    }
    
    init(_ slot: Slot?, _ _isFirstTime: Bool?) {
        isFirstItem = _isFirstTime
        startTime = Date.init(fromString: /slot?.start_time, format: DateFormat.custom("h:mm a"))
        endTime = Date.init(fromString: /slot?.end_time, format: DateFormat.custom("h:mm a"))
    }
}

class WeekdayOrDate {
    var weekDay: String?
    var date: Date?
    var isSelected: Bool? = false
    
    init(_ _weekday: String?) {
        weekDay = _weekday
    }
    
    init(_ _date: Date) {
        date = _date
    }
}


