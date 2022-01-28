//
//  PregnantSuccessVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 10/12/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import Lottie

class PregnantSuccessPopUpVC: BaseVC {

    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLottie: UIView! {
        didSet {
            viewLottie.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var lblPregnancyTimelineTitle: UILabel!
    @IBOutlet weak var progressBarTrimester1: UIProgressView!
    @IBOutlet weak var lblTrimester1: UILabel!
    @IBOutlet weak var lblTrimester1Value: UILabel!
    @IBOutlet weak var progressBarTrimester2: UIProgressView!
    @IBOutlet weak var lblTrimester2: UILabel!
    @IBOutlet weak var lblTrimester2Value: UILabel!
    @IBOutlet weak var progressBarTrimester3: UIProgressView!
    @IBOutlet weak var lblTrimester3: UILabel!
    @IBOutlet weak var lblTrimester3Value: UILabel!
    @IBOutlet weak var lblZodiac: UILabel!
    
    lazy var pregnantWomen: AnimationView = {
        let anView = AnimationView()
        anView.backgroundColor = UIColor.clear
        anView.animation = Animation.named(LottieFiles.PregnantWomen.getFileName(), bundle: .main, subdirectory: nil, animationCache: nil)
        anView.loopMode = .loop
        anView.contentMode = .scaleAspectFill
        return anView
    }()
    
    var dueDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSetup()
        visualEffectView.isHidden = true
        pregnantWomen.frame = viewLottie.bounds
        pregnantWomen.play()
        viewLottie.addSubview(pregnantWomen)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.unhideVisualEffectView()
        }
    }

    @IBAction func btnBackAction(_ sender: UIButton) {
        hideVisulEffectView()
    }
    
    private func dataSetup() {
        lblTitle.text = VCLiteral.PREGNANCY_SUCCESS.localized
        
        let pregnancyStartDate = dueDate?.dateBySubtractingDays(280) ?? Date()
        let pregnancyTime = Date().daysAfterDate(pregnancyStartDate)
        
        let weeks = pregnancyTime / 7
        let days = pregnancyTime % 7
        
        lblDueDate.text = String.init(format: VCLiteral.DUE_DATE_IS.localized, arguments: [/dueDate?.toString(DateFormat.custom(UserPreference.shared.dateFormat), isForAPI: false), String(weeks), String(days)])
        
        lblPregnancyTimelineTitle.text = VCLiteral.PREGNANCY_TIMELINE.localized
        lblTrimester1.text = VCLiteral.TRIMESTER_1.localized
        lblTrimester2.text = VCLiteral.TRIMESTER_2.localized
        lblTrimester3.text = VCLiteral.TRIMESTER_3.localized
        
        let trimesterDifference = 280 / 3
        let trimester1StartDate = pregnancyStartDate
        let trimester1EndDate = pregnancyStartDate.dateByAddingDays(trimesterDifference).dateBySubtractingDays(3)
        let trimester2StartDate = trimester1EndDate.dateByAddingDays(1)
        let trimester2EndDate = trimester2StartDate.dateByAddingDays(trimesterDifference).dateByAddingDays(4)
        let trimester3StartDate = trimester2EndDate.dateByAddingDays(1)
        let trimester3EndDate = trimester3StartDate.dateByAddingDays(trimesterDifference).dateBySubtractingDays(2)
        
        lblTrimester1Value.text = String.init(format: VCLiteral.TRIMESTER_VALUE.localized, arguments: [/trimester1StartDate.toString(DateFormat.custom("MMM dd"), isForAPI: false), /trimester1EndDate.toString(DateFormat.custom("MMM dd"), isForAPI: false)])
        lblTrimester2Value.text = String.init(format: VCLiteral.TRIMESTER_VALUE.localized, arguments: [/trimester2StartDate.toString(DateFormat.custom("MMM dd"), isForAPI: false), /trimester2EndDate.toString(DateFormat.custom("MMM dd"), isForAPI: false)])
        lblTrimester3Value.text = String.init(format: VCLiteral.TRIMESTER_VALUE.localized, arguments: [/trimester3StartDate.toString(DateFormat.custom("MMM dd"), isForAPI: false), /trimester3EndDate.toString(DateFormat.custom("MMM dd"), isForAPI: false)])

        let currentDate = Date()
        
        if currentDate.isEarlierThanDate(trimester1EndDate) { //Lies in 1st Trimester
            let percentage = (currentDate.timeIntervalSince1970 - trimester1StartDate.timeIntervalSince1970) * 100 / (trimester1EndDate.timeIntervalSince1970 - trimester1StartDate.timeIntervalSince1970)
            progressBarTrimester1.progress = Float(percentage) * 0.01
            progressBarTrimester2.progress = 0.0
            progressBarTrimester3.progress = 0.0
        } else if currentDate.isEarlierThanDate(trimester2EndDate) { //Lies in 2nd Trimester
            progressBarTrimester1.progress = 1.0
            let percentage = (currentDate.timeIntervalSince1970 - trimester2StartDate.timeIntervalSince1970) * 100 / (trimester2EndDate.timeIntervalSince1970 - trimester2StartDate.timeIntervalSince1970)
            progressBarTrimester2.progress = Float(percentage) * 0.01
            progressBarTrimester3.progress = 0.0
        } else { //Lies in 3rd Trimester
            progressBarTrimester1.progress = 1.0
            progressBarTrimester2.progress = 1.0
            let percentage = (currentDate.timeIntervalSince1970 - trimester3StartDate.timeIntervalSince1970) * 100 / (trimester3EndDate.timeIntervalSince1970 - trimester3StartDate.timeIntervalSince1970)
            progressBarTrimester3.progress = Float(percentage) * 0.01
        }
        
        lblZodiac.text = String(format: VCLiteral.ZODIAC.localized, arguments: [getZodiacSign(for: dueDate!).title.localized])
    }
    
    private func unhideVisualEffectView() {
        visualEffectView.alpha = 0
        visualEffectView.isHidden = false
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.visualEffectView.alpha = 1.0
        }
    }
    
    private func hideVisulEffectView() {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.visualEffectView.alpha = 0.0
        }) { [weak self] (finished) in
            self?.visualEffectView.isHidden = true
            self?.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    private func getZodiacSign(for dob: Date) -> ZodiacSign {
        let day = dob.day()
        let month = dob.month()
        
        switch (day,month) {
        case (21...31,1),(1...19,2):
            return .aquarius
        case (20...29,2),(1...20,3):
            return .pisces
        case (21...31,3),(1...20,4):
            return .aries
        case (21...30,4),(1...21,5):
            return .taurus
        case (22...31,5),(1...21,6):
            return .gemini
        case (22...30,6),(1...22,7):
            return .cancer
        case (23...31,7),(1...22,8):
            return .leo
        case (23...31,8),(1...23,9):
            return .virgo
        case (24...30,9),(1...23,10):
            return .libra
        case (24...31,10),(1...22,11):
            return .scorpio
        case (23...30,11),(1...21,12):
            return .sagittarius
        default:
            return .capricorn
        }
    }
}

public enum ZodiacSign {
    case aries
    case cancer
    case taurus
    case leo
    case gemini
    case virgo
    case libra
    case capricorn
    case scorpio
    case aquarius
    case sagittarius
    case pisces
    
    var title: VCLiteral {
        switch self {
        case .aries:
            return .aries
        case .cancer:
            return .cancer
        case .taurus:
            return .taurus
        case .leo:
            return .leo
        case .gemini:
            return .gemini
        case .virgo:
            return .virgo
        case .libra:
            return .virgo
        case .capricorn:
            return .capricorn
        case .scorpio:
            return .scorpio
        case .aquarius:
            return .aquarius
        case .sagittarius:
            return .sagittarius
        case .pisces:
            return .pisces
        }
    }
}
