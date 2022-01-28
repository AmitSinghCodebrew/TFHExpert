//
//  PregnancyModels.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 10/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import Foundation

enum CycleLength: Int, CaseIterable {
    case NA = 0
    case Days_21 = 21
    case Days_22 = 22
    case Days_23 = 23
    case Days_24 = 24
    case Days_25 = 25
    case Days_26 = 26
    case Days_27 = 27
    case Days_28 = 28
    case Days_29 = 29
    case Days_30 = 30
    case Days_31 = 31
    case Days_32 = 32
    case Days_33 = 33
    case Days_34 = 34
    case Days_35 = 35
    
    var title: VCLiteral {
        switch self {
        case .NA:
            return .CycleLength_NA
        case .Days_21:
            return .CycleLength_Days_21
        case .Days_22:
            return .CycleLength_Days_22
        case .Days_23:
            return .CycleLength_Days_23
        case .Days_24:
            return .CycleLength_Days_24
        case .Days_25:
            return .CycleLength_Days_25
        case .Days_26:
            return .CycleLength_Days_26
        case .Days_27:
            return .CycleLength_Days_27
        case .Days_28:
            return .CycleLength_Days_28
        case .Days_29:
            return .CycleLength_Days_29
        case .Days_30:
            return .CycleLength_Days_30
        case .Days_31:
            return .CycleLength_Days_31
        case .Days_32:
            return .CycleLength_Days_32
        case .Days_33:
            return .CycleLength_Days_33
        case .Days_34:
            return .CycleLength_Days_34
        case .Days_35:
            return .CycleLength_Days_35
        }
    }
}

class PeriodCycle: SKGenericPickerModelProtocol {
    typealias ModelType = CycleLength

    var title: String?
    
    var model: CycleLength?
    
    required init(_ _title: String?, _ _model: CycleLength?) {
        title = _title
        model = _model
    }
    
    class func getArray() -> [PeriodCycle] {
        var array = [PeriodCycle]()
        CycleLength.allCases.forEach { (cycle) in
            array.append(PeriodCycle.init(cycle.title.localized, cycle))
        }
        return array
    }
}

enum CalculationMethod: Int {
    case LastPeriod = 1
    case ConceptionDate = 2
    case IVF = 3
    case Ultrasound = 4
    
    var title: VCLiteral {
        switch self {
        case .LastPeriod:
            return .LAST_PERIOD
        case .ConceptionDate:
            return .CONCEPTION_DATE
        case .IVF:
            return .IVF
        case .Ultrasound:
            return .ULTRASOUND
        }
    }
}

enum IVF_TransferDateType {
    case ThreeDays
    case FiveDays
}

class UltraWeek: SKGenericPickerModelProtocol {
    typealias ModelType = UltrasoundWeek

    var title: String?
    
    var model: UltrasoundWeek?
    
    required init(_ _title: String?, _ _model: UltrasoundWeek?) {
        title = _title
        model = _model
    }
    
    class func getArray() -> [UltraWeek] {
        var array = [UltraWeek]()
        UltrasoundWeek.allCases.forEach { (week) in
            array.append(UltraWeek.init(week.title.localized, week))
        }
        return array
    }
}

class UltraDay: SKGenericPickerModelProtocol {
    
    typealias ModelType = UltrasoundDay

    var title: String?
    
    var model: UltrasoundDay?
    
    required init(_ _title: String?, _ _model: UltrasoundDay?) {
        title = _title
        model = _model
    }
    
    class func getArray() -> [UltraDay] {
        var array = [UltraDay]()
        UltrasoundDay.allCases.forEach { (day) in
            array.append(UltraDay.init(day.title.localized, day))
        }
        return array
    }
}

enum UltrasoundDay: Int, CaseIterable {
    case Zero = 0
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    
    var title: VCLiteral {
        switch self {
        case .Zero:
            return .UltrasoundDay_Zero
        case .One:
            return .UltrasoundDay_One
        case .Two:
            return .UltrasoundDay_Two
        case .Three:
            return .UltrasoundDay_Three
        case .Four:
            return .UltrasoundDay_Four
        case .Five:
            return .UltrasoundDay_Five
        case .Six:
            return .UltrasoundDay_Six
        }
    }
}

enum UltrasoundWeek: Int, CaseIterable {
    
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
    case Five = 5
    case Six = 6
    case Seven = 7
    case Eight = 8
    case Nine = 9
    case Ten = 10
    case Eleven = 11
    case Twelve = 12
    case Thirteen = 13
    case Fourteen = 14
    case Fifteen = 15
    case Sixteen = 16
    case Seventeen = 17
    case Eighteen = 18
    case Nineteen = 19
    case Twenty = 20
    case TwentyOne = 21
    case TwentyTwo = 22
    case TwentyThree = 23
    case TwentyFour = 24
    
    var title: VCLiteral {
        switch self {
        case .One:
            return .UltrasoundWeek_One
        case .Two:
            return .UltrasoundWeek_Two
        case .Three:
            return .UltrasoundWeek_Three
        case .Four:
            return .UltrasoundWeek_Four
        case .Five:
            return .UltrasoundWeek_Five
        case .Six:
            return .UltrasoundWeek_Six
        case .Seven:
            return .UltrasoundWeek_Seven
        case .Eight:
            return .UltrasoundWeek_Eight
        case .Nine:
            return .UltrasoundWeek_Nine
        case .Ten:
            return .UltrasoundWeek_Ten
        case .Eleven:
            return .UltrasoundWeek_Eleven
        case .Twelve:
            return .UltrasoundWeek_Twelve
        case .Thirteen:
            return .UltrasoundWeek_Thirteen
        case .Fourteen:
            return .UltrasoundWeek_Fourteen
        case .Fifteen:
            return .UltrasoundWeek_Fifteen
        case .Sixteen:
            return .UltrasoundWeek_Sixteen
        case .Seventeen:
            return .UltrasoundWeek_Seventeen
        case .Eighteen:
            return .UltrasoundWeek_Eighteen
        case .Nineteen:
            return .UltrasoundWeek_Nineteen
        case .Twenty:
            return .UltrasoundWeek_Twenty
        case .TwentyOne:
            return .UltrasoundWeek_TwentyOne
        case .TwentyTwo:
            return .UltrasoundWeek_TwentyTwo
        case .TwentyThree:
            return .UltrasoundWeek_TwentyThree
        case .TwentyFour:
            return .UltrasoundWeek_TwentyFour
        }
    }
}
