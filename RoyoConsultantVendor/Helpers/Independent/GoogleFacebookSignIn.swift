//
//  GoogleFacebookSignIn.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 12/05/20.
//  Copyright © 2020 SandsHellCreations. All rights reserved.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices


//-------------------------------------------------------------------------------------------------------------------
//MARK:- GoogleSigin Class
class GoogleSignIn: NSObject, GIDSignInDelegate {
    
    typealias SuccessCallBack = ((_ userData: GoogleAppleFBUserData?) -> ())
    var successCallBack: SuccessCallBack?
    
    static let shared = GoogleSignIn()
    
    override init() {
        super.init()
        GIDSignIn.sharedInstance()?.clientID = Configuration.getValue(for: .APP_CLIENT_ID)
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func openGoogleSigin(success: SuccessCallBack?) {
        GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.topVC()
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance().signIn()
        successCallBack = success
    }
    
    //MARK:- GIDSignInDelegate Method
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user != nil {
            let googleData = GoogleAppleFBUserData.init(user.profile.name, user.userID, user.profile.email, user.profile.imageURL(withDimension: 120), user.authentication.idToken)
            UserPreference.shared.socialLoginData = googleData
            successCallBack?(googleData)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
}

//-------------------------------------------------------------------------------------------------------------------
//MARK:- Facebook Login Class
class FBLogin: NSObject {
    
    static let shared = FBLogin()
    
    typealias SuccessCallBack = ((_ userData: GoogleAppleFBUserData?) -> ())
    var successCallBack: SuccessCallBack?
    
    func login(_ success: SuccessCallBack?) {
        successCallBack = success
        AccessToken.current = nil
        Profile.current = nil
        LoginManager().logOut()
        LoginManager().logIn(permissions: ["email", "public_profile", "user_friends"], from: UIApplication.topVC()) { (result, err) in
            if err != nil {
                print("failed to start graph request: \(String(describing: err))")
                return
            }
            self.getEmailNameIdImageFromFB()
        }
    }
    
    fileprivate func getEmailNameIdImageFromFB() {
        GraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.width(480).height(480)"]).start { [weak self] (connection, result, err) -> Void in
            if err != nil {
                print("failed to start graph request: \(String(describing: err))")
                return
            }
            print(result ?? "")
            let fbData = GoogleAppleFBUserData(result: result as AnyObject?)
            UserPreference.shared.socialLoginData = fbData
            self?.successCallBack?(fbData)
        }
    }
}

//MARK:- Google and Facebook Model
//-------------------------------------------------------------------------------------------------------------------
class GoogleAppleFBUserData {
    var name: String?
    var id: String?
    var email: String?
    var imageURL: URL?
    var isThroughGoogle = false
    var accessToken: String?
    var password: String?

    init(_ _name: String?, _ _id: String?, _ _email: String?, _ _imageURL: URL?, _ _accessToken: String?) {
        name = _name
        id = _id
        email = _email
        imageURL = _imageURL
        isThroughGoogle = true
        accessToken = _accessToken
    }
    
    init(result : AnyObject?) {
        guard let fbResult = result else { return }
        id = fbResult.value(forKey: "id") as? String
        name = fbResult.value(forKey: "name") as? String
        email = fbResult.value(forKey: "email") as? String
        imageURL = URL.init(string: "https://graph.facebook.com/".appending(/AccessToken.current?.userID).appending("/picture?type=large"))
        isThroughGoogle = false
        accessToken = /AccessToken.current?.tokenString
    }
    
    init(_ _id: String?, _ _firstName: String?, _ _lastName: String?, _ _email: String?, _ _password: String?) {
         id = _id
         accessToken = _id
         name = /_firstName + " " + /_lastName
         email = _email
         password = _password
     }
}
//-------------------------------------------------------------------------------------------------------------------

@IBDesignable class AppleSignInButton: UIView {
    
    private var appleBtn = ASAuthorizationAppleIDButton()
    
    public var didCompletedSignIn: ((_ user: GoogleAppleFBUserData) -> Void)?
    
    private var appleData: GoogleAppleFBUserData? {
        didSet {
            UserPreference.shared.socialLoginData = appleData
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setUpView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpView()
    }
    
    @IBInspectable private var type: Int = ASAuthorizationAppleIDButton.ButtonType.default.rawValue {
        didSet {
            let buttonType = ASAuthorizationAppleIDButton.ButtonType(rawValue: type) ?? ASAuthorizationAppleIDButton.ButtonType.default
            let buttonStyle = UITraitCollection.current.userInterfaceStyle == .dark ? ASAuthorizationAppleIDButton.Style.white : ASAuthorizationAppleIDButton.Style.black
            appleBtn = ASAuthorizationAppleIDButton.init(type: buttonType, style: buttonStyle)
            setUpView()
        }
    }
    
    private func setUpView() {
        appleBtn.tag = 420
        appleBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(appleBtn)
        NSLayoutConstraint.activate([
            appleBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            appleBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            appleBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            appleBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        appleBtn.addTarget(self, action: #selector(didTapASAuthorizationButton), for: .touchUpInside)
    }
    
    
    
    @objc private func didTapASAuthorizationButton() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController.init(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

//MARK:- Presentation Context Provider Delegate
extension AppleSignInButton: ASAuthorizationControllerPresentationContextProviding {
    internal func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIWindow.keyWindow!
    }
}

//MARK:- ASAuthorizationController Delegate
extension AppleSignInButton: ASAuthorizationControllerDelegate {
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        let alertBox = UIAlertController.init(title: AppSignInStrings.APPLE_SIGN_IN_FAILED_TITLE.localized, message: error.localizedDescription, preferredStyle: .alert)
        alertBox.addAction(UIAlertAction.init(title: AppSignInStrings.APPLE_SIGN_IN_OK.localized, style: .default, handler: nil))
        UIWindow.keyWindow?.rootViewController?.present(alertBox, animated: true, completion: nil)
    }
    
    internal func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            appleData = GoogleAppleFBUserData(credentials.user, credentials.fullName?.givenName, credentials.fullName?.familyName, credentials.email, nil)
            didCompletedSignIn?(appleData!)
        case let passwordCredential as ASPasswordCredential:
            appleData = GoogleAppleFBUserData(passwordCredential.user, "", "", "", passwordCredential.password)
            didCompletedSignIn?(appleData!)
        default:
            break
        }
    }
}

enum AppSignInStrings: String {
    case APPLE_SIGN_IN_FAILED_TITLE = "SIGN_IN_FAILED_TITLE"
    case APPLE_SIGN_IN_OK = "APPLE_SIGN_IN_OK"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, tableName: Configuration.getValue(for: .APP_LOCALIZABLE), comment: "")
    }
}

