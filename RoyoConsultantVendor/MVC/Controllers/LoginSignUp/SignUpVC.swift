//
//  SignUpVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 11/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import SZTextView
import JVFloatLabeledTextField

class SignUpVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblNamePrefix: UILabel!
    
    @IBOutlet weak var tfFirstName: JVFloatLabeledTextField!
    @IBOutlet weak var tfEmail: JVFloatLabeledTextField!
    @IBOutlet weak var tfPsw: JVFloatLabeledTextField!
    @IBOutlet weak var tfDOB: JVFloatLabeledTextField!
    @IBOutlet weak var tfWorkingSince: JVFloatLabeledTextField!
    @IBOutlet weak var tvBio: SZTextView!
    @IBOutlet weak var btnNext: SKButton!
    @IBOutlet weak var tfQualification: JVFloatLabeledTextField!
    @IBOutlet weak var tfGender: JVFloatLabeledTextField!
    @IBOutlet weak var tfChooseLng: JVFloatLabeledTextField!
    @IBOutlet weak var tableLngOptions: UITableView!
    @IBOutlet weak var tblLngHeight: NSLayoutConstraint!
    @IBOutlet weak var viewQualification: UIView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var viewInvite: UIView!
    @IBOutlet weak var tfInvite: JVFloatLabeledTextField!
    @IBOutlet weak var viewTerms: UIStackView!
    @IBOutlet weak var btnTick: UIButton!
    @IBOutlet weak var lblByContinue: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    @IBOutlet weak var lblAnnd: UILabel!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var viewTick: UIView!
    
    private var dob: Date?
    private var workingSince: Date?
    private var image_URL: String?
    private var gender: GenderOption?
    private var dataSourceLng: TableDataSource<DefaultHeaderFooterModel<FilterOption>, DefaultCellModel<FilterOption>, FilterOption>?
    private var isTermsAgreed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        
        tfDOB.inputView = SKDatePicker.init(frame: .zero, mode: .date, maxDate: Date().dateBySubtractingMonths(5 * 12), minDate: nil, configureDate: { [weak self] (selectedDate) in
            self?.dob = selectedDate
            self?.tfDOB.text = selectedDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
        })
        
        tfWorkingSince.inputView = SKDatePicker.init(frame: .zero, mode: .date, maxDate: Date(), minDate: nil, configureDate: { [weak self] (selectedDate) in
            self?.workingSince = selectedDate
            self?.tfWorkingSince.text = selectedDate.toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
        })
        
        lblNamePrefix.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(namePrefixTapped)))
        imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(selectImage)))
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Next
            switch Validation.shared.validate(values: (.NAME, /tfFirstName.text), (.EMAIL, /tfEmail.text), (.PASSWORD, /tfPsw.text), (.WORKING_SINCE, /tfWorkingSince.text)) {
            case .success:
                validateDynamicFields()
//                registerAPI()
            case .failure(let alertType, let message):
                Toast.shared.showAlert(type: alertType, message: message.localized)
            }
        case 2: //Terms
            let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(APIConstants.termsConditions)", VCLiteral.TERMS_AND_CONDITIONS.localized)
            pushVC(destVC)
        case 3: //Privacy Policy
            let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
            destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(APIConstants.privacyPolicy)", VCLiteral.PRIVACY.localized)
            pushVC(destVC)
        case 4: // Tick Terms
            isTermsAgreed = !(isTermsAgreed)
            btnTick.backgroundColor = isTermsAgreed ? ColorAsset.appTint.color : .clear
            btnTick.setImage(isTermsAgreed ? #imageLiteral(resourceName: "ic_tick") : nil, for: .normal)
        default:
            break
        }
    }
    
}

//MARK:- VCFuncs
extension SignUpVC {
    
    private func validateDynamicFields() {
        if /UserPreference.shared.clientDetail?.hasQualification(for: .service_provider) && /tfQualification.text?.trimmingCharacters(in: .whitespaces) == "" {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.QUALIFICATION_ALERT.localized)
        } else if UserPreference.shared.masterPrefs?.getGenderPreference() != nil && gender == nil {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.GENDER_ALERT.localized)
        } else if UserPreference.shared.masterPrefs?.getLanguagePrefrence() != nil && /(dataSourceLng?.getSingleLisitngAllItems() ?? []).filter({ /$0.isSelected }).count == 0 {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.LANGUAGE_ALERT.localized)
        } else if !isTermsAgreed {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.TERMS_ALERT.localized)
        } else {
            registerAPI()
        }
    }
    
    private func registerAPI() {
        btnNext.playAnimation()
        var customFields: String?
        var fields = [CustomField]()
        
        if let custom = UserPreference.shared.clientDetail?.getCustomField(for: .Qualification, user: .service_provider) {
            custom.field_value = /tfQualification.text
            fields.append(custom)
            customFields = JSONHelper<[CustomField]>().toJSONString(model: fields)
        }
        
        var preferencesToSend = [PreferenceToSend]()
        var filters = [Filter]()
        if let genderFilter = UserPreference.shared.masterPrefs?.getGenderPreference(), let option = gender?.model {
            option.isSelected = true
            genderFilter.options = [option]
            filters.append(genderFilter)
        }
        
        if let languageFilter = UserPreference.shared.masterPrefs?.getLanguagePrefrence() {
            let selectedOptions = dataSourceLng?.getSingleLisitngAllItems().filter({/$0.isSelected}) ?? []
            languageFilter.options = selectedOptions
            filters.append(languageFilter)
        }
        
        filters.forEach({ (filter) in
            if /filter.options?.contains(where: {/$0.isSelected}) {
                let ids = ((filter.options)?.filter({/$0.isSelected}) ?? []).compactMap({/$0.id})
                preferencesToSend.append(PreferenceToSend.init(filter.id, ids))
            }
        })
        let jsonFilters = JSONHelper<[PreferenceToSend]>().toJSONString(model: preferencesToSend)
        
        
        let registerEP = EP_Login.register(name: tfFirstName.text, email: tfEmail.text, password: tfPsw.text, phone: nil, code: nil, user_type: .service_provider, fcm_id: UserPreference.shared.firebaseToken, country_code: nil, dob: dob?.toString(DateFormat.custom("yyyy-MM-dd"), isForAPI: true), bio: tvBio.text, profile_image: image_URL, workingSince: workingSince?.toString(DateFormat.custom("yyyy-MM-dd"), isForAPI: true), custom_fields: customFields, master_preferences: jsonFilters, inviteCode: tfInvite.text, is_agreed: true)
        
        
        #if NurseLynxExpert
        EP_Login.sendEmailOTP(email: /tfEmail.text).request { [weak self] (response) in
            self?.btnNext.stop()
            let destVC = Storyboard<VerificationVC>.LoginSignUp.instantiateVC()
            destVC.email = /self?.tfEmail.text
            destVC.registerEP = registerEP
            destVC.providerType = .email
            self?.pushVC(destVC)
        } error: { [weak self] error in
            self?.btnNext.stop()
        }

        #else
        registerEP.request(success: { [weak self] (response) in
            self?.btnNext.stop()
            if /UserPreference.shared.data?.services?.count == 0 {
                let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
                self?.pushVC(destVC)
            } else {
                UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
            }
        }) { [weak self] (_) in
            self?.btnNext.stop()
        }
        #endif
    }
    
    private func localizedTextSetup() {
        tfPsw.placeholder = VCLiteral.PSW_PLACEHOLDER.localized
        tfFirstName.placeholder = VCLiteral.NAME_PLACEHOLDER.localized
        tfDOB.placeholder = VCLiteral.DOB_PLACEHOLDER.localized
        tfEmail.placeholder = VCLiteral.EMAIL_PLACEHOLDER.localized
        tvBio.placeholder = VCLiteral.BIO_PLACEHOLDER.localized
        btnNext.setTitle(VCLiteral.NEXT.localized, for: .normal)
        lblTitle.text = VCLiteral.SIGNUP.localized
        tfQualification.placeholder = VCLiteral.QUALIFICATIONS.localized
        tfGender.placeholder = VCLiteral.GENDER.localized
        tfChooseLng.placeholder = VCLiteral.CHOOSE_LANG.localized
        
        lblByContinue.text = VCLiteral.BY_CONTINUE.localized
        btnTerms.setTitle(VCLiteral.TERMS.localized, for: .normal)
        btnPrivacy.setTitle(VCLiteral.PRIVACY.localized, for: .normal)
        lblAnnd.text = VCLiteral.AND.localized
        
        btnTick.setImage(isTermsAgreed ? #imageLiteral(resourceName: "ic_tick") : nil, for: .normal)
        btnTick.backgroundColor = isTermsAgreed ? ColorAsset.appTint.color : .clear
        
        viewQualification.isHidden = !(/UserPreference.shared.clientDetail?.hasQualification(for: .service_provider))
        tfQualification.isEnabled = (/UserPreference.shared.clientDetail?.hasQualification(for: .service_provider))
        
        viewGender.isHidden = UserPreference.shared.masterPrefs?.getGenderPreference() == nil
        tfGender.isEnabled = UserPreference.shared.masterPrefs?.getGenderPreference() != nil
        
        tfInvite.placeholder = VCLiteral.INVITE_CODE.localized
        viewInvite.isHidden = !(/UserPreference.shared.clientDetail?.invite_enabled)
        tfInvite.isEnabled = /UserPreference.shared.clientDetail?.invite_enabled
        
        var array = [GenderOption]()
        UserPreference.shared.masterPrefs?.getGenderPreference()?.options?.forEach({ (option) in
            array.append(GenderOption.init(option.option_name, option))
        })
                
        tfGender.inputView = SKGenericPicker<GenderOption>.init(frame: .zero, items: array, configureItem: { [weak self] (selectedGender) in
            self?.gender = selectedGender
            self?.tfGender.text = /selectedGender?.title
        })
        
        viewLanguage.isHidden = /UserPreference.shared.masterPrefs?.getLanguagePrefrence()?.options?.count == 0
        tfChooseLng.isEnabled = false
        
        tableLngOptions.isHidden = /UserPreference.shared.masterPrefs?.getLanguagePrefrence()?.options?.count == 0
        languageTableSetup()
    }
    
    @objc func selectImage() {
        view.endEditing(true)
        mediaPicker.presentPicker({ [weak self] (image) in
            self?.imgView.image = image
            self?.uploadImageAPI()
        }, nil, nil)
    }
    
    @objc private func namePrefixTapped() {
        view.endEditing(true)
        var prefixes = [VCLiteral.NAME_PREFIX_MR.localized,
                        VCLiteral.NAME_PREFIX_MRS.localized,
                        VCLiteral.NAME_PREFIX_MISS.localized,
                        VCLiteral.NAME_PREFIX_DR.localized]
        #if NurseLynxExpert
        prefixes.removeAll(where: {$0 == VCLiteral.NAME_PREFIX_DR.localized})
        #endif
        actionSheet(for: prefixes, title: nil, message: nil, view: lblNamePrefix) { [weak self] (selectedPrefix) in
            self?.lblNamePrefix.text = /selectedPrefix
        }
    }
    
    private func languageTableSetup() {
        dataSourceLng = TableDataSource<DefaultHeaderFooterModel<FilterOption>, DefaultCellModel<FilterOption>, FilterOption>.init(.SingleListing(items: UserPreference.shared.masterPrefs?.getLanguagePrefrence()?.options ?? [], identifier: LngOptionCell.identfier, height: 40.0, leadingSwipe: nil, trailingSwipe: nil), tableLngOptions)
        
        dataSourceLng?.configureCell = { (cell, item, indexPath) in
            (cell as? LngOptionCell)?.item = item
        }
        
        dataSourceLng?.didSelectRow = { [weak self] (indexPath, item) in
            item?.property?.model?.isSelected = !(/item?.property?.model?.isSelected)
            self?.tableLngOptions.reloadRows(at: [indexPath], with: .automatic)
            
            self?.tfChooseLng.text = /self?.dataSourceLng?.getSingleLisitngAllItems().filter({/$0.isSelected}).map({/$0.option_name}).joined(separator: ", ")
        }
        
        tblLngHeight.constant = 40.0 * /CGFloat(/UserPreference.shared.masterPrefs?.getLanguagePrefrence()?.options?.count)
    }
    
    private func uploadImageAPI() {
        playUploadAnimation(on: imgView)
        EP_Home.uploadMedia(image: (imgView.image)!, type: .image, doc: nil, localAudioPath: nil).request(success: { [weak self] (responseData) in
            self?.stopUploadAnimation()
            self?.image_URL = (responseData as? ImageUploadData)?.image_name
        }) { [weak self] (error) in
            self?.stopUploadAnimation()
            self?.alertBox(title: VCLiteral.UPLOAD_ERROR.localized, message: error, btn1: VCLiteral.CANCEL.localized, btn2: VCLiteral.RETRY_SMALL.localized, tapped1: {
                self?.imgView.image = nil
            }, tapped2: {
                self?.uploadImageAPI()
            })
        }
    }
}
