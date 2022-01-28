//
//  PendingRequestsVC.swift
//  RoyoConsultantVendor
//
//  Created by Chitresh Goyal on 27/08/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class PendingRequestsVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnViewMap: UIButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewAddress: UIView!
    @IBOutlet weak var lblServiceType: UILabel!
    @IBOutlet weak var lblServiceTypeValue: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTimeValue: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblPriceTitle: UILabel!

    @IBOutlet weak var btnMulti: SKButton!
    @IBOutlet weak var btnCancel: SKLottieButton!
    @IBOutlet weak var progressView: UIProgressView!

    public var didReceiveRequestId: ((_ requestId: Int?) -> Void)?
    var item: Pending?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
    }
    
    @IBAction func actionButtons(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            break
        case 1: //Accept
            
            btnMulti.playAnimation()
            Ep_Others.acceptRequest(requestId: "\(/item?.id)").request {[weak self] responseData in
                
                self?.btnMulti.stop()
                let response = responseData as? RequestDetailData
                self?.dismiss(animated: true) {
                    self?.didReceiveRequestId?(response?.request_detail?.id)
                }
            } error: { error in
                self.btnMulti.stop()
            }
        case 2: //Cancel
            
            btnCancel.playAnimation()
            Ep_Others.cancelRequest(requestId: "\(/item?.id)").request {[weak self] responseData in
                self?.btnCancel.stop()
                self?.dismissVC()
                
            } error: { error in
                self.btnCancel.stop()
            }
        default:
            break
        }
    }
}

extension PendingRequestsVC {
    
    private func setupData() {
    
        let obj = item
        lblName.text = /obj?.from_user?.name
        lblServiceType.text = VCLiteral.SERVICE_TYPE_TITLE.localized
        lblDate.text = VCLiteral.DATE.localized
        lblTime.text = VCLiteral.TIME.localized

        lblPriceTitle.text = VCLiteral.PRICE.localized
       
        var age = VCLiteral.NA.localized
        if /obj?.from_user?.profile?.dob != "" {
            let tempAge = Date().year() - /Date.init(fromString: /obj?.from_user?.profile?.dob, format: DateFormat.custom("yyyy-MM-dd")).year()
            age = (tempAge == 0 ? VCLiteral.NA.localized : "\(tempAge)")
        }
        lblAge.text = String.init(format: VCLiteral.AGE.localized, age)
        lblAge.isHidden = /obj?.from_user?.profile?.dob == ""
        
        imgView.setImageNuke(/obj?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
      
        let utcDate = Date(fromString: /obj?.bookingDateUTC, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
        let utcEndDate = Date(fromString: /obj?.booking_end_date, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)

        lblDateValue.text = utcDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false) + " - " + utcEndDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
        lblTimeValue.text = utcDate.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false) + " - " + utcEndDate.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
        
        lblServiceTypeValue.text = (/obj?.service_type).uppercased()
        lblPrice.text = /obj?.price?.getDoubleValue?.getFormattedPrice()
        btnCancel.setTitle(VCLiteral.CANCEL.localized, for: .normal)
        btnMulti.setTitle(VCLiteral.ACCEPT_TITLE.localized, for: .normal)

        viewAddress.isHidden = /obj?.extra_details?.service_address == ""
        lblAddress.text = /obj?.extra_details?.service_address
     
        startTimer()
    }
    
    func startTimer() {
        
        let totalTime = Double(/item?.remain_second)
        var waitingTime = 0.0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if waitingTime < totalTime {
                waitingTime += 1
                
                let progress = Float(waitingTime/totalTime)
                self.progressView.setProgress(Float(progress), animated: true)
            } else {
                Timer.invalidate()
                self.dismissVC()
            }
        }
    }
}
