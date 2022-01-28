//
//  ProfileVC.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 02/06/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit

class ProfileVC: BaseVC {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblVersionNo: UILabel!
    @IBOutlet weak var lblVersionInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var headerView: UIView!
    
    private var dataSource: TableDataSource<DefaultHeaderFooterModel<ProfileItem>, DefaultCellModel<ProfileItem>, ProfileItem>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localizedTextSetup()
        imgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(viewProfile)))
        #if HealthCarePrashantExpert || HealExpert
        LocationManager.shared.startTrackingUser()
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateProfileData()
    }
}

//MARK:- VCFuncs
extension ProfileVC {
    @objc private func viewProfile() {
        pushVC(Storyboard<ProfileDetailVC>.Other.instantiateVC())
    }
    
    public func updateProfileData() {
        tableView.tableHeaderView = headerView
        lblName.text = "\(/UserPreference.shared.data?.profile?.title) \(/UserPreference.shared.data?.name)" 
        var age = VCLiteral.NA.localized
        if /UserPreference.shared.data?.profile?.dob != "" {
            age = "\(Date().year() - /Date.init(fromString: /UserPreference.shared.data?.profile?.dob, format: DateFormat.custom("yyyy-MM-dd")).year())"
        }
        lblAge.text = String.init(format: VCLiteral.AGE.localized, age)
        imgView.setImageNuke(/UserPreference.shared.data?.profile_image, placeHolder: #imageLiteral(resourceName: "ic_profile_placeholder"))
    }
    
    private func localizedTextSetup() {
        lblTitle.text = VCLiteral.PROFILE.localized
        lblVersionNo.text = String.init(format: VCLiteral.VERSION.localized, Bundle.main.versionNumber)
        lblVersionInfo.text = VCLiteral.VERSION_INFO.localized
        tableView.contentInset.top = 16.0
        dataSource = TableDataSource<DefaultHeaderFooterModel<ProfileItem>, DefaultCellModel<ProfileItem>, ProfileItem>.init(.SingleListing(items: ProfileItem.getItems(pages: UserPreference.shared.pages), identifier: SideMenuCell.identfier, height: 56.0, leadingSwipe: nil, trailingSwipe: nil), tableView)
        
        dataSource?.configureCell = { (cell, item, indexPath) in
            (cell as? SideMenuCell)?.item = item
        }
        
        dataSource?.didSelectRow = { [weak self] (indexPath, item) in
            switch item?.property?.model?.title ?? .AGE {
            case .CHAT:
                self?.pushVC(Storyboard<ChatListingVC>.Other.instantiateVC())
            case .BANK_DETAILS:
                self?.pushVC(Storyboard<BankDetailVC>.Other.instantiateVC())
            case .CLASSES:
                let destVC = Storyboard<ClassesVC>.Other.instantiateVC()
                self?.pushVC(destVC)
            case .NOTIFICATIONS:
                self?.pushVC(Storyboard<NotificationsVC>.Other.instantiateVC())
            case .INVITE_PEOPLE:
                let appLink = "https://apps.apple.com/us/app/id\(Configuration.getValue(for: .APP_APPLE_APP_ID))?ls=1"
                var shareItems = [appLink]
                if /UserPreference.shared.clientDetail?.invite_enabled {
                    shareItems.append(String.init(format: VCLiteral.USE_REFER_CODE.localized, /UserPreference.shared.data?.reference_code))
                }
                self?.share(items: shareItems, sourceView: self?.tableView.cellForRow(at: indexPath))
            case .LOGOUT:
                self?.logoutAlert()
            case .FREE_EXPERT_ADVICE:
                self?.pushVC(Storyboard<QuestionsVC>.Other.instantiateVC())
            case .SECOND_OPINION:
                let destVC = Storyboard<RequestsVC>.Other.instantiateVC()
                destVC.isSecondOpinion = true
                UIApplication.topVC()?.pushVC(destVC)
            case .HISTORY:
                self?.pushVC(Storyboard<HistoryVC>.Other.instantiateVC())
            #if NurseLynxExpert
            case .EMERGENCY_CONTACTS:
                self?.pushVC(Storyboard<EmergencyContactVC>.Other.instantiateVC())
            #endif
            case .ACCOUNT_SETTINGS:
                self?.pushVC(Storyboard<ProfileDetailVC>.Other.instantiateVC())
            case .CHANGE_PASSWORD:
                let destVC = Storyboard<ChangePSWVC>.LoginSignUp.instantiateVC()
//                destVC.didSuccess = { [weak self] in
//                    let successVC = Storyboard<SuccessPopUpVC>.PopUp.instantiateVC()
//                    successVC.modalPresentationStyle = .overFullScreen
//                    successVC.message = VCLiteral.PASSWORD_SUCCESS_MESSAGE.localized
//                    self?.present(successVC, animated: true, completion: nil)
//                }
                self?.pushVC(destVC)
            case .SUPPORT:
                let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
                destVC.linkTitle = (/UserPreference.shared.clientDetail?.support_url, VCLiteral.SUPPORT.localized)
                self?.pushVC(destVC)
            case .CHANGE_LANGUAGE:
                self?.openLanguageActionSheet(languages: [.English, .Arabic])
            default:
                let destVC = Storyboard<WebLinkVC>.Other.instantiateVC()
                destVC.linkTitle = ("\(/UserPreference.shared.clientDetail?.domain_url)/\(/item?.property?.model?.page?.slug)", /item?.property?.model?.page?.title)
                self?.pushVC(destVC)
            }
        }
    }
    
    private func logoutAlert() {
        alertBoxOKCancel(title: VCLiteral.LOGOUT.localized, message: VCLiteral.LOGOUT_ALERT_MESSAGE.localized, tapped: { [weak self] in
            self?.logoutAPI()
        }, cancelTapped: nil)
    }
    
    private func logoutAPI() {
        playLineAnimation()
        EP_Home.logout.request(success: { [weak self] (_) in
            self?.stopLineAnimation()
            SocketIOManager.shared.disconnect()
            UIWindow.replaceRootVC(Storyboard<LoginSignUpNavVC>.LoginSignUp.instantiateVC())
        }) { [weak self] (_) in
            self?.stopLineAnimation()
        }
    }
    
    private func openLanguageActionSheet(languages: [AppleLanguage]) {
        actionSheet(for: languages.map({$0.title.localized}), title: "", message: VCLiteral.CHOOSE_LANGUAGE.localized, view: nil) { (tappedLanguage) in
            switch tappedLanguage {
            case VCLiteral.LANGUAGE_ENGLISH.localized:
                L102Language.setAppleLanguage(to: .English)
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                (UIApplication.shared.delegate as! AppDelegate).setRoot(for: Storyboard<NavigationTabVC>.TabBar.instantiateVC())
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.apiToFetchPage()

            case VCLiteral.LANGUAGE_ARABIC.localized:
                L102Language.setAppleLanguage(to: .Arabic)
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                (UIApplication.shared.delegate as! AppDelegate).setRoot(for: Storyboard<NavigationTabVC>.TabBar.instantiateVC())
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.apiToFetchPage()

            default:
                break
            }
        }
    }
}
