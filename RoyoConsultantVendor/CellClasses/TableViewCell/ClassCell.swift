//
//  ClassCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 11/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ClassCell: UITableViewCell, ReusableCell {
    
    typealias T = DefaultCellModel<ClassObj>
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblUsers: UILabel!
    @IBOutlet weak var lblClassName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnStart: SKBorderButton!
    @IBOutlet weak var btnComplete: SKBorderButton!
    
    public var reloadCell: ((_ _class: ClassObj?) -> Void)?
    
    var item: DefaultCellModel<ClassObj>? {
        didSet {
            let obj = item?.property?.model
            imgView.setImageNuke(/obj?.created_by?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            lblName.text = /obj?.created_by?.profile?.title + " " + /obj?.created_by?.name?.capitalizingFirstLetter()
            lblCategory.text = String.init(format: VCLiteral.CLASS_CATEGORY.localized, /obj?.category_data?.name?.capitalizingFirstLetter())
            lblUsers.text = String.init(format: VCLiteral.USER_JOINED.localized, String(/obj?.enroll_user_data?.count))
            lblClassName.text = /obj?.name?.capitalizingFirstLetter()
            lblDate.text = Date.init(fromString: /obj?.class_date, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc).toString(DateFormat.custom("dd MMM yyyy · hh:mm a"), timeZone: .local, isForAPI: false)
            lblPrice.text = /obj?.price?.getDoubleValue?.getFormattedPrice()
            btnStart.setTitle(VCLiteral.START_CLASS.localized, for: .normal)
            btnComplete.setTitle(VCLiteral.COMPLETE_CLASS.localized, for: .normal)
            btnStart.setAnimationType(.BtnAppTintLoader)
            btnComplete.setAnimationType(.BtnAppTintLoader)
            switch obj?.status ?? .added {
            case .added:
                btnStart.isHidden = false
                btnComplete.isHidden = true
            case .started, .Default:
                btnStart.isHidden = false
                btnComplete.isHidden = false
            case .completed:
                btnStart.isHidden = true
                btnComplete.isHidden = true
            }
        }
    }
    
    @IBAction func btnAction(_ sender: SKLottieButton) {
        switch sender.tag {
        case 0: // Start Class
            startClassAlert()
        case 1: // Complete Class
            completeClassAlert()
        default:
            break
        }
    }
    
    private func completeClassAlert() {
        UIApplication.topVC()?.alertBoxOKCancel(title: VCLiteral.COMPLETE_CLASS.localized, message: VCLiteral.COMPLETE_CLASS_ALERT.localized, tapped: { [weak self] in
            self?.changeStatusOfClass(.completed, btn: self?.btnComplete)
        }, cancelTapped: nil)
    }
    
    private func startClassAlert() {
        UIApplication.topVC()?.alertBoxOKCancel(title: VCLiteral.START_CLASS.localized, message: VCLiteral.START_CLASS_ALERT.localized, tapped: { [weak self] in
            self?.changeStatusOfClass(.started, btn: self?.btnStart)
        }, cancelTapped: nil)
    }
    
    private func changeStatusOfClass(_ status: ClassStatus, btn: SKLottieButton?) {
        btn?.playAnimation()
        EP_Home.updateClassStatus(classId: String(/item?.property?.model?.id), status: status).request(success: { [weak self] (_) in
            btn?.stop()
            self?.item?.property?.model?.status = status
            self?.reloadCell?(self?.item?.property?.model)
            
            if status == .started {
                 
                (UIApplication.shared.delegate as? AppDelegate)?.startJitsiCall(roomName: /UserPreference.shared.clientDetail?.getJitsiUniqueID(.CLASS, id: /self?.item?.property?.model?.id), subject: self?.item?.property?.model?.name, isVideo: true)
            }
            
        }) { (_) in
            btn?.stop()
        }
    }
}
