//
//  DosageTypeCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 09/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class DosageTypeCell: UITableViewCell, ReusableCell {

    typealias T = DigitalPresCellProvider
    
    @IBOutlet weak var viewBAWD: UIView! //Before After With Dosage
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSaveEdit: UIButton!
    @IBOutlet weak var btnTick: UIButton!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var tfDosage: JVFloatLabeledTextField!
    
    var reloadCell: (() -> Void)?
    
    var item: DigitalPresCellProvider? {
        didSet {
            btnTick.backgroundColor = /item?.property?.model?.doseTime?.isSelected ? ColorAsset.appTint.color : UIColor.clear
            btnTick.setImage(/item?.property?.model?.doseTime?.isSelected ? #imageLiteral(resourceName: "ic_tick") : nil, for: .normal)
            lblTitle.text = item?.property?.model?.doseTime?.time?.title.localized
            segments.removeAllSegments()
            segments.insertSegment(withTitle: DoseTimingWith.Before.title.localized, at: 0, animated: false)
            segments.insertSegment(withTitle: DoseTimingWith.After.title.localized, at: 1, animated: false)
            segments.insertSegment(withTitle: DoseTimingWith.With.title.localized, at: 2, animated: false)
            
            segments.selectedSegmentIndex = /item?.property?.model?.doseTime?.with?.relatedIndex
            
            tfDosage.inputView = SKGenericPicker<DoseValuePickerModel>.init(frame: CGRect.zero, items: item?.property?.model?.dosageType?.getRelatedDosageValues() ?? DoseValuePickerModel.getArray(), configureItem: { [weak self] (value) in
                self?.tfDosage.text = /value?.title
                self?.item?.property?.model?.doseTime?.dose_value = /value?.title
            })
            tfDosage.placeholder = item?.property?.model?.dosageType?.title ?? VCLiteral.DOSAGE.localized
            tfDosage.text = /item?.property?.model?.doseTime?.dose_value
            viewBAWD.isHidden = !(/item?.property?.model?.doseTime?.isSelected)
        }
    }

    @IBAction func btnTickAction(_ sender: UIButton) {
        item?.property?.model?.doseTime?.isSelected = !(/item?.property?.model?.doseTime?.isSelected)
        reloadCell?()
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            item?.property?.model?.doseTime?.with = .Before
        case 1:
            item?.property?.model?.doseTime?.with = .After
        case 2:
            item?.property?.model?.doseTime?.with = .With
        default: break
        }
    }
    
}
