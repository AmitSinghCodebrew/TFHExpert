//
//  BMI_CalVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 09/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
#if HealExpert || RoyoConsultExpert
import ABGaugeViewKit
#endif

class BMI_CalVC: BaseVC {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblheight: UILabel!
    @IBOutlet weak var tfWeight: UITextField!
    @IBOutlet weak var tfGender: UITextField!
    @IBOutlet weak var tfheight: UITextField!
    @IBOutlet weak var lblKg: UILabel!
    @IBOutlet weak var lblCM: UILabel!
    @IBOutlet weak var lblYourBMI: UILabel!
    @IBOutlet weak var lblBMI_Value: UILabel!
    #if HealExpert || RoyoConsultExpert
    @IBOutlet weak var guageView: ABGaugeView!
    #endif
    @IBOutlet weak var lblBMIType: UILabel!
    @IBOutlet weak var lblBMIRange: UILabel!
    
    private var selectedGender: Gender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func btnPlayAction(_ sender: UIButton) {
        let isValid = Validation.shared.validate(values: (.WEIGHT, /tfWeight.text), (.HEIGHT, /tfheight.text))
        
        switch isValid {
        case .success:
            break
        case .failure(let alertType, let message):
            Toast.shared.showAlert(type: alertType, message: message.localized)
            return
        }
        
        let bmi = calculateBMI(mass: tfWeight.text, height: tfheight.text)
        lblBMI_Value.text = /String(format: "%0.2f", /bmi?.BMI)
        lblBMIType.text = /bmi?.Interpretation
        lblBMIRange.text = /bmi?.BMI_Range
        let bmiValue = /Double(/bmi?.BMI)
        
        #if HealExpert || RoyoConsultExpert
        switch true {
        case bmiValue < 18.5: //Underweight
            guageView.needleValue = CGFloat((bmiValue / 18.5) * 33)
        case bmiValue > 18.5 && bmiValue <= 25: //Normal
            guageView.needleValue = CGFloat((bmiValue / 25) * 66)
        case bmiValue > 25 && bmiValue <= 30: //OverWeight
            guageView.needleValue = 82
        case bmiValue >= 30: //OverWeight
            guageView.needleValue = 100
        default:
            break
        }
        #endif
    }
}

//MARK:- VCFuncs
extension BMI_CalVC {
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.HEALTH_TOOL_01_TITLE.localized
        lblGender.text = VCLiteral.GENDER.localized
        lblWeight.text = VCLiteral.WEIGHT.localized
        lblheight.text = VCLiteral.HEIGHT.localized
        lblKg.text = VCLiteral.KG.localized
        lblCM.text = VCLiteral.CM.localized
        lblYourBMI.text = VCLiteral.YOUR_BMI.localized
        selectedGender = Gender.getGenders().first
        tfGender.text = /selectedGender?.title
        lblBMIRange.text = ""
        lblBMIType.text = ""
        
        tfGender.inputView = SKGenericPicker<Gender>.init(frame: .zero, items: Gender.getGenders(), configureItem: { [weak self] (selectedGender) in
            self?.tfGender.text = /selectedGender?.title
            self?.selectedGender = selectedGender
        })
    }
    
    private func calculateBMI(mass : String? , height : String?) -> (BMI: Double, Interpretation: String , BMI_Range : String)? {
        
        let isHeightInCentimeters =  !(/height?.contains("."))//height?.contains(".")
        
        var heightInMeters : Double?
        if isHeightInCentimeters {
            let squareCentimeters = Measurement(value: /Double(/height), unit: UnitArea.squareCentimeters)
            heightInMeters = squareCentimeters.value / 100
        }
        
        if let bodyComposition = BodyComposition(mass: /Double(/mass), height: isHeightInCentimeters ? /heightInMeters : /Double(/height)) {
            let out: (BMI: Double, Interpretation: String , BMI_Range : String)
            
            switch bodyComposition {
            
            case .overweight(let bmi):
                out = (BMI: bmi, Interpretation: VCLiteral.OVERWEIGHT.localized, BMI_Range : ">25")
            case .healthy(let bmi):
                out = (BMI: bmi, Interpretation: VCLiteral.NORMAL.localized, BMI_Range : "18.5-25")
            case .underweight(let bmi):
                out = (BMI: bmi, Interpretation: VCLiteral.UNDERWEIGHT.localized, BMI_Range : "0-18.5")
            }
            
            print("Your BMI is \(String(format: "%0.1f", out.BMI)). \(out.Interpretation) The BMI of a healthy guy is between 18.5 & 25")
            
            return out
        } else {
            return (BMI: 0, Interpretation: VCLiteral.UNDERWEIGHT.localized, BMI_Range : "0-18")
        }
    }
    
}

//MARK:- BODY Composition
enum BodyComposition {
    case overweight(bmi: Double)
    case healthy(bmi: Double)
    case underweight(bmi: Double)
}

extension BodyComposition {
    init?(mass: Double, height: Double)
    {
        guard height > 0 && mass > 0 else {
            return nil
        }
        
        let bmi = mass / pow(height, 2)
        
        switch bmi {
        case _ where bmi > 25:
            self = .overweight(bmi: bmi)
        case _ where bmi >= 18.5:
            self = .healthy(bmi: bmi)
        default:
            self = .underweight(bmi: bmi)
        }
    }
    
    init?(weightInPounds : Double, heightInFeet: Double, remainderInches: Double) {
        let weightInKg     = weightInPounds * 0.45359237
        let totalInches    = (heightInFeet * 12) + remainderInches
        let heightInMeters = totalInches * 0.0254
        
        self.init(mass: weightInKg, height: heightInMeters)
    }
}
