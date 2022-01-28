//
//  CallVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 22/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class CallVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    
    public var serviceRequest: Requests?
    public var callType: CallType = .Outgoing
    public var isVideo: Bool? = false
    
    public var callId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        localizedTextSetup()
        switch callType {
        case .Outgoing:
            lblStatus.text = VCLiteral.CALLING.localized
            btnAccept.isHidden = true
        case .Incoming:
            lblStatus.text = VCLiteral.INCOMING.localized
        }
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Decline
            updateStatusAPI(status: .CALL_CANCELED)
            dismissVC()
        case 1: //Accept
            updateStatusAPI(status: .CALL_ACCEPTED)
            (UIApplication.shared.delegate as? AppDelegate)?.startJitsiCall(roomName: "\(Configuration.getValue(for: .APP_JITSI_SERVER))\(callId ?? "")", requestId: String(/serviceRequest?.id), subject: VCLiteral.CALL.localized, isVideo: isVideo, callID: callId)
        default:
            break
        }
    }
}
//MARK:- VCFuncs
extension CallVC {
    private func localizedTextSetup() {
        lblTitle.text = Configuration.appName()
        lblName.text = /serviceRequest?.from_user?.name
        imgView.setImageNuke(/serviceRequest?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        lblDesc.text = "NA"
        let utcDate = Date(fromString: /serviceRequest?.bookingDateUTC, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
        lblTime.text = utcDate.toString(DateFormat.custom("dd MMM yyyy · hh:mm a"), timeZone: .local, isForAPI: false)
    }
    
    private func updateStatusAPI(status: CallStatus) {
        EP_Home.callStatus(requestID: String(/serviceRequest?.id), status: status, callId: callId).request(success: { (_) in
            
        }) { (_) in
            
        }
    }
    
    public func callStatusUpdate(status: CallStatus) {
        switch status {
        case .CALL_RINGING:
            lblStatus.text = VCLiteral.RINGING.localized
        case .CALL_CANCELED:
            lblStatus.text = VCLiteral.CALL_CANCELLED.localized
            dismissVC()
        case .CALL_ACCEPTED:
            dismiss(animated: true) { [weak self] in
                (UIApplication.shared.delegate as? AppDelegate)?.startJitsiCall(roomName: "\(Configuration.getValue(for: .APP_JITSI_SERVER))\(/self?.callId )", requestId: String(/self?.serviceRequest?.id), subject: VCLiteral.CALL.localized, isVideo: self?.isVideo, callID: self?.callId)
            }
        default:
            break
        }
    }
}
