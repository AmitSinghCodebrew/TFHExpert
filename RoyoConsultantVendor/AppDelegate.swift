//
//  AppDelegate.swift
//  RoyoConsultantVendor
//
//  Created by Sandeep Kumar on 27/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import GoogleSignIn
import IQKeyboardManagerSwift
import FBSDKLoginKit
import Firebase
import JitsiMeetSDK
#if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
import GoogleMaps
#endif

 

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    fileprivate var pipViewCoordinator: PiPViewCoordinator?
    fileprivate var jitsiMeetView: JitsiMeetView?
    private var onGoingCallRequestId: String?
    private var callId: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        sleep(1)
        
        L102Localizer.DoTheMagic()
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions) //FBSDK Setup
        
        if #available(iOS 13.0, *) {
            //Code written in SceneDelegate
        } else {
            setRootVC()
        }
        
        #if HealExpert || HomeDoctorKhalidExperts || NurseLynxExpert
        GMSServices.provideAPIKey(/Configuration.getValue(for: .APP_GOOGLE_PLACES_KEY))
        #endif
        
        IQ_KeyboardManagerSetup()
        
        registerRemoteNotifications(application)
        
        JitsiMeet.sharedInstance().defaultConferenceOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL.init(string: Configuration.getValue(for: .APP_JITSI_SERVER))!
        }

  
        
        return JitsiMeet.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions ?? [:])
    }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        appForegroundAction()
    }
}

//MARK:- Custom functions
extension AppDelegate {
    public func setRootVC() {
        window?.tintColor = ColorAsset.appTint.color
        if !(/UserPreference.shared.isLanguageScreenShown) {
            let navigationLanguageVC = UINavigationController.init(rootViewController: Storyboard<LanguageVC>.LoginSignUp.instantiateVC())
            navigationLanguageVC.navigationBar.isHidden = true
            setRoot(for: navigationLanguageVC)
        } else if !(/UserPreference.shared.isIntroScreensSeen) {
            let navigationChooseAppVC = UINavigationController.init(rootViewController: Storyboard<ChooseAppVC>.LoginSignUp.instantiateVC())
            navigationChooseAppVC.navigationBar.isHidden = true
            setRoot(for: navigationChooseAppVC)
        } else if !(/UserPreference.shared.isIntroScreensSeen) {
            let navigationIntroVC = UINavigationController.init(rootViewController: Storyboard<IntroVC>.LoginSignUp.instantiateVC())
            navigationIntroVC.navigationBar.isHidden = true
            setRoot(for: navigationIntroVC)
        } else if !(/UserPreference.shared.isLocationScreenSeen) {
            let navigationLocationVC = UINavigationController.init(rootViewController: Storyboard<LocationRequestVC>.LoginSignUp.instantiateVC())
            navigationLocationVC.navigationBar.isHidden = true
            setRoot(for: navigationLocationVC)
        } else if /UserPreference.shared.data?.token != "" && /UserPreference.shared.data?.services?.count != 0 {
            setRoot(for: Storyboard<NavigationTabVC>.TabBar.instantiateVC())
        } else {
            setRoot(for: Storyboard<LoginSignUpNavVC>.LoginSignUp.instantiateVC())
        }
    }
    
    public func setRoot(for vc: UIViewController) {
        window?.rootViewController = vc
        window?.tintColor = ColorAsset.appTint.color
        window?.makeKeyAndVisible()
        UIView.transition(with: window!, duration: 0.4, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { }, completion: { _ in })
    }
    
    public func appForegroundAction() {
        EP_Home.appversion(app: .VendorApp, version: Bundle.main.versionDecimalScrapped).request(success: { (responseData) in
            guard let updateType = (responseData as? AppData)?.update_type else {
                return
            }
            self.handleAppUpDate(updateType: updateType)
        })
        
        apiToFetchPage()
        
        EP_Home.masterPreferences(type: .All).request(success: { (responseData) in
        })
    }
    func apiToFetchPage() {
        EP_Home.pages.request(success: { (response) in
            #if HomeDoctorKhalidExperts
            UserPreference.shared.pages = response as? [Page]
            #endif
        })
        
        EP_Home.getClientDetail(app: .VendorApp).request(success: { (responeData) in

            #if HomeDoctorKhalidExperts
            #else
            UserPreference.shared.pages = UserPreference.shared.clientDetail?.pages

            #endif

            if /UserPreference.shared.data?.token != "" {
                SocketIOManager.shared.connect(nil)
            }
        })
    }
    func handleAppUpDate(updateType: AppUpdateType) {
        let appURL = "http://itunes.apple.com/app/id\(Configuration.getValue(for: .APP_APPLE_APP_ID))"
        switch updateType {
        case .NoUpdate:
            break
        case .MinorUpdate:
            UIApplication.topVC()?.alertBoxOKCancel(title: String.init(format: VCLiteral.UPDATE_TITLE.localized, Configuration.appName()), message: VCLiteral.UPDATE_DESC.localized, tapped: {
                UIApplication.shared.open(URL.init(string: appURL)!, options: [:], completionHandler: nil)
            }, cancelTapped: nil)
        case .MajorUpdate:
            UIApplication.topVC()?.alertBox(title: String.init(format: VCLiteral.UPDATE_TITLE.localized, Configuration.appName()), message: VCLiteral.UPDATE_DESC.localized, btn1: VCLiteral.OK.localized, btn2: nil, tapped1: {
                UIApplication.shared.open(URL.init(string: appURL)!, options: [:], completionHandler: nil)
            }, tapped2: nil)
        }
    }
    
    private func IQ_KeyboardManagerSetup() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(IQView.self)
        IQKeyboardManager.shared.toolbarTintColor = ColorAsset.appTint.color
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(ChatVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(SignUpInterMediateVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(LoginEmailVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(LoginMobileVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(VerificationVC.self)
        IQKeyboardManager.shared.disabledToolbarClasses.append(QuestionDetailVC.self)
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(QuestionDetailVC.self)
    }
    
    private func registerRemoteNotifications(_ app: UIApplication) {
        let filePath = Bundle.main.path(forResource: Configuration.getValue(for: .APP_PLIST_NAME), ofType: "plist")!
        let options = FirebaseOptions(contentsOfFile: filePath)
        FirebaseApp.configure(options: options!)
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization( options: authOptions,completionHandler: {_, _ in })
        app.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func handleAutomaticRefreshData(_ model: RemotePush?) {
        switch model?.pushType ?? .UNKNOWN {
        case .chat:
            if /(UIApplication.topVC() as? ChatVC)?.thread?.id == /Int(/model?.request_id) {
                return
            } else if /UIApplication.topVC()?.isKind(of: ChatListingVC.self) {
                Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
                (UIApplication.topVC() as? ChatListingVC)?.reloadViaNotification()
                return
            } else {
                Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
                if let listingVC: ChatListingVC = (UIApplication.topVC()?.tabBarController?.viewControllers?.last as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: ChatListingVC.self)}) as? ChatListingVC {
                    listingVC.reloadViaNotification()
                }
            }
        case .BOOKING_REQUEST:
             #if NurseLynxExpert
            ((UIApplication.topVC()?.tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: HomeVC.self)}) as? HomeVC)?.getPendingRequestsAPI()
            (UIApplication.topVC() as? HomeVC)?.getPendingRequestsAPI()

            #else
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
            
            #endif
            return
             
            
        case .NEW_REQUEST,
             .REQUEST_COMPLETED,
             .CANCELED_REQUEST,
             .REQUEST_FAILED,
             .RESCHEDULED_REQUEST,
             .PROFILE_APPROVED,
             .UPCOMING_APPOINTMENT,
             .PATIENT_ADDED_SYMPTOMS,
             .PAID_EXTRA_PAYMENT,
             .USER_AVAILABLE,
             .REQUEST_EXTRA_PAYMENT:
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
            ((UIApplication.topVC()?.tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: HomeVC.self)}) as? HomeVC)?.dataSource?.refreshProgrammatically()
            (UIApplication.topVC() as? ApptDetailVC)?.refreshViaNotification()
        case .AMOUNT_RECEIVED,
             .PAYOUT_PROCESSED,
             .PAYOUT_FAILED,
             .BALANCE_ADDED,
             .BALANCE_FAILED:
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
            ((UIApplication.topVC()?.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: WalletVC.self)}) as? WalletVC)?.dataSource?.refreshProgrammatically()
        case .ASSINGED_USER:
            if /UIApplication.topVC()?.isKind(of: ClassesVC.self) {
                (UIApplication.topVC() as? ClassesVC)?.dataSource?.refreshProgrammatically()
            } else if let vc = (UIApplication.topVC()?.tabBarController?.viewControllers?.last as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: ClassesVC.self)}) as? ClassesVC {
                vc.dataSource?.refreshProgrammatically()
            }
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
            
        case .PROFILE_REJECTED,
             .DOCUMENT_REJECTED:
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
            
        case .UNKNOWN:
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
        case .CALL_CANCELED:
            if /callId == /model?.call_id {
                DispatchQueue.main.async {
                    self.pipViewCoordinator?.hide() { _ in
                        self.cleanUp()
                    }
                }
                if let requestId = onGoingCallRequestId {
//                    model?.call_id
              
                    EP_Home.callStatus(requestID: requestId, status: .CALL_CANCELED, callId: model?.call_id ).request(success: { [weak self] (_) in
                        self?.onGoingCallRequestId = nil
                        self?.callId = nil
                    }) { (_) in
                        
                    }
                }
            }
        case .CALL_ACCEPTED:
            (UIApplication.topVC() as? CallVC)?.callStatusUpdate(status: .CALL_ACCEPTED)
            callId = model?.call_id
        case .CALL_RINGING:
            (UIApplication.topVC() as? CallVC)?.callStatusUpdate(status: .CALL_RINGING)
            callId = model?.call_id
        }
    }
    
    private func handleNotificationTap(_ model: RemotePush?) {
        switch model?.pushType ?? .UNKNOWN {
        case .chat:
            if /UIApplication.topVC()?.isKind(of: ChatVC.self) {
                if /(UIApplication.topVC() as? ChatVC)?.thread?.id != /Int(/model?.request_id) {
                    //Refresh Chat Data for new vendor chat
                    (UIApplication.topVC() as? ChatVC)?.initialChatLoad()
                }
            } else {
                if let listingVC: ChatListingVC = (UIApplication.topVC()?.tabBarController?.viewControllers?.last as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: ChatListingVC.self)}) as? ChatListingVC {
                    listingVC.reloadViaNotification()
                    UIApplication.topVC()?.tabBarController?.selectedIndex = 3
                }
                let destVC = Storyboard<ChatVC>.Other.instantiateVC()
                destVC.thread = ChatThread.init(model!)
                UIApplication.topVC()?.pushVC(destVC)
            }
        case .BOOKING_REQUEST:
            #if NurseLynxExpert
            UIApplication.topVC()?.tabBarController?.selectedIndex = 0
            ((UIApplication.topVC()?.tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: HomeVC.self)}) as? HomeVC)?.getPendingRequestsAPI(isRefreshing: true)
            
            #else
            Toast.shared.showAlert(type: .notification, message: /model?.aps?.alert?.body)
            #endif
        case .NEW_REQUEST,
             .REQUEST_COMPLETED,
             .CANCELED_REQUEST,
             .REQUEST_FAILED,
             .RESCHEDULED_REQUEST,
             .UPCOMING_APPOINTMENT,
             .PATIENT_ADDED_SYMPTOMS,
             .PAID_EXTRA_PAYMENT,
             .USER_AVAILABLE,
             .REQUEST_EXTRA_PAYMENT,
             .PROFILE_REJECTED,
             .DOCUMENT_REJECTED:
            UIApplication.topVC()?.tabBarController?.selectedIndex = 0
            ((UIApplication.topVC()?.tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: HomeVC.self)}) as? HomeVC)?.dataSource?.refreshProgrammatically()
            
            if /UIApplication.topVC()?.isKind(of: ApptDetailVC.self) && /(UIApplication.topVC() as? ApptDetailVC)?.request?.id == /Int(/model?.request_id) {
                (UIApplication.topVC() as? ApptDetailVC)?.refreshViaNotification()
            } else {
                let destVC = Storyboard<ApptDetailVC>.Other.instantiateVC()
                destVC.requestID = Int(/model?.request_id)
                UIApplication.topVC()?.pushVC(destVC)
            }
        case .PROFILE_APPROVED:
            UIApplication.topVC()?.tabBarController?.selectedIndex = 0
            ((UIApplication.topVC()?.tabBarController?.viewControllers?.first as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: HomeVC.self)}) as? HomeVC)?.dataSource?.refreshProgrammatically()
        case .AMOUNT_RECEIVED,
             .PAYOUT_PROCESSED,
             .PAYOUT_FAILED,
             .BALANCE_ADDED,
             .BALANCE_FAILED:
            UIApplication.topVC()?.tabBarController?.selectedIndex = 1
            ((UIApplication.topVC()?.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers.first(where: {$0.isKind(of: WalletVC.self)}) as? WalletVC)?.dataSource?.refreshProgrammatically()
        case .ASSINGED_USER:
            if /UIApplication.topVC()?.isKind(of: ClassesVC.self) {
                (UIApplication.topVC() as? ClassesVC)?.dataSource?.refreshProgrammatically()
            } else {
                UIApplication.topVC()?.pushVC(Storyboard<ClassesVC>.Other.instantiateVC())
            }
        case .UNKNOWN:
            break
        case .CALL_CANCELED:
            callId = model?.call_id
            DispatchQueue.main.async {
                self.pipViewCoordinator?.hide() { _ in
                    self.cleanUp()
                }
            }
            if let requestId = onGoingCallRequestId {
                EP_Home.callStatus(requestID: requestId, status: .CALL_CANCELED, callId: callId ?? "").request(success: { [weak self] (_) in
                    self?.onGoingCallRequestId = nil
                }) { (_) in
                    
                }
            }
        case .CALL_ACCEPTED:
            callId = model?.call_id
            (UIApplication.topVC() as? CallVC)?.callStatusUpdate(status: .CALL_ACCEPTED)
        case .CALL_RINGING:
            callId = model?.call_id
            (UIApplication.topVC() as? CallVC)?.callStatusUpdate(status: .CALL_RINGING)
        }
    }
}

//MARK:- UNUserNotificationCenter Deelgates
extension AppDelegate: UNUserNotificationCenterDelegate {
    //MARK:- Notification Native UI Tapped
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.request.content.userInfo as? [String : Any] else { return }
        let notificationData = JSONHelper<RemotePush>().getCodableModel(data: userInfo)
        handleNotificationTap(notificationData)
    }
    
    //MARK:- Native notification just came up
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard let userInfo = notification.request.content.userInfo as? [String : Any] else { return }
        let notificationData = JSONHelper<RemotePush>().getCodableModel(data: userInfo)
        handleAutomaticRefreshData(notificationData)
    }
}

//MARK:- Firebase messaging delegate
extension AppDelegate: MessagingDelegate {
    internal func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM TOKEN", fcmToken)
        UserPreference.shared.firebaseToken = fcmToken
        if /UserPreference.shared.data?.token != "" {
            EP_Home.updateFCMId.request(success: { (_) in
                
            })
        }
    }
}

//MARK:- Jitsi start call functions for classes and calls
extension AppDelegate: JitsiMeetViewDelegate {
    public func startJitsiCall(roomName: String, requestId: String? = nil, subject: String?, isVideo: Bool?, callID: String? = nil) {
        cleanUp()
        print("roomName " , roomName)
        print("callID " , callID ?? "")
        print("requestId " , requestId ?? "")
        
        
        onGoingCallRequestId = requestId
        
        callId = callID
        
        let user = UserPreference.shared.data
        
        // create and configure jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL.init(string: Configuration.getValue(for: .APP_JITSI_SERVER))
            builder.room = roomName
            //          builder.room = callID ?? ""
            builder.welcomePageEnabled = false
            builder.userInfo = JitsiMeetUserInfo.init(displayName: /user?.name?.capitalizingFirstLetter(), andEmail: user?.email, andAvatar: URL.init(string: Configuration.getValue(for: .APP_IMAGE_UPLOAD) + /user?.profile_image)!)
            builder.setFeatureFlag("invite.enabled", withValue: false)
            builder.setFeatureFlag("chat.enabled", withValue: false)
            builder.setFeatureFlag("calendar.enabled", withValue: false)
            builder.setFeatureFlag("call-integration.enabled", withValue: false)
            builder.setFeatureFlag("live-streaming.enabled", withValue: false)
            builder.setFeatureFlag("recording.enabled", withValue: false)
            builder.setFeatureFlag("tile-view.enabled", withValue: true)
            builder.setFeatureFlag("meeting-password.enabled", withValue: false)
            builder.setFeatureFlag("pip.enabled", withValue: true)
            builder.setFeatureFlag("close-captions.enabled", withValue: false)
            builder.subject = /subject
            builder.audioMuted = false
            builder.videoMuted = !(/isVideo)
        }
        jitsiMeetView.join(options)
        // Enable jitsimeet view to be a view that  can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: UIWindow.keyWindow?.subviews.last)
        
        // animate in
        jitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }
    
    fileprivate func cleanUp() {
        jitsiMeetView?.leave()
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }
    
    internal func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() { _ in
                self.cleanUp()
            }
        }
        if let requestId = onGoingCallRequestId {
            EP_Home.callStatus(requestID: requestId, status: .CALL_CANCELED, callId: callId ?? "").request(success: { [weak self] (_) in
                self?.onGoingCallRequestId = nil
                self?.callId = nil
            }) { (_) in
                
            }
        }
    }
    
    internal func enterPicture(inPicture data: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
        }
    }
}

