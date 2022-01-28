//
//  WaterIntakeCalVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/11/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import Lottie

class WaterIntakeCalVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnDrinkWater: SKButton!
    @IBOutlet weak var btnAdd: SKLottieButton!
    @IBOutlet weak var viewLottieWrapper: UIView! {
        didSet {
            viewLottieWrapper.backgroundColor = UIColor.clear
        }
    }
    @IBOutlet weak var lblWaterIntakeTitle: UILabel!
    @IBOutlet weak var lblDailyLimitTitle: UILabel!
    @IBOutlet weak var lblDaysTitle: UILabel!
    @IBOutlet weak var lblWaterIntakeValue: UILabel!
    @IBOutlet weak var lblDailyLimitValue: UILabel!
    @IBOutlet weak var lblDaysValue: UILabel!
    
    private var glasses: [WaterGlass] = WaterGlass.getGlasses()
    private var collectionDataSource: CollectionDataSource?
    private var intakeData: WaterIntakeData? {
        didSet {
            setData()
        }
    }
    
    lazy var waterView: AnimationView = {
        let anView = AnimationView()
        anView.backgroundColor = UIColor.clear
        anView.animation = Animation.named("water", bundle: .main, subdirectory: nil, animationCache: nil)
        anView.loopMode = .playOnce
        anView.contentMode = .scaleAspectFill
        return anView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGlasses()
        getDailyLimit()
        setData()
        waterView.frame = viewLottieWrapper.bounds
        waterView.play(toProgress: 0.0)
        viewLottieWrapper.addSubview(waterView)
    }

    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Back
            popVC()
        case 1: // +Add
            let alert = UIAlertController.init(title: nil, message: VCLiteral.SET_DAILY_WATER_LIMIT.localized, preferredStyle: .alert)
            alert.addTextField { (tf) in
                tf.placeholder = VCLiteral.WATER_INTAKE_IN_LITRES.localized
                tf.keyboardType = .numberPad
            }
            alert.addAction(UIAlertAction.init(title: VCLiteral.CANCEL.localized, style: .destructive, handler: nil))
            alert.addAction(UIAlertAction.init(title: VCLiteral.SET_DAILY_LIMIT.localized, style: .default, handler: { [weak self] (action) in
                self?.addDrinkTarget(for: alert.textFields?.first?.text)
            }))
            presentVC(alert)
        case 2: //Drink Water
            drinkWater()
        default:
            break
        }
    }
    
}

//MARK:- VCFuncs
extension WaterIntakeCalVC {
    private func setData() {
        lblTitle.text = VCLiteral.HEALTH_TOOL_02_TITLE.localized
        if /intakeData?.today_intake >= 1.0 {
            lblWaterIntakeValue.text = String(format: VCLiteral.LITRE.localized, /intakeData?.today_intake?.roundedString(toPlaces: 2))
        } else {
            let intakeInML = (/intakeData?.today_intake * 1000).roundedString(toPlaces: 2)
            lblWaterIntakeValue.text = String(format: VCLiteral.MILLI_LITRE.localized, intakeInML)
        }
        lblDailyLimitValue.text = String(format: VCLiteral.LITRE.localized, /(intakeData?.limit ?? 0.0)?.roundedString(toPlaces: 2))
        lblDaysValue.text = /intakeData?.total_achieved_goal?.roundedString(toPlaces: 0)
        let progress = /intakeData?.today_intake / /intakeData?.limit
        if progress <= 0.0 {
            waterView.play(toProgress: 0.0)
        } else if progress >= 1.0 {
            waterView.play(toProgress: 1.0)
        } else if progress > 0.0 {
            waterView.play(toProgress: CGFloat(progress))
        }
    }
    
    private func addDrinkTarget(for limit: String?) {
        btnDrinkWater.isUserInteractionEnabled = false
        btnDrinkWater.playAnimation()
        EP_Home.addWaterLimit(limit: limit).request { [weak self] (response) in
            self?.intakeData = response as? WaterIntakeData
            self?.btnDrinkWater.isUserInteractionEnabled = true
            self?.btnDrinkWater.stop()
        } error: { [weak self] (error) in
            self?.btnDrinkWater.isUserInteractionEnabled = true
            self?.btnDrinkWater.stop()
        }
    }
    
    private func drinkWater() {
        if /intakeData?.limit == 0.0 {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.ADD_DAILY_WATER_LIMIT.localized)
            btnDrinkWater.vibrate()
            return
        }
        guard let glass = glasses.first(where: { /$0.isSelected}) else {
            btnDrinkWater.vibrate()
            return
        }
        btnDrinkWater.playAnimation()
        let qtyInLitre = (/Double(/glass.qty) / 1000).roundedString(toPlaces: 2)
        EP_Home.drinkWater(qty: qtyInLitre).request { [weak self] (response) in
            self?.intakeData = response as? WaterIntakeData
            self?.btnDrinkWater.stop()
            self?.glasses.forEach({$0.isSelected = false})
            self?.collectionDataSource?.updateData(self?.glasses)
        } error: { [weak self] (error) in
            self?.btnDrinkWater.stop()
        }
    }
    
    private func getDailyLimit() {
        playLineAnimation()
        EP_Home.getWaterLimit.request { [weak self] (response) in
            self?.intakeData = response as? WaterIntakeData
            self?.stopLineAnimation()
        } error: { [weak self] (error) in
            self?.stopLineAnimation()
        }

    }
    
    private func setupGlasses() {
        collectionView.contentInset.right = 16 * (CGFloat(glasses.count) - 1)
        
        collectionDataSource = CollectionDataSource.init(glasses, VendorFilterCell.identfier, collectionView, CGSize.init(width: 88, height: 36), UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16), 16, 0, .horizontal)
        
        collectionDataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? VendorFilterCell)?.glass = item as? WaterGlass
        }
        
        collectionDataSource?.didSelectItem = { [weak self] (indexPath, item) in
            if /self?.glasses[indexPath.item].isSelected {
                self?.glasses[indexPath.item].isSelected = false
            } else {
                self?.glasses.forEach({$0.isSelected = false})
                self?.glasses[indexPath.item].isSelected = true
            }
            self?.collectionDataSource?.updateData(self?.glasses)
        }
    }
}
