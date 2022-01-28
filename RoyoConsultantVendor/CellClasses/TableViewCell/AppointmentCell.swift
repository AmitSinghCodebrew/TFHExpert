//
//  AppointmentCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 01/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit


import UIKit

class AppointmentCell: UITableViewCell, ReusableCell {
    
    typealias T = HomeCellProvider
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblRequestType: UILabel!
    @IBOutlet weak var imgVIew: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnCancel: SKLottieButton!
    @IBOutlet weak var btnMulti: SKLottieButton!
    @IBOutlet weak var btnAddPres: SKLottieButton!
    @IBOutlet weak var btnTrackStatus: SKButton!
    @IBOutlet weak var lblViewDetail: UILabel!
    
    var reloadTable: (() -> Void)?
    
    var item: HomeCellProvider? {
        didSet {
            let obj = item?.property?.model?.request
            lblName.text = /obj?.from_user?.name
            lblRequestType.text = (/obj?.service_type).uppercased()
            lblStatus.text = /obj?.status?.title.localized
            lblStatus.textColor = obj?.status?.linkedColor.color
            imgVIew.setImageNuke(/obj?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            let utcDate = Date(fromString: /obj?.bookingDateUTC, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
            lblDate.text = utcDate.toString(DateFormat.custom("\(UserPreference.shared.dateFormat) · hh:mm a"), timeZone: .local, isForAPI: false)
            lblPrice.text = /obj?.price?.getDoubleValue?.getFormattedPrice()
            btnCancel.isHidden = !(/obj?.canCancel)
            btnCancel.setTitle(VCLiteral.CANCEL.localized, for: .normal)
            btnAddPres.setTitle(/obj?.is_prescription ? VCLiteral.VIEW_PRESCRIPTION.localized : VCLiteral.ADD_PRESC.localized, for: .normal)
            btnAddPres.isHidden = !(obj?.status == .completed)
            btnTrackStatus.setTitle(VCLiteral.TRACK_STATUS.localized, for: .normal)
            switch obj?.status ?? .unknown {
            case .canceled, .completed, .failed:
                btnCancel.isHidden = true
                btnMulti.isHidden = true
                btnTrackStatus.isHidden = true
            case .pending:
                btnMulti.isHidden = false
                btnMulti.setTitle(VCLiteral.ACCEPT_TITLE.localized, for: .normal)
                btnTrackStatus.isHidden = true
            case .accept:
                btnMulti.isHidden = false
                btnMulti.setTitle(VCLiteral.START.localized, for: .normal)
                btnTrackStatus.isHidden = true
            case .inProgress, .reached, .start:
                if obj?.getRelatedAction() == .HOME {
                    btnTrackStatus.isHidden = false
                } else {
                    btnTrackStatus.isHidden = true
                }
                btnCancel.isHidden = true
                btnMulti.isHidden = true
            default:
                btnMulti.isHidden = true
                btnTrackStatus.isHidden = true
            }
            
            #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
            
            #else
            btnTrackStatus.isHidden = true
            #endif
            
            lblViewDetail.text = VCLiteral.VIEW_DETAIL.localized
            
            
            //All Buttons hide
            btnAddPres.isHidden = true

            #if HomeDoctorKhalidExperts
            btnAddPres.isHidden = true
            #else
            btnCancel.isHidden = true
            btnMulti.isHidden = true
            btnTrackStatus.isHidden = true
            btnAddPres.isHidden = true
            #endif
            
            btnCancel.isHidden = true
            btnMulti.isHidden = true
            btnTrackStatus.isHidden = true
            btnAddPres.isHidden = true
        }
    }
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 1: //Cancel
            cancelRequestAlert()
        default: //Other Actions
            switch /sender.title(for: .normal) {
            case VCLiteral.ACCEPT_TITLE.localized:
                acceptRequestAlert()
            case VCLiteral.START.localized:
                startRequestAlert()
            case VCLiteral.ADD_PRESC.localized:
                UIApplication.topVC()?.actionSheet(for: [VCLiteral.DIGITAL_PRESCRIPTION.localized, VCLiteral.MANUAL_PRESCRIPTION.localized], title: nil, message: nil, view: sender, tapped: { (titleTapped) in
                    switch titleTapped {
                    case VCLiteral.MANUAL_PRESCRIPTION.localized:
                        let destVC = Storyboard<AddManualPrescriptionVC>.Other.instantiateVC()
                        destVC.appt = self.item?.property?.model?.request
                        destVC.didAddedPrescription = { [weak self] in
                            self?.item?.property?.model?.request?.is_prescription = true
                            self?.reloadTable?()
                        }
                        UIApplication.topVC()?.pushVC(destVC)
                    case VCLiteral.DIGITAL_PRESCRIPTION.localized:
                        let destVC = Storyboard<AddDigitalPrescriptionVC>.Other.instantiateVC()
                        destVC.appt = self.item?.property?.model?.request
                        destVC.didAddedPrescription = { [weak self] in
                            self?.item?.property?.model?.request?.is_prescription = true
                            self?.reloadTable?()
                        }
                        UIApplication.topVC()?.pushVC(destVC)
                    default: break
                    }
                })
            case VCLiteral.VIEW_PRESCRIPTION.localized:
                
                let url = Configuration.getValue(for: .APP_BASE_PATH) + APIConstants.pdf + "?request_id=\(/item?.property?.model?.request?.id)&client_id=\(Configuration.getValue(for: .APP_PROJECT_ID))"
                //for download --&download
                let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
                destVC.linkTitle = (url, VCLiteral.PRESC_DETAIL.localized)
                UIApplication.topVC()?.pushVC(destVC)
            case VCLiteral.TRACK_STATUS.localized:
                #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
                let destVC = Storyboard<TrackingVC>.Other.instantiateVC()
                destVC.request = item?.property?.model?.request
                destVC.modalPresentationStyle = .fullScreen
                destVC.didStatusChanged = { [weak self] (status) in
                    self?.item?.property?.model?.request?.status = status
                    self?.reloadTable?()
                }
                UIApplication.topVC()?.presentVC(destVC)
                #endif
            default:
                break
            }
        }
    }
    
    private func cancelRequestAlert() {
        let alertVC = UIAlertController.init(title: VCLiteral.CANCEL_REQUEST.localized, message: VCLiteral.CANCEL_REQUEST_ALERT_MESSAGE.localized, preferredStyle: .alert)
        alertVC.addTextField { (tf) in
            tf.placeholder = String(format: VCLiteral.CANCEL_REASON.localized, "").replacingOccurrences(of: ":", with: "")
        }
        alertVC.addAction(UIAlertAction.init(title: VCLiteral.CANCEL.localized, style: .cancel, handler: { (_) in
            
        }))
        alertVC.addAction(UIAlertAction.init(title: VCLiteral.OK.localized, style: .default, handler: { [weak self] (_) in
            if /alertVC.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.CANCEL_REASON_ALERT.localized)
            } else {
                self?.cancelRequestAPI(reason: /alertVC.textFields?.first?.text)
            }
        }))
        UIApplication.topVC()?.presentVC(alertVC)
    }
    
    private func acceptRequestAlert() {
        UIApplication.topVC()?.alertBox(title: VCLiteral.ACCEPT_REQUEST.localized, message: VCLiteral.ACCEP_REQUEST_ALERT_DESC.localized, btn1: VCLiteral.CANCEL.localized, btn2: VCLiteral.ACCEPT_TITLE.localized, tapped1: nil, tapped2: { [weak self] in
            self?.acceptRequestAPI()
        })
    }
    
    private func startRequestAlert() {
        UIApplication.topVC()?.alertBox(title: VCLiteral.START_REQUEST.localized, message: VCLiteral.START_REQUEST_ALERT_DESC.localized, btn1: VCLiteral.CANCEL.localized, btn2: VCLiteral.START.localized, tapped1: nil, tapped2: { [weak self] in
            
            let service = self?.item?.property?.model?.request
            
            switch service?.getRelatedAction() ?? .DEFAULT {
            case .HOME, .DEFAULT:
                self?.startRequestWithLocationTrackAPI()
            default:
                self?.startRequestFurtherProceed()
            }
        })
    }
    
    private func startRequestWithLocationTrackAPI() {
        btnMulti.setAnimationType(.BtnAppTintLoader)
        btnMulti.playAnimation()
        let service = item?.property?.model?.request

        EP_Home.callStatus(requestID: String(/service?.id), status: .start, callId: nil).request { [weak self] (response) in
            self?.btnMulti.stop()
            self?.item?.property?.model?.request?.status = .start
            self?.reloadTable?()
            //Open Tracking screen
            #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
            let destVC = Storyboard<TrackingVC>.Other.instantiateVC()
            destVC.request = service
            destVC.modalPresentationStyle = .fullScreen
            destVC.didStatusChanged = { [weak self] (status) in
                self?.item?.property?.model?.request?.status = status
                self?.reloadTable?()
            }
            UIApplication.topVC()?.presentVC(destVC)
            #endif
        } error: { [weak self] (_) in
            self?.btnMulti.stop()
        }
    }
    
    private func startRequestFurtherProceed() {
        btnMulti.setAnimationType(.BtnAppTintLoader)
        btnMulti.playAnimation()
        let service = item?.property?.model?.request
        
        EP_Home.startRequest(requestId: String(/service?.id)).request(success: { [weak self] (response) in
            
            self?.btnMulti.stop()

            switch service?.getRelatedAction() ?? .DEFAULT {
            case .CHAT:
                self?.item?.property?.model?.request?.status = .inProgress
                self?.reloadTable?()
                let destVC = Storyboard<ChatVC>.Other.instantiateVC()
                destVC.thread = ChatThread.init(/service?.id, service?.from_user, .inProgress, service?.to_user)
                UIApplication.topVC()?.pushVC(destVC)
            case .CALL:
                let callVC = Storyboard<CallVC>.Other.instantiateVC()
                callVC.serviceRequest = service
                callVC.callType = .Outgoing
                callVC.isVideo = false
                callVC.callId = (response as? CallerData)?.call_id
                callVC.modalPresentationStyle = .overFullScreen
                UIApplication.topVC()?.presentVC(callVC)
            case .VIDEO_CALL:
                let callVC = Storyboard<CallVC>.Other.instantiateVC()
                callVC.serviceRequest = service
                callVC.callType = .Outgoing
                callVC.isVideo = true
                callVC.callId = (response as? CallerData)?.call_id
                callVC.modalPresentationStyle = .overFullScreen
                UIApplication.topVC()?.presentVC(callVC)
            case .HOME, .DEFAULT:
                self?.item?.property?.model?.request?.status = .inProgress
                self?.reloadTable?()
            }
            
        }) { [weak self] (_) in
            self?.btnMulti.stop()
        }
    }
    
    private func cancelRequestAPI(reason: String) {
        btnCancel.setAnimationType(.BtnAppTintLoader)
        btnCancel.playAnimation()
        EP_Home.cancelRequest(requestId: String(/item?.property?.model?.request?.id), reason: reason).request(success: { [weak self] (responseData) in
            self?.btnCancel.stop()
            self?.item?.property?.model?.request?.canCancel = false
            self?.item?.property?.model?.request?.status = .canceled
            self?.item?.property?.model?.request?.cancel_reason = reason
            self?.reloadTable?()
        }) { [weak self] (error) in
            self?.btnCancel.stop()
        }
    }
    
    private func acceptRequestAPI() {
        btnMulti.setAnimationType(.BtnAppTintLoader)
        btnMulti.playAnimation()
        EP_Home.acceptRequest(requestId: String(/item?.property?.model?.request?.id)).request(success: { [weak self] (responseData) in
            self?.btnMulti.stop()
            self?.item?.property?.model?.request?.status = .accept
            self?.reloadTable?()
        }) { [weak self] (error) in
            self?.btnMulti.stop()
        }
    }
}
