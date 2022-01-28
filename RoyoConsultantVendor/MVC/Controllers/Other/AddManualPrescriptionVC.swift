//
//  AddManualPrescriptionVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 07/09/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class AddManualPrescriptionVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPatient: UILabel!
    @IBOutlet weak var imgViewPatient: UIImageView!
    @IBOutlet weak var lblPatientName: UILabel!
    @IBOutlet weak var lblPatientInfo: UILabel!
    @IBOutlet weak var lblAppt: UILabel!
    @IBOutlet weak var lblApptDate: UILabel!
    @IBOutlet weak var lblRecordDetails: UILabel!
    @IBOutlet weak var tfRecord: JVFloatLabeledTextField!
    @IBOutlet weak var lblAddImages: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var btnDone: SKButton!
    
    public var appt: Requests?
    private var images = [AddMedia.init(nil, .image)]
    private var dataSource: CollectionDataSource?
    public var sizeProvider: CollectionSizeProvider!
    public var didAddedPrescription: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        apptDataSetup()
        collectionViewInit()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Back
            popVC()
        case 1: // Done
            validateData()
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension AddManualPrescriptionVC {
    
    private func localizedTextSetup() {
        lblTitle.text = appt?.pre_scription?.type == .manual ? VCLiteral.EDIT_MANUAL_PRESC.localized : VCLiteral.ADD_MANUAL_PRESC.localized
        lblPatient.text = VCLiteral.PATIENT.localized
        lblAppt.text = VCLiteral.APPOINTMENT.localized
        lblRecordDetails.text = VCLiteral.RECORD_DETAILS.localized
        tfRecord.placeholder = VCLiteral.RECORD_TITLE.localized
        lblAddImages.text = VCLiteral.ADD_IMAGES.localized
        btnDone.setTitle(VCLiteral.DONE.localized, for: .normal)
        tfRecord.text = /appt?.pre_scription?.title
        appt?.pre_scription?.images?.forEach({ (image) in
            self.images.append(AddMedia.init(image, .image))
        })
        dataSource?.updateData(images)
    }
    
    private func apptDataSetup() {
        lblPatientName.text = /appt?.from_user?.name
        let utcDate = Date(fromString: /appt?.bookingDateUTC, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
        lblApptDate.text = utcDate.toString(DateFormat.custom("dd MMM yyyy · hh:mm a"), timeZone: .local, isForAPI: false)
        imgViewPatient.setImageNuke(/appt?.from_user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        if /appt?.from_user?.phone != "" {
            lblPatientInfo.text = /appt?.from_user?.country_code + "-" + /appt?.from_user?.phone
        } else {
            lblPatientInfo.text = /appt?.from_user?.email
        }
    }
    
    private func collectionViewInit() {
        let cellWidth = (UIScreen.main.bounds.width - (16 * 5)) / 4
        
        sizeProvider = CollectionSizeProvider.init(cellSize: CGSize.init(width: cellWidth, height: cellWidth), interItemSpacing: 16, lineSpacing: 16, edgeInsets: UIEdgeInsets.init(top: 0, left: 16, bottom: 16, right: 16))
        
        dataSource = CollectionDataSource.init(images, AddImageCell.identfier, collectionView, sizeProvider.cellSize, sizeProvider.edgeInsets, sizeProvider.lineSpacing, sizeProvider.interItemSpacing, .vertical)
        
        dataSource?.configureCell = { [weak self] (cell, item, indexPath) in
            (cell as? AddImageCell)?.item = item
            (cell as? AddImageCell)?.didTapDelete = {
                self?.images.remove(at: indexPath.item)
                self?.dataSource?.items = self?.images
                self?.collectionView.deleteItems(at: [indexPath])
            }
        }
        
        dataSource?.didSelectItem = { [weak self] (indexPath, item) in
            if indexPath.item == 0 {
                self?.mediaPicker.presentPicker({ (image) in
                    self?.addImage(image: image)
                }, nil, nil)
            }
        }
        
        collectionHeight.constant = sizeProvider.getHeightOfTableViewCell(for: 4, gridCount: 4)
    }
    
    private func validateData() {
        if /tfRecord.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.RECORD_TITLE_ALERT.localized)
            btnDone.vibrate()
            return
        } else if /images.count == 1 {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.PRESCRIPTION_IMAGE_ALERT.localized)
            btnDone.vibrate()
            return
        } else if /images.contains(where: {/$0.isUploading}) {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.DOC_UPLOADING_ALERT.localized)
            btnDone.vibrate()
            return
        } else {
            uploadPrescriptionAPI()
        }
    }
    
    
    private func uploadPrescriptionAPI() {
        btnDone.playAnimation()
        
        let imagesFiltered = images.filter({$0.url != nil})
        let urls = imagesFiltered.map({/($0.url as? String)})
        
        EP_Home.addPrescriptions(request_id: appt?.id, type: .manual, pre_scription_notes: nil, title: tfRecord.text, image: urls, pre_scriptions: nil).request(success: { [weak self] (responseData) in
            self?.btnDone.stop()
            self?.didAddedPrescription?()
            self?.popVC()
        }) { [weak self] (error) in
            self?.btnDone.stop()
        }
    }
    
    private func addImage(image: UIImage) {
        let imageObj = AddMedia.init(image, .image)
        imageObj.isUploading = true
        images.append(imageObj)
        collectionHeight.constant = sizeProvider.getHeightOfTableViewCell(for: images.count < 4 ? 4 : images.count + 1, gridCount: 4)
        dataSource?.items = images
        collectionView.insertItems(at: [IndexPath(row: images.count - 1, section: 0)])
        uploadImageAPI(image: image, indexPath: IndexPath(row: images.count - 1, section: 0))
    }
    
    private func uploadImageAPI(image: UIImage, indexPath: IndexPath) {
        EP_Home.uploadMedia(image: image, type: .image, doc: nil, localAudioPath: nil).request(success: { [weak self] (responseData) in
            let tempData = responseData as? ImageUploadData
            self?.images[indexPath.item].isUploading = false
            self?.images[indexPath.item].url = tempData?.image_name
            self?.dataSource?.items = self?.images
            self?.collectionView.reloadItems(at: [indexPath])
        }) { [weak self] (error) in
            self?.images[indexPath.item].isUploading = false
            self?.dataSource?.items = self?.images
            self?.collectionView.reloadItems(at: [indexPath])
            self?.alertBox(title: VCLiteral.UPLOAD_ERROR.localized, message: nil, btn1: VCLiteral.CANCEL.localized, btn2: VCLiteral.RETRY_SMALL.localized, tapped1: {
                self?.images.remove(at: indexPath.item)
                self?.dataSource?.items = self?.images
                self?.collectionView.deleteItems(at: [indexPath])
                self?.collectionHeight.constant = /self?.sizeProvider.getHeightOfTableViewCell(for: /self?.images.count < 4 ? 4 : /self?.images.count + 1, gridCount: 4)
            }, tapped2: {
                self?.images[indexPath.item].isUploading = true
                self?.dataSource?.items = self?.images
                self?.collectionView.reloadItems(at: [indexPath])
                self?.uploadImageAPI(image: image, indexPath: indexPath)
            })
        }
    }
}
