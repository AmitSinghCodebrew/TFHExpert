//
//  ProfileDetailVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 03/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ProfileDetailVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblClientTitle: UILabel!
    @IBOutlet weak var lblClientCount: UILabel!
    @IBOutlet weak var lblExpTitle: UILabel!
    @IBOutlet weak var lblExp: UILabel!
    @IBOutlet weak var lblReviewTitle: UILabel!
    @IBOutlet weak var lblReviewCount: UILabel!
    @IBOutlet weak var btnManageAvailability: SKButton!
    @IBOutlet weak var btnManagePreferences: SKButton!
    @IBOutlet weak var btnUpdateCategory: UIButton!
    @IBOutlet weak var lblBioTitle: UILabel!
    @IBOutlet weak var lblBioValue: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblEmailValue: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblPhoneValue: UILabel!
    @IBOutlet weak var lblDOB: UILabel!
    @IBOutlet weak var lblDOBValue: UILabel!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewRating: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExpEtc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblRatingReviews: UILabel!
    @IBOutlet weak var btnManageDoc: SKButton!
    @IBOutlet weak var btnUpdate: SKButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        localizedTextSetup()
        updateProfileData(user: UserPreference.shared.data)
        getVendorDetailAPI()
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Edit Profile
            let destVC = Storyboard<SignUpInterMediateVC>.LoginSignUp.instantiateVC()
            destVC.comingFrom = .WhileManaging
            pushVC(destVC)
        case 2: //Manage Availability
            let destVC = Storyboard<ServicesVC>.LoginSignUp.instantiateVC()
            destVC.comingFrom = .WhileManaging
            pushVC(destVC)
        case 3: //Manage Preferences
            let destVC = Storyboard<SetPreferencesVC>.LoginSignUp.instantiateVC()
            destVC.comingFrom = .WhileManaging
            destVC.isUpdatingFiltersOnly = true
            pushVC(destVC)
        case 4: //Update Category
            let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
            destVC.comingFrom = .WhileManaging
            pushVC(destVC)
        case 5: //Manage Documents
            let destVC = Storyboard<UploadDocsVC>.LoginSignUp.instantiateVC()
            destVC.category = UserPreference.shared.data?.categoryData
            destVC.comingFrom = .WhileManaging
            pushVC(destVC)
        case 6: //Update Phone
            let destVC = Storyboard<LoginMobileVC>.LoginSignUp.instantiateVC()
            destVC.providerType = .updatePhone
            pushVC(destVC)
        default:
            break
        }
    }
    
}

//MARK:- VCFuncs
extension ProfileDetailVC {
     private func getVendorDetailAPI() {
        playLineAnimation()
        EP_Home.vendorDetail(vendorId: String(/UserPreference.shared.data?.id)).request(success: { [weak self] (responseData) in
            self?.updateProfileData(user: responseData as? User)
            self?.stopLineAnimation()
        }) { [weak self] (_) in
            self?.stopLineAnimation()
        }
    }
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.PROFILE.localized
        btnEdit.setTitle(VCLiteral.EDIT_CAPS.localized, for: .normal)
        lblClientTitle.text = VCLiteral.CLIENTS_TITLE.localized
        lblExpTitle.text = VCLiteral.EXPERIENCE.localized
        lblReviewTitle.text = VCLiteral.REVIEWS.localized
        btnManageAvailability.setTitle(VCLiteral.MANAGE_AVAIL.localized, for: .normal)
        btnManagePreferences.setTitle(VCLiteral.MANAGE_PREFE.localized, for: .normal)
        btnUpdateCategory.setTitle(VCLiteral.UPDATE_CAT.localized, for: .normal)
        lblBioTitle.text = VCLiteral.BIO_PLACEHOLDER.localized
        lblEmail.text = VCLiteral.EMAIL_PLACEHOLDER.localized
        lblPhone.text = VCLiteral.PHONE_NUMBER.localized
        lblDOB.text = VCLiteral.DOB_PLACEHOLDER.localized
        btnUpdate.setTitle(VCLiteral.UPDATE.localized, for: .normal)
        btnManagePreferences.isHidden = /UserPreference.shared.data?.filters?.count == 0
        btnManageDoc.setTitle(VCLiteral.MANAGE_DOCS.localized, for: .normal)
        btnManageDoc.isHidden = !(/UserPreference.shared.data?.categoryData?.is_additionals)
    }
    
    private func updateProfileData(user: User?) {
        imgView.setImageNuke(/user?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
        lblName.text = "\(/user?.profile?.title) \(/user?.name)"
        let experience = "\(Date().year() - /Date.init(fromString: /user?.profile?.working_since, format: DateFormat.custom("yyyy-MM-dd")).year())".experience
//        var desc = [/user?.qualification, /user?.speciality, experience]
//        desc.removeAll(where: {/$0 == ""})
        lblExpEtc.text = /user?.categoryData?.name
        #if HealthCarePrashantExpert || HealExpert
        lblAddress.text = /LocationManager.shared.address?.name
        viewLocation.isHidden = false
        #else
        viewLocation.isHidden = true
        #endif
        
        lblRatingReviews.text = "\(/user?.totalRating) · \(/user?.reviewCount) \(/user?.reviewCount == 1 ? VCLiteral.REVIEW.localized : VCLiteral.REVIEWS.localized)"
        lblClientCount.text = "\(/user?.patientCount)"
        lblExp.text = experience
        lblReviewCount.text = "\(/user?.reviewCount)"
        lblBioValue.text = /user?.profile?.bio
        lblEmailValue.text = /user?.email
        lblPhoneValue.text = "\(/user?.country_code) \(/user?.phone)"
        lblDOB.text = Date.init(fromString: /user?.profile?.dob, format: DateFormat.custom("yyyy-MM-dd")).toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
    }
}

