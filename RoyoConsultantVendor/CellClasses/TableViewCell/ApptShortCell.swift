//
//  ApptShortCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit
import MapKit

class ApptShortCell: UITableViewCell, ReusableCell {
    
    typealias T = AppDetailCellModel
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
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
    @IBOutlet weak var lblNationality: UILabel!
    @IBOutlet weak var lblPriceTitle: UILabel!
    @IBOutlet weak var lblCancelReason: UILabel!
    
    @IBOutlet weak var btnMulti: SKButton!
    @IBOutlet weak var btnCancel: SKLottieButton!
    @IBOutlet weak var btnPresc: SKButton!
    @IBOutlet weak var btnRequestpayment: SKButton!
    @IBOutlet weak var btnCallnow: SKButton!
    @IBOutlet weak var btnMedicalHistory: UIButton!
    
    @IBOutlet weak var btnTrackStatusOrMarkComplete: SKButton!
    @IBOutlet weak var stackBtns0: UIStackView! //Multi, CANCEL, Prescriptiom
    
    var didReloadCell: (() -> Void)?
    var updateApptDetail: (() -> Void)?
    var extraPaymentRequested: ((_ _extraPayment: ExtraPayment) -> Void)?
    
    var item: AppDetailCellModel? {
        didSet {
            let obj = item?.property?.model?.request
            lblName.text = /obj?.from_user?.name
            lblServiceType.text = VCLiteral.SERVICE_TYPE_TITLE.localized
            lblDate.text = VCLiteral.DATE.localized
            lblTime.text = VCLiteral.TIME.localized
            lblStatus.text = /obj?.status?.title.localized
            lblStatus.textColor = obj?.status?.linkedColor.color
            lblPriceTitle.text = VCLiteral.PRICE.localized
            btnMedicalHistory.setTitle(VCLiteral.MEDICAL_HISTORY.localized, for: .normal)
            lblCancelReason.text = /obj?.cancel_reason == "" ? "" : String(format: VCLiteral.CANCEL_REASON.localized, /obj?.cancel_reason)
            var age = VCLiteral.NA.localized
            if /obj?.from_user?.profile?.dob != "" {
                let tempAge = Date().year() - /Date.init(fromString: /obj?.from_user?.profile?.dob, format: DateFormat.custom("yyyy-MM-dd")).year()
                age = (tempAge == 0 ? VCLiteral.NA.localized : "\(tempAge)")
            }
            lblAge.text = String.init(format: VCLiteral.AGE.localized, age)
            lblAge.isHidden = /obj?.from_user?.profile?.dob == ""
            lblNationality.text = String.init(format: VCLiteral.NATIONALITY.localized, /obj?.from_user?.profile?.country)
            lblNationality.isHidden = /obj?.from_user?.profile?.country == ""
            imgView.setImageNuke(/obj?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
            let utcDate = Date(fromString: /obj?.bookingDateUTC, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
            lblDateValue.text = utcDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
            lblTimeValue.text = utcDate.toString(DateFormat.custom("hh:mm a"), timeZone: .local, isForAPI: false)
            lblServiceTypeValue.text = (/obj?.service_type).uppercased()
            lblPrice.text = /obj?.price?.getDoubleValue?.getFormattedPrice()
            btnCancel.isHidden = !(/obj?.canCancel)
            btnCancel.setTitle(VCLiteral.CANCEL.localized, for: .normal)
            btnPresc.setTitle(/obj?.is_prescription ? VCLiteral.VIEW_PRESCRIPTION.localized : VCLiteral.ADD_PRESC.localized, for: .normal)
            btnPresc.isHidden = !(obj?.status == .completed)

            viewAddress.isHidden = /obj?.extra_detail?.service_address == ""
            lblAddress.text = /obj?.extra_detail?.service_address
            btnRequestpayment.setTitle(VCLiteral.REQUEST_FOR_PAYMENT.localized, for: .normal)
            #if NurseLynxExpert
            btnCallnow.setTitle(VCLiteral.CALL_NOW.localized, for: .normal)
            #endif

            #if HomeDoctorKhalidExperts
            btnRequestpayment.isHidden = obj?.extra_payment != nil
            #else
            btnRequestpayment.isHidden = true
            #endif
            
            switch obj?.status ?? .unknown {
            case .canceled, .completed, .failed:
                btnCancel.isHidden = true
                btnMulti.isHidden = true
                btnTrackStatusOrMarkComplete.isHidden = true
                btnRequestpayment.isHidden = true
                btnCallnow.isHidden = true
            case .pending:
                btnMulti.isHidden = false
                btnMulti.setTitle(VCLiteral.ACCEPT_TITLE.localized, for: .normal)
                btnTrackStatusOrMarkComplete.isHidden = true
                btnRequestpayment.isHidden = true
                #if NurseLynxExpert
                btnCallnow.isHidden = false
                #else
                btnCallnow.isHidden = true
                #endif
            case .accept:
                btnMulti.isHidden = false
                btnMulti.setTitle(VCLiteral.START.localized, for: .normal)
                if obj?.getRelatedAction() == .CALL || obj?.getRelatedAction() == .VIDEO_CALL {
                    btnCallnow.isHidden = true
                    btnTrackStatusOrMarkComplete.isHidden = false
                    btnTrackStatusOrMarkComplete.setTitle(VCLiteral.MARK_COMPLETE.localized, for: .normal)
                } else {
                    btnTrackStatusOrMarkComplete.isHidden = true
                    #if NurseLynxExpert
                    btnCallnow.isHidden = false
                    #else
                    btnCallnow.isHidden = true
                    #endif
                }
                #if HomeDoctorKhalidExperts
                btnRequestpayment.isHidden = obj?.extra_payment != nil
                #else
                btnRequestpayment.isHidden = true
                #endif
            case .inProgress, .reached, .start:
                if obj?.getRelatedAction() == .HOME {
                    #if HealthCarePrashantExpert
                    btnTrackStatusOrMarkComplete.isHidden = true
                    #else
                    btnTrackStatusOrMarkComplete.setTitle(VCLiteral.TRACK_STATUS.localized, for: .normal)
                    btnTrackStatusOrMarkComplete.isHidden = false
                    #endif
                } else {
                    btnTrackStatusOrMarkComplete.isHidden = false
                    btnTrackStatusOrMarkComplete.setTitle(VCLiteral.MARK_COMPLETE.localized, for: .normal)
                }
                btnCancel.isHidden = true
                btnMulti.isHidden = true
                #if HomeDoctorKhalidExperts
                btnRequestpayment.isHidden = obj?.extra_payment != nil
                #else
                btnRequestpayment.isHidden = true
                #endif
                if obj?.getRelatedAction() == .CALL || obj?.getRelatedAction() == .VIDEO_CALL {
                    btnCallnow.isHidden = true
                } else {
                    #if NurseLynxExpert
                    btnCallnow.isHidden = false
                    #else
                    btnCallnow.isHidden = true
                    #endif
                }
            case .start_service:
                btnMulti.isHidden = true
                #if HealthCarePrashantExpert
                btnTrackStatusOrMarkComplete.isHidden = true
                #else
                btnTrackStatusOrMarkComplete.isHidden = false
                btnTrackStatusOrMarkComplete.setTitle(VCLiteral.MARK_COMPLETE.localized, for: .normal)
                #endif
                
                #if HomeDoctorKhalidExperts
                btnRequestpayment.isHidden = obj?.extra_payment != nil
                btnMedicalHistory.isHidden = false
                #else
                btnRequestpayment.isHidden = true
                btnMedicalHistory.isHidden = true
                #endif
                if obj?.getRelatedAction() == .CALL || obj?.getRelatedAction() == .VIDEO_CALL {
                    btnCallnow.isHidden = true
                } else {
                    #if NurseLynxExpert
                    btnCallnow.isHidden = false
                    #else
                    btnCallnow.isHidden = true
                    #endif
                }
            default:
                btnMulti.isHidden = true
                btnTrackStatusOrMarkComplete.isHidden = true
                btnRequestpayment.isHidden = true
                btnCallnow.isHidden = true
            }
            
            #if HomeDoctorKhalidExperts
            
            #else
            btnMedicalHistory.isHidden = true
            #endif
           
            
            stackBtns0.isHidden = btnMulti.isHidden && btnPresc.isHidden && btnCancel.isHidden
        }
    }
    
    @IBAction func btnViewAddressAction(_ sender: UIButton) {
        let clinic = item?.property?.model?.request?.service?.clinic_address
        if /item?.property?.model?.request?.service?.isClinicAddress() {
            let mapItem = MKMapItem.init(coordinate: CLLocationCoordinate2D.init(latitude: /clinic?.lat, longitude: /clinic?.long), name: /clinic?.locationName)
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        } else {
            let location = item?.property?.model?.request?.extra_detail
            let mapItem = MKMapItem.init(coordinate: CLLocationCoordinate2D.init(latitude: /Double(/location?.lat), longitude: /Double(/location?.long)), name: /location?.service_address)
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    @IBAction func btnMedicalHistoryAction(_ sender: UIButton) {
        let destVC = Storyboard<MedicalHistoryVC>.Other.instantiateVC()
        destVC.requestID = item?.property?.model?.request?.id
        destVC.isHistoryAdded = item?.property?.model?.request?.medical_history_added
        destVC.didAddedHistory = { [weak self] in
            self?.item?.property?.model?.request?.medical_history_added = true
        }
        UIApplication.topVC()?.pushVC(destVC)
    }
    
    @IBAction func btnAction(_ sender: SKLottieButton) {
        switch /sender.title(for: .normal) {
        case VCLiteral.CANCEL.localized:
            cancelRequestAlert()
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
                        self?.didReloadCell?()
                        self?.updateApptDetail?()
                    }
                    UIApplication.topVC()?.pushVC(destVC)
                case VCLiteral.DIGITAL_PRESCRIPTION.localized:
                    let destVC = Storyboard<AddDigitalPrescriptionVC>.Other.instantiateVC()
                    destVC.appt = self.item?.property?.model?.request
                    destVC.didAddedPrescription = { [weak self] in
                        self?.item?.property?.model?.request?.is_prescription = true
                        self?.didReloadCell?()
                        self?.updateApptDetail?()
                    }
                    UIApplication.topVC()?.pushVC(destVC)
                default: break
                }
            })
        case VCLiteral.VIEW_PRESCRIPTION.localized:
            let obj = item?.property?.model?.request
            UIApplication.topVC()?.actionSheet(for: [VCLiteral.EDIT.localized, VCLiteral.VIEW.localized], title: nil, message: nil, view: sender) { [weak self] (tappedString) in
                switch tappedString {
                case VCLiteral.EDIT.localized:
                    switch obj?.pre_scription?.type {
                    case .digital:
                        let destVC = Storyboard<AddDigitalPrescriptionVC>.Other.instantiateVC()
                        destVC.appt = obj
                        destVC.didAddedPrescription = { [weak self] in
                            self?.updateApptDetail?()
                        }
                        UIApplication.topVC()?.pushVC(destVC)
                    case .manual:
                        let destVC = Storyboard<AddManualPrescriptionVC>.Other.instantiateVC()
                        destVC.appt = obj
                        destVC.didAddedPrescription = { [weak self] in
                            self?.updateApptDetail?()
                        }
                        UIApplication.topVC()?.pushVC(destVC)
                    case .none:
                        break
                    }
                case VCLiteral.VIEW.localized:
                    let url = Configuration.getValue(for: .APP_BASE_PATH) + APIConstants.pdf + "?request_id=\(/obj?.id)&client_id=\(Configuration.getValue(for: .APP_PROJECT_ID))&download"
                    //for download --&download
                    let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
                    destVC.linkTitle = (url, VCLiteral.PRESC_DETAIL.localized)
                    UIApplication.topVC()?.pushVC(destVC)
                default: break
                }
            }
        case VCLiteral.TRACK_STATUS.localized:
            #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
            let destVC = Storyboard<TrackingVC>.Other.instantiateVC()
            destVC.request = item?.property?.model?.request
            destVC.modalPresentationStyle = .fullScreen
            destVC.didStatusChanged = { [weak self] (status) in
                self?.item?.property?.model?.request?.status = status
                self?.didReloadCell?()
            }
            UIApplication.topVC()?.presentVC(destVC)
            #endif
        case VCLiteral.MARK_COMPLETE.localized:
            markCompleteAlert()
        case VCLiteral.REQUEST_FOR_PAYMENT.localized:
            let destVC = Storyboard<AddExtraFeeVC>.PopUp.instantiateVC()
            destVC.modalPresentationStyle = .overFullScreen
            destVC.request = item?.property?.model?.request
            destVC.didRequestedExtraPayment = { [weak self] (extraPayment) in
                self?.extraPaymentRequested?(extraPayment)
            }
            UIApplication.topVC()?.presentVC(destVC)
        #if NurseLynxExpert
        case VCLiteral.CALL_NOW.localized:
            btnCallnow.playAnimation()
            EP_Home.startCall(requestId: item?.property?.model?.request?.id).request { [weak self] (responseData) in
                self?.btnCallnow.stop()
                let callVC = Storyboard<CallVC>.Other.instantiateVC()
                callVC.serviceRequest = self?.item?.property?.model?.request
                callVC.callType = .Outgoing
                callVC.callId = (responseData as? CallerData)?.call_id
                callVC.isVideo = true
                callVC.modalPresentationStyle = .overFullScreen
                UIApplication.topVC()?.presentVC(callVC)
            } error: { [weak self] (error) in
                self?.btnCallnow.stop()
            }
        #endif
        default:
            break
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
        btnMulti.setAnimationType(.BtnWhiteLoader)
        btnMulti.playAnimation()
        let service = item?.property?.model?.request

        EP_Home.callStatus(requestID: String(/service?.id), status: .start, callId: nil).request { [weak self] (response) in
            self?.btnMulti.stop()
            self?.item?.property?.model?.request?.status = .start
            self?.didReloadCell?()
            //Open Tracking screen
            #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
            let destVC = Storyboard<TrackingVC>.Other.instantiateVC()
            destVC.request = service
            destVC.modalPresentationStyle = .fullScreen
            destVC.didStatusChanged = { [weak self] (status) in
                self?.item?.property?.model?.request?.status = status
                self?.didReloadCell?()
            }
            UIApplication.topVC()?.presentVC(destVC)
            #endif
        } error: { [weak self] (_) in
            self?.btnMulti.stop()
        }
    }
    
    private func startRequestFurtherProceed() {
        btnMulti.setAnimationType(.BtnWhiteLoader)
        btnMulti.playAnimation()
        let service = item?.property?.model?.request
        
        EP_Home.startRequest(requestId: String(/service?.id)).request(success: { [weak self] (response) in
            
            self?.btnMulti.stop()

            switch service?.getRelatedAction() ?? .DEFAULT {
            case .CHAT:
                self?.item?.property?.model?.request?.status = .inProgress
                self?.didReloadCell?()
                let destVC = Storyboard<ChatVC>.Other.instantiateVC()
                destVC.thread = ChatThread.init(/service?.id, service?.from_user, .inProgress, service?.to_user)
                UIApplication.topVC()?.pushVC(destVC)
            case .CALL:
                let callVC = Storyboard<CallVC>.Other.instantiateVC()
                callVC.serviceRequest = service
                callVC.callType = .Outgoing
                callVC.isVideo = false
                
                // if call issue is there uncomment below comment 
//                callVC.callId = "\(Configuration.getValue(for: .APP_JITSI_SERVER))\((response as? CallerData)?.call_id ?? "")"
//                print("\(Configuration.getValue(for: .APP_JITSI_SERVER))\((response as? CallerData)?.call_id ?? "")")
                
                callVC.callId = (response as? CallerData)?.call_id
                callVC.modalPresentationStyle = .overFullScreen
                UIApplication.topVC()?.presentVC(callVC)
            case .VIDEO_CALL:
                let callVC = Storyboard<CallVC>.Other.instantiateVC()
                callVC.serviceRequest = service
                callVC.callType = .Outgoing
                callVC.isVideo = true
                
                
//                callVC.callId = "\(Configuration.getValue(for: .APP_JITSI_SERVER))\((response as? CallerData)?.call_id ?? "")"
//                print("\(Configuration.getValue(for: .APP_JITSI_SERVER))\((response as? CallerData)?.call_id ?? "")")
                
                callVC.callId = (response as? CallerData)?.call_id
                callVC.modalPresentationStyle = .overFullScreen
                UIApplication.topVC()?.presentVC(callVC)
            case .HOME, .DEFAULT:
                self?.item?.property?.model?.request?.status = .inProgress
                self?.didReloadCell?()
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
            self?.didReloadCell?()
        }) { [weak self] (error) in
            self?.btnCancel.stop()
        }
    }
    
    private func acceptRequestAPI() {
        btnMulti.setAnimationType(.BtnWhiteLoader)
        btnMulti.playAnimation()
        EP_Home.acceptRequest(requestId: String(/item?.property?.model?.request?.id)).request(success: { [weak self] (responseData) in
            self?.btnMulti.stop()
            self?.item?.property?.model?.request?.status = .accept
            self?.didReloadCell?()
        }) { [weak self] (error) in
            self?.btnMulti.stop()
        }
    }
    
    private func markCompleteAlert() {
        UIApplication.topVC()?.alertBoxOKCancel(title: VCLiteral.MARK_COMPLETE.localized, message: VCLiteral.MARK_COMPLETE_ALERT.localized, tapped: { [weak self] in
            self?.changeStatusToCompleteAPI()
        }, cancelTapped: nil)
    }
    
    private func changeStatusToCompleteAPI() {
        btnTrackStatusOrMarkComplete.playAnimation()
        EP_Home.callStatus(requestID: String(/item?.property?.model?.request?.id), status: .completed, callId: nil).request { [weak self] (responseData) in
            self?.btnTrackStatusOrMarkComplete.stop()
            self?.item?.property?.model?.request?.status = .completed
            self?.didReloadCell?()
        } error: { [weak self] (error) in
            self?.btnTrackStatusOrMarkComplete.stop()
            self?.didReloadCell?()
        }
    }
}
