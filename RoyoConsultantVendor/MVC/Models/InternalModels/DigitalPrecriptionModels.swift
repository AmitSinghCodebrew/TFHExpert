//
//  DigitalPrecriptionModels.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 09/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class DigitalPresHeaderFooterProvider: HeaderFooterModelProvider {
    
    typealias CellModelType = DigitalPresCellProvider
    
    typealias HeaderModelType = DigitalHeaderModel
    
    typealias FooterModelType = DigitalFooterModel
    
    var headerProperty: HeaderProperty?
    
    var footerProperty: FooterProperty?
    
    var items: [DigitalPresCellProvider]?
    
    required init(_ _header: HeaderProperty?, _ _footer: FooterProperty?, _ _items: [DigitalPresCellProvider]?) {
        headerProperty = _header
        footerProperty = _footer
        items = _items
    }
    
    class func getArray(request: Requests?) -> [DigitalPresHeaderFooterProvider] {
        let section = DigitalPresHeaderFooterProvider.init(nil, (DosageFooterView.identfier, 80, DigitalFooterModel(.ADD, .RESET)), [
            DigitalPresCellProvider.init((DosageTypeCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(DosageTiming.init(true, .Breakfast, .Before, nil), nil, nil)), nil, nil),
            DigitalPresCellProvider.init((DosageTypeCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(DosageTiming.init(false, .Lunch, .Before, nil), nil, nil)), nil, nil),
            DigitalPresCellProvider.init((DosageTypeCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(DosageTiming.init(false, .Dinner, .Before, nil), nil, nil)), nil, nil)
        ])
        
        var medicineCells = [DigitalPresCellProvider]()
        request?.pre_scription?.medicines?.forEach({ (medicine) in
            medicineCells.append(DigitalPresCellProvider.init((MedicineCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(nil, medicine, nil)), nil, nil))
        })
        
        let sectionMedicines = DigitalPresHeaderFooterProvider.init((MedicineHeaderView.identfier, 48.0, DigitalHeaderModel.init(.PRESCRIPTIONS)), nil, medicineCells)
        if /medicineCells.count > 0 {
            return [section, sectionMedicines]
        } else {
            return [section]
        }
    }
    
    class func getDosageTimeSection(for prescription: Prescription?, indexPath: IndexPath) -> DigitalPresHeaderFooterProvider {
      
        let section = DigitalPresHeaderFooterProvider.init(nil, (DosageFooterView.identfier, 80, DigitalFooterModel(.SAVE, .RESET, _indexPath: indexPath)), [
            DigitalPresCellProvider.init((DosageTypeCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(DosageTiming.init(true, .Breakfast, .Before, nil), nil, .init(VCLiteral.DOSAGE_TYPE_1.localized, .DOSAGE_TYPE_1))), nil, nil),
            DigitalPresCellProvider.init((DosageTypeCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(DosageTiming.init(false, .Lunch, .Before, nil), nil, .init(VCLiteral.DOSAGE_TYPE_2.localized, .DOSAGE_TYPE_2))), nil, nil),
            DigitalPresCellProvider.init((DosageTypeCell.identfier, UITableView.automaticDimension, DigitalPresCellModel.init(DosageTiming.init(false, .Dinner, .Before, nil), nil, .init(VCLiteral.DOSAGE_TYPE_3.localized, .DOSAGE_TYPE_3))), nil, nil)
        ])
        
        if let breakfast = prescription?.dosage_timing?.filter({/$0.time == DoseTime.Breakfast.rawValue}).first {
            section.items?[0].property?.model?.doseTime = DosageTiming.init(true, .Breakfast, DoseTimingWith(rawValue: /breakfast.with), /breakfast.dose_value)
            section.items?[0].property?.model?.dosageType = .init(VCLiteral.DOSAGE_TYPE_1.localized, .DOSAGE_TYPE_1)
        }
        
        if let lunch = prescription?.dosage_timing?.filter({/$0.time == DoseTime.Lunch.rawValue}).first {
            section.items?[1].property?.model?.doseTime = DosageTiming.init(true, .Lunch, DoseTimingWith(rawValue: /lunch.with), /lunch.dose_value)
            section.items?[1].property?.model?.dosageType = .init(VCLiteral.DOSAGE_TYPE_2.localized, .DOSAGE_TYPE_2)
        }
        
        if let dinner = prescription?.dosage_timing?.filter({/$0.time == DoseTime.Dinner.rawValue}).first {
            section.items?[2].property?.model?.doseTime = DosageTiming.init(true, .Lunch, DoseTimingWith(rawValue: /dinner.with), /dinner.dose_value)
            section.items?[2].property?.model?.dosageType = .init(VCLiteral.DOSAGE_TYPE_3.localized, .DOSAGE_TYPE_3)
        }
        return section
    }
}

class DigitalHeaderModel {
    var title: VCLiteral?
    
    init(_ _title: VCLiteral) {
        title = _title
    }
}

class DigitalFooterModel {
    var addTitle: VCLiteral?
    var resetTitle: VCLiteral?
    var indexPath: IndexPath?
    
    init(_ _addTitle: VCLiteral, _ _resetTitle: VCLiteral, _indexPath: IndexPath? = nil) {
        addTitle = _addTitle
        resetTitle = _resetTitle
        indexPath = _indexPath
    }
}

class DigitalPresCellProvider: CellModelProvider {
    
    typealias CellModelType = DigitalPresCellModel

    var property: Property?
    
    var leadingSwipeConfig: SKSwipeActionConfig?
    
    var trailingSwipeConfig: SKSwipeActionConfig?
    
    required init(_ _property: Property?, _ _leadingSwipe: SKSwipeActionConfig?, _ _trailingSwipe: SKSwipeActionConfig?) {
        property = _property
        leadingSwipeConfig = _leadingSwipe
        trailingSwipeConfig = _trailingSwipe
    }
}


class DigitalPresCellModel {
    var doseTime: DosageTiming?
    var prescription: Prescription?
    var dosageType: DosageType?
    
    init(_ _doseTime: DosageTiming?, _ _prescription: Prescription?, _ _dosageType: DosageType?) {
        doseTime = _doseTime
        prescription = _prescription
    }
}

class DosageTiming {
    var isSelected: Bool?
    var time: DoseTime?
    var with: DoseTimingWith?
    var dose_value: String?
    
    init(_ _isSelected: Bool?, _ _time: DoseTime?, _ _with: DoseTimingWith?, _ _dose_value: String?) {
        isSelected = _isSelected
        time = _time
        with = _with
        dose_value = _dose_value
    }
}

enum DoseTimingWith: String {
    case Before = "Before"
    case After = "After"
    case With = "With"
    
    var relatedIndex: Int {
        switch self {
        case .Before:
            return 0
        case .After:
            return 1
        case .With:
            return 2
        }
    }
    
    var title: VCLiteral {
        switch self {
        case .Before:
            return .DoseTimingWith_1
        case .After:
            return .DoseTimingWith_2
        case .With:
            return .DoseTimingWith_3
        }
    }
}

enum DoseTime: String {
    case Breakfast = "Breakfast"
    case Lunch = "Lunch"
    case Dinner = "Dinner"
    
    var title: VCLiteral {
        switch self {
        case .Breakfast:
            return .DoseTime_1
        case .Lunch:
            return .DoseTime_2
        case .Dinner:
            return .DoseTime_3
        }
    }
}

class DurationDay: SKGenericPickerModelProtocol {
    
    typealias ModelType = String

    var title: String?
    
    var model: String?
    
    required init(_ _title: String?, _ _model: String?) {
        title = _title
        model = _title
    }
    
    class func getArray() -> [DurationDay] {
        var durations = [DurationDay]()
        for number in 1...30 {
            durations.append(DurationDay.init(String.init(format: number == 1 ? VCLiteral.SINGLE_DIGIT_DAY.localized : VCLiteral.MULTI_DIGIT_DAY.localized, String(number)), nil))
        }
        return durations
    }
}

class DosageType: SKGenericPickerModelProtocol {
    
    typealias ModelType = VCLiteral
    
    var title: String?
    
    var model: VCLiteral?
    
    required init(_ _title: String?, _ _model: VCLiteral?) {
        title = _title
        model = _model
    }
    
    class func getDosageTypes() -> [DosageType] {
        return [DosageType(VCLiteral.DOSAGE_TYPE_1.localized, .DOSAGE_TYPE_1),
                DosageType(VCLiteral.DOSAGE_TYPE_2.localized, .DOSAGE_TYPE_2),
                DosageType(VCLiteral.DOSAGE_TYPE_3.localized, .DOSAGE_TYPE_3)]
    }
    
    func getRelatedDosageValues() -> [DoseValuePickerModel] {
        switch model ?? .DOSAGE {
        case .DOSAGE_TYPE_3: //Syrup
            var values = [DoseValuePickerModel]()
            for number in 1...50 {
                values.append(DoseValuePickerModel.init(String.init(format: VCLiteral.ML.localized, String(number)), nil))
            }
            return values
        default:
            return [DoseValuePickerModel.init(VCLiteral.DoseValue_1.localized, nil),
                    DoseValuePickerModel.init(VCLiteral.DoseValue_2.localized, nil),
                    DoseValuePickerModel.init(VCLiteral.DoseValue_3.localized, nil),
                    DoseValuePickerModel.init(VCLiteral.DoseValue_4.localized, nil),
                    DoseValuePickerModel.init(VCLiteral.DoseValue_5.localized, nil)]
        }
    }
}

class DoseValuePickerModel: SKGenericPickerModelProtocol {
    var title: String?
    
    var model: String?
    
    required init(_ _title: String?, _ _model: String?) {
        model = _title
        title = _title
    }
    
    typealias ModelType = String
    
    class func getArray() -> [DoseValuePickerModel] {
        return [DoseValuePickerModel.init(VCLiteral.DoseValue_1.localized, nil),
                DoseValuePickerModel.init(VCLiteral.DoseValue_2.localized, nil),
                DoseValuePickerModel.init(VCLiteral.DoseValue_3.localized, nil),
                DoseValuePickerModel.init(VCLiteral.DoseValue_4.localized, nil),
                DoseValuePickerModel.init(VCLiteral.DoseValue_5.localized, nil)]
    }
    
}

class Prescription: Codable {
    var id: Int?
    var medicine_name: String?
    var duration: String?
    var dosage_type: String?
    var dosage_timing: [DosageTimingBackend]?
    
    init(_ _medicineName: String?, _ _duration: String?, _ _dosageType: String?, timings: [DosageTiming]?) {
        medicine_name = _medicineName
        duration = _duration
        dosage_type = _dosageType
        var tempArray = [DosageTimingBackend]()
        timings?.forEach( { tempArray.append(DosageTimingBackend.init($0)) } )
        dosage_timing = tempArray
    }
}

class DosageTimingBackend: Codable {
    var time: String?
    var with: String?
    var dose_value: String?
    
    init(_ model: DosageTiming?) {
        time = model?.time?.rawValue
        with = model?.with?.rawValue
        dose_value = model?.dose_value
    }
}
