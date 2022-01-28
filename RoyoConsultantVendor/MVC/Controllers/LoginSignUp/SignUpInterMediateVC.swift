//
//  SignUpInterMediateVC.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 13/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import SZTextView
import JVFloatLabeledTextField

class SignUpInterMediateVC: BaseVC {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblNamePrefix: UILabel!
    
    @IBOutlet weak var tfName: JVFloatLabeledTextField!
    @IBOutlet weak var tfEmail: JVFloatLabeledTextField!
    @IBOutlet weak var tfDOB: JVFloatLabeledTextField!
    @IBOutlet weak var tfWorkingSince: JVFloatLabeledTextField!
    @IBOutlet weak var tvBio: SZTextView!
    
    @IBOutlet weak var tfQualification: JVFloatLabeledTextField!
    @IBOutlet weak var tfGender: JVFloatLabeledTextField!
    @IBOutlet weak var tfChooseLng: JVFloatLabeledTextField!
    @IBOutlet weak var tableLngOptions: UITableView!
    @IBOutlet weak var viewQualification: UIView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var viewLanguage: UIView!
    @IBOutlet weak var tblLngHeight: NSLayoutConstraint!
    @IBOutlet weak var viewInvite: UIView!
    @IBOutlet weak var tfInvite: JVFloatLabeledTextField!
    
    private var dob: Date?
    private var workingSince: Date?
    private var image_URL: String?
    public var comingFrom: AvailabilityDataType = .WhileLoginModule    
    public var isViaAppleSignUp: Bool?
    private var gender: GenderOption?
    private var dataSourceLng: TableDataSource<DefaultHeaderFooterModel<FilterOption>, DefaultCellModel<FilterOption>, FilterOption>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        nextBtnAccessory.didTapContinue = { [weak self] in
            let btn = UIButton()
            btn.tag = 1
            self?.btnAction(btn)
        }
        
        tfResponder = TFResponder()
        tfResponder?.addResponders([.TF(tfName), .TF(tfEmail), .TF(tfDOB), .TF(tfWorkingSince), .TV(tvBio)])
        
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
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return nextBtnAccessory
    }
    
    @IBAction func btnAction(_ sender: UIButton) {
        switch sender.tag {
        case 0: //Back
            popVC()
        case 1: //Next
            switch Validation.shared.validate(values: (ValidationType.NAME, /tfName.text), (ValidationType.EMAIL, /tfEmail.text), (ValidationType.WORKING_SINCE, /tfWorkingSince.text)) {
            case .success:
                validateDynamicFields()
            case .failure(let alertType, let message):
                Toast.shared.showAlert(type: alertType, message: message.localized)
            }
        default:
            break
        }
    }
}

//MARK:- VCFuncs
extension SignUpInterMediateVC {
    
    private func validateDynamicFields() {
        if /UserPreference.shared.clientDetail?.hasQualification(for: .service_provider) && /tfQualification.text?.trimmingCharacters(in: .whitespaces) == "" {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.QUALIFICATION_ALERT.localized)
        } else if UserPreference.shared.masterPrefs?.getGenderPreference() != nil && gender == nil {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.GENDER_ALERT.localized)
        } else if UserPreference.shared.masterPrefs?.getLanguagePrefrence() != nil && /(dataSourceLng?.getSingleLisitngAllItems() ?? []).filter({ /$0.isSelected }).count == 0 {
            Toast.shared.showAlert(type: .validationFailure, message: VCLiteral.LANGUAGE_ALERT.localized)
        } else {
            updateProfileAPI()
        }
    }
    
    private func updateProfileAPI() {
        view.endEditing(true)
        view.isUserInteractionEnabled = false
        nextBtnAccessory.startAnimation()
        
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
        
        EP_Login.profileUpdate(name: tfName.text, email: tfEmail.text, phone: nil, country_code: nil, dob: dob?.toString(DateFormat.custom("yyyy-MM-dd"), timeZone: .local, isForAPI: true), bio: tvBio.text, speciality: nil, call_price: nil, chat_price: nil, category_id: nil, experience: nil, profile_image: image_URL, workingSince: workingSince?.toString(DateFormat.custom("yyyy-MM-dd"), timeZone: .local, isForAPI: true), namePrefix: /lblNamePrefix.text, custom_fields: customFields, master_preferences: jsonFilters, inviteCode: tfInvite.text, is_agreed: true).request(success: { [weak self] (response) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
            
            switch self?.comingFrom ?? .WhileLoginModule {
            case .WhileLoginModule:
                if /UserPreference.shared.data?.services?.count == 0 {
                    let destVC = Storyboard<CategoriesVC>.LoginSignUp.instantiateVC()
                    self?.pushVC(destVC)
                } else {
                    UIWindow.replaceRootVC(Storyboard<NavigationTabVC>.TabBar.instantiateVC())
                }
            case .WhileManaging:
                self?.popTo(toControllerType: ProfileDetailVC.self)
            }
            
        }) { [weak self] (error) in
            self?.view.isUserInteractionEnabled = true
            self?.nextBtnAccessory.stopAnimation()
        }
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
        
        let languages = dataSourceLng?.getSingleLisitngAllItems()
        let languagesKnown = UserPreference.shared.data?.master_preferences?.getLanguagePrefrence()?.options
        
        languages?.forEach({ (option) in
            option.isSelected = /languagesKnown?.contains(where: {$0.option_name == option.option_name })
        })
        tfChooseLng.text = languages?.filter({/$0.isSelected}).map({/$0.option_name}).joined(separator: ", ")
    }
    
    private func localizedTextSetup() {
        tfName.placeholder = VCLiteral.NAME_PLACEHOLDER.localized
        tfDOB.placeholder = VCLiteral.DOB_PLACEHOLDER.localized
        tfEmail.placeholder = VCLiteral.EMAIL_PLACEHOLDER.localized
        tvBio.placeholder = VCLiteral.BIO_PLACEHOLDER.localized
        
        switch comingFrom {
        case .WhileManaging: //Editing Profile Data
            lblTitle.text = VCLiteral.EDIT_PROFILE.localized
            

        case .WhileLoginModule:
            lblTitle.text = String.init(format: VCLiteral.JOINCONSULTANTS.localized, "2500")
        }
        
        let user = UserPreference.shared.data
        
        lblNamePrefix.text = user?.profile?.title ?? VCLiteral.NAME_PREFIX_MR.localized
        tfName.text = /user?.name
        tfEmail.text = /user?.email
        if user?.profile?.dob != nil {
            tfDOB.text = Date.init(fromString: /user?.profile?.dob, format: DateFormat.custom("yyyy-MM-dd")).toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
            tfWorkingSince.text = Date.init(fromString: /user?.profile?.working_since, format: DateFormat.custom("yyyy-MM-dd")).toString(DateFormat.custom(UserPreference.shared.dateFormat), timeZone: .local, isForAPI: false)
        }
        tvBio.text = /user?.profile?.bio
        imgView.setImageNuke(/user?.profile_image, placeHolder: nil)
        tfGender.text = /user?.master_preferences?.getGenderPreference()?.options?.first?.option_name
        gender = GenderOption.init(tfGender.text, user?.master_preferences?.getGenderPreference()?.options?.first)
        
        viewQualification.isHidden = !(/UserPreference.shared.clientDetail?.hasQualification(for: .service_provider))
        tfQualification.isEnabled = (/UserPreference.shared.clientDetail?.hasQualification(for: .service_provider))
        
        tfQualification.text = /UserPreference.shared.data?.custom_fields?.first(where: {/$0.field_name == CustomFieldType.Qualification.fieldName})?.field_value
        
        viewGender.isHidden = UserPreference.shared.masterPrefs?.getGenderPreference() == nil
        tfGender.isEnabled = UserPreference.shared.masterPrefs?.getGenderPreference() != nil
        
        var array = [GenderOption]()
        UserPreference.shared.masterPrefs?.getGenderPreference()?.options?.forEach({ (option) in
            array.append(GenderOption.init(option.option_name, option))
        })
            
        tfGender.inputView = SKGenericPicker<GenderOption>.init(frame: .zero, items: array, configureItem: { [weak self] (selectedGender) in
            self?.gender = selectedGender
            self?.tfGender.text = /selectedGender?.title
        })
        
        tfInvite.placeholder = VCLiteral.INVITE_CODE.localized
        viewInvite.isHidden = !(/UserPreference.shared.clientDetail?.invite_enabled)
        tfInvite.isEnabled = /UserPreference.shared.clientDetail?.invite_enabled
        
        viewLanguage.isHidden = /UserPreference.shared.masterPrefs?.getLanguagePrefrence()?.options?.count == 0
        tfChooseLng.isEnabled = false
        
        tableLngOptions.isHidden = /UserPreference.shared.masterPrefs?.getLanguagePrefrence()?.options?.count == 0
        languageTableSetup()
        
        switch UserPreference.shared.data?.provider_type ?? .phone {
        case .facebook, .google, .apple:
            tfEmail.isUserInteractionEnabled = false
        default:
            tfEmail.isUserInteractionEnabled = true
        }
        
        if /isViaAppleSignUp {
            tfName.text = /UserPreference.shared.socialLoginData?.name
            tfEmail.text = /UserPreference.shared.socialLoginData?.email
            tfEmail.isUserInteractionEnabled = /UserPreference.shared.socialLoginData?.email == ""
        }
    }
}
