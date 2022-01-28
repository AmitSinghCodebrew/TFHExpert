//
//  MedicalHIstoryDescCell.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 14/05/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import UIKit

class MedicalHIstoryDescCell: UITableViewCell, ReusableCell {
    
    typealias T = MedicalHistoryProvider
    
    @IBOutlet weak var lblApptDate: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblExtraDetails: UILabel!
    @IBOutlet weak var btnPrescription: UIButton!{
        didSet{
            btnPrescription.setTitle(VCLiteral.Prescription.localized, for: .normal)
        }
    }

    
    var item: MedicalHistoryProvider? {
        didSet {
            let utcDate = Date(fromString: /item?.property?.model?.request?.booking_date, format: DateFormat.custom("yyyy-MM-dd HH:mm:ss"), timeZone: .utc)
            lblApptDate.text = "\(VCLiteral.Appointment_Date.localized) \(utcDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false))"
            lblDesc.text = /item?.property?.model?.comment
            lblExtraDetails.text = ""
            
            if let extraDetails = item?.property?.model?.request?.extra_payment {
                let amount = /extraDetails.balance?.getFormattedPrice()

                lblExtraDetails.text = "\(VCLiteral.Services.localized) (\(/extraDetails.status?.title.localized)) \n\(VCLiteral.Amount.localized) \(amount)\n\(/extraDetails.description)"
            }
            btnPrescription.isHidden = !(/item?.property?.model?.request?.is_prescription)
        }
    }
    
    @IBAction func btnPrescription(_ sender: UIButton) {
        
        let url = Configuration.getValue(for: .APP_BASE_PATH) + APIConstants.pdf + "?request_id=\(/item?.property?.model?.request?.id)&client_id=\(Configuration.getValue(for: .APP_PROJECT_ID))&download"
        
        if let URL = URL(string: url) {
            do {
                let contents = try String(contentsOf: URL)
                print(contents)
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
        //for download --&download
        let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
        destVC.linkTitle = (url, VCLiteral.PRESC_DETAIL.localized)
        UIApplication.topVC()?.pushVC(destVC)
    }
}
