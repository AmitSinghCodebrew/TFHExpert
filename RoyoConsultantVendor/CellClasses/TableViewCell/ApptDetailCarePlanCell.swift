//
//  ApptDetailCarePlanCell.swift
//  NurseLynxExpert
//
//  Created by Sandeep Kumar on 27/04/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class ApptDetailCarePlanCell: UITableViewCell, ReusableCell {
        
    typealias T = AppDetailCellModel
    
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var btnTick: UIButton!
    @IBOutlet weak var viewmarkDone: UIView!
    @IBOutlet weak var lblMarkDone: UILabel!
    
    public var reloadCell: (() -> Void)?
    
    var item: AppDetailCellModel? {
        didSet {
            lblText.text = "\(/item?.property?.model?.tierOption?.title) (\(/item?.property?.model?.tierOption?.type?.localized))"
            switch item?.property?.model?.tierOption?.status ?? .pending {
            case .pending:
                viewmarkDone.isHidden = false
                btnTick.isHidden = true
            case .completed:
                viewmarkDone.isHidden = true
                btnTick.isHidden = false
            }
            lblMarkDone.text = VCLiteral.MARK_DONE_MULTI_LINE.localized
            lblMarkDone.addTapGestureRecognizer { [weak self] in
                self?.markDoneAlert()
            }
        }
    }
    
    private func markDoneAlert() {
        UIApplication.topVC()?.alertBoxOKCancel(title: VCLiteral.MARK_DONE.localized, message: VCLiteral.MARK_COMPLETE_ALERT.localized, tapped: { [weak self] in
            self?.updateAPI()
        }, cancelTapped: nil)
    }
    
    private func updateAPI() {
        (UIApplication.topVC() as? BaseVC)?.playLineAnimation()
        EP_Home.updateCarePlan(id: item?.property?.model?.tierOption?.id, requestId: item?.property?.model?.request?.id, status: .completed).request { [weak self] (response) in
            self?.item?.property?.model?.tierOption?.status = .completed
            self?.reloadCell?()
            (UIApplication.topVC() as? BaseVC)?.stopLineAnimation()
        } error: { (error) in
            (UIApplication.topVC() as? BaseVC)?.stopLineAnimation()
        }

    }
}
