//
//  SocialConnect.swift
//
//  Created by iOS Development Company on 12/10/15.
//  Copyright © 2015 iOS Development Company All rights reserved.
//
//

import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import FirebaseCore
import FirebaseAuth

enum LoginType: String {
    case facebook = "F"
    case google = "G"
    case apple = "A"
    case normal = "normal"
}

struct SocialUser {
    var id: String
    var fName: String
    var lName: String
    var email: String
    var imgUrl: URL?
    var token: String
    var type: LoginType
    var invitationCode: String = ""
    var nationality: String = ""
    var isAfricanAmerican: Bool = false
    var isAlumni: Bool = false
    
    var fullName: String {
        return "\(fName) \(lName)".trimmedString
    }
    
    var requestParameterForFacebook: [String : Any] {
        var param =  [
            "first_name": fName,
            "last_name": lName,
            "signup_type": "2",
            "device_type": "iOS",
            "username": id,
            "device_token": YZApp.shared.getAPNSDeviceToken() ?? "",
            "type": "login",
            "fcm_token": YZApp.shared.getAPNSDeviceToken() ?? ""
        ]
        
        if !nationality.isEmpty && !invitationCode.isEmpty {
            param["is_hbcu_alumni"] = isAlumni ? "Yes" : "No"
            param["is_african_american"] = isAfricanAmerican ? "1" : "0"
            param["nationality"] = nationality
            param["invitation_code"] = invitationCode
            param["type"] = "signup"
        }
        return param
    }
    var requestParameterForGoogle: [String : Any] {
        var param =  [
            "first_name": fName,
            "last_name": lName,
            "signup_type": "3",
            "device_type": "iOS",
            "username": id,
            "device_token": YZApp.shared.getAPNSDeviceToken() ?? "",
            "type": "login",
            "fcm_token": YZApp.shared.getAPNSDeviceToken() ?? ""
        ]
        if !nationality.isEmpty && !invitationCode.isEmpty {
            param["is_hbcu_alumni"] = isAlumni ? "Yes" : "No"
            param["is_african_american"] = isAfricanAmerican ? "1" : "0"
            param["nationality"] = nationality
            param["invitation_code"] = invitationCode
            param["type"] = "signup"
        }
        return param
    }
    
    var requestParameterForApple: [String: Any] {
        var param = [
            "signup_type": "4",
            "first_name": fName,
            "last_name": lName,
            "device_type": "iOS",
            "username": email,
            "device_token": YZApp.shared.getAPNSDeviceToken() ?? "",
            "type": "login",
            "fcm_token": YZApp.shared.getAPNSDeviceToken() ?? ""
        ]
        
        if !nationality.isEmpty && !invitationCode.isEmpty {
            param["is_hbcu_alumni"] = isAlumni ? "Yes" : "No"
            param["is_african_american"] = isAfricanAmerican ? "1" : "0"
            param["nationality"] = nationality
            param["invitation_code"] = invitationCode
            param["type"] = "signup"
        }
        return param
    }
    
    init(fbdict: NSDictionary, token: String) {
        print(fbdict)
        id = fbdict.getStringValue(forKey: "id")
        fName = fbdict.getStringValue(forKey: "first_name")
        lName = fbdict.getStringValue(forKey: "last_name")
        email = fbdict.getStringValue(forKey: "email")
        type = .facebook
        if let urlStr = ((fbdict["picture"] as? NSDictionary)?["data"] as? NSDictionary)?["url"] as? String{
            imgUrl = URL(string: urlStr)
        }
        self.token = token
    }
    
    init(googleUser: GIDGoogleUser, token: String) {
        id = googleUser.userID
        fName = googleUser.profile.givenName
        lName = googleUser.profile.familyName
        email = googleUser.profile.email
        self.token = token
        type = .google
        if googleUser.profile.hasImage {
            imgUrl = googleUser.profile.imageURL(withDimension: 300)
        }
    }
    
    @available(iOS 13.0, *)
    init?(id: String, fName: String, lName: String, email: String, token: String) {
        self.id = id
        self.fName = fName
        self.lName = lName
        self.email = email
        type = .apple
        self.token = token
    }
    
    init(resDict: NSDictionary, usr: SocialUser) {
        id = usr.id
        imgUrl = usr.imgUrl
        email = resDict.getStringValue(forKey: "sEmail")
        fName = usr.fName
        lName = usr.lName
        type = usr.type
        token = usr.token
    }
}

class SocialViewController: YZParentVC {
    var appleBlock: ((ASAuthorizationAppleIDCredential?) -> ())?
    var googleBlock: ((GIDGoogleUser?) -> ())?
    var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        if let natinalityVC = segue.destination as? NationalityVC {
            natinalityVC.socialUser = sender as? SocialUser
        }
    }
}

// MARK: - Facebook Login
extension SocialViewController {
    
    @objc func connectToFacebook() {
        self.showCentralNVActivity()
        loginWithFacebook(permission: FBConfig.facebookPermission) { [weak self] (fbToken, error) in
            guard let weakSelf = self else {return}
            if let token = fbToken {
                weakSelf.fetchDataFromFacebook(graphPath: FBConfig.facebookMeUrl, param: FBConfig.facebookUserField, complitionHandler: { (userInfo, error) in
                    if let data = userInfo {
                        let fbUser = SocialUser(fbdict: data as NSDictionary, token: token)
                        DispatchQueue.main.async {
                            weakSelf.hideCentralNVActivity()
                        }
                        weakSelf.signInUsingSocial(socialUser: fbUser)
                    }else{
                        DispatchQueue.main.async {
                            weakSelf.hideCentralNVActivity()
                        }
                        YZValidationToast.shared.showToastOnStatusBar(error?.localizedDescription ?? "")
                    }
                })
            } else {
                DispatchQueue.main.async {
                    weakSelf.hideCentralNVActivity()
                }
                if let err = error {
                    YZValidationToast.shared.showToastOnStatusBar(err.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - FACEBOOK SDK
    func loginWithFacebook(permission: [String], complitionHandler: @escaping ((_ authToken: String?, _ error: Error?)->())) {
        let fbSDKLoginManager = LoginManager()
        fbSDKLoginManager.logOut()
        fbSDKLoginManager.logIn(permissions: permission , from: self) { (result, error) in
            DispatchQueue.main.async {
                if error != nil {
                    complitionHandler(nil, error)
                } else {
                    if let res = result {
                        if res.isCancelled {
                            print("Cancelled: \(res.isCancelled)")
                            complitionHandler(nil, nil)
                        } else if error == nil && !res.isCancelled && res.token != nil {
                            complitionHandler(res.token?.tokenString, error)
                        }
                    } else {
                        complitionHandler(nil, error)
                    }
                }
            }
        }
    }
    
    func fetchDataFromFacebook(graphPath: String, param: [String:Any], complitionHandler: @escaping ((_ data: [String:Any]?, _ error: Error?)->())) {
        GraphRequest(graphPath: graphPath, parameters: param).start(completionHandler: { (connection, userData, error) in
            DispatchQueue.main.async {
                if error != nil {
                    complitionHandler(nil, error)
                } else {
                    complitionHandler(userData as? [String:Any], error)
                }
            }
        })
    }
}


// MARK: - Google Login
extension SocialViewController: GIDSignInDelegate {
    @objc func connectToGoogle() {
        GIDSignIn.sharedInstance().clientID = "989483872592-0dkc2dqtb8ho3tlb8j6alusjdps2t9j1.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.disconnect()
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
        
        self.showCentralNVActivity()
        googleBlock = { [weak self] (user) -> () in
            guard let weakSelf = self else {return}
            if let gUser = user {
                let gleUser = SocialUser(googleUser: gUser, token: gUser.authentication.idToken)
                DispatchQueue.main.async {
                    weakSelf.hideCentralNVActivity()
                }
                weakSelf.signInUsingSocial(socialUser: gleUser)
            } else {
                weakSelf.hideCentralNVActivity()
            }
        }
    }
    
    // MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            googleBlock?(user)
            // ...
        } else {
            if (error as NSError).code != -5 {
                YZValidationToast.shared.showToastOnStatusBar(error.localizedDescription)
            }
            googleBlock?(nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

// MARK:- Login with apple
@available(iOS 13.0, *)
extension SocialViewController: ASAuthorizationControllerDelegate {
    
    @objc func connectToApple() {
        self.showCentralNVActivity()
        self.handleLogInWithAppleIDButtonPress()
        self.appleBlock = { [weak self] cred in
            guard let weakSelf = self else { return }
            if let sCred = cred {
                weakSelf.showCentralNVActivity()
                weakSelf.performFirebaseAppleLogin(cred: sCred)
                //                weakSelf.signInUsingSocial(socialUser: sUser)
            } else {
                DispatchQueue.main.async {
                    weakSelf.hideCentralNVActivity()
                }
            }
        }
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        // ASAuthorizationAppleIDProvider requests from User for AppleID
        // ASAuthorizationPasswordProvider access from KeyChain
        let requests = [ASAuthorizationAppleIDProvider().createRequest(), ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func handleLogInWithAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        currentNonce = randomNonceString()
        /// A controller that Shows the requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if (error as NSError).code != 1001 {
            YZValidationToast.shared.showToastOnStatusBar(error.localizedDescription)
        }
        appleBlock?(nil)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account in your system.
            // For the purpose of this demo app, store the these details in the keychain.
            //            KeychainItem.currentUserIdentifier = appleIDCredential.user
            //            Config.userDefault.setValue(appleIDCredential.user, forKey: UserDefaults.appleLoginIdKey)
            //            Config.userDefault.synchronize()
            
            print("User Id - \(appleIDCredential.user)")
            print("User Name - \(appleIDCredential.fullName?.description ?? "N/A")")
            print("User Email - \(appleIDCredential.email ?? "N/A")")
            print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
            
            /// The token to be sent to the app server.
            if let identityTokenData = appleIDCredential.identityToken,
               let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                print("Identity Token \(identityTokenString)")
                DispatchQueue.main.async {
                    self.appleBlock?(appleIDCredential)
                }
            } else {
                YZValidationToast.shared.showToastOnStatusBar("Login token not found.")
                DispatchQueue.main.async {
                    self.appleBlock?(nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.appleBlock?(nil)
            }
        }
    }
}

@available(iOS 13.0, *)
extension SocialViewController : ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


// MARK: - Api calls
extension SocialViewController {
    
    func signInUsingSocial(socialUser: SocialUser) {
        self.showCentralNVActivity()
        YZAPI.call.authorizedUsing(socialUser) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else{return}
            if statusCode == 200 {
                DispatchQueue.main.async {
                    weakSelf.hideCentralNVActivity()
                }
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        _appDelegate.requestForPushNotification()
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            if let userDict = dataDict["user"] as? NSDictionary {
                                YZApp.shared.setUserDetails(userDict)//Store user details to CoreData.
                                _appDelegate.navigateToUserTabBar(false)
                            }
                        }
                    } else if statusCode == 401 {
                        weakSelf.performSegue(withIdentifier: "showNationalitySegue", sender: socialUser)
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                DispatchQueue.main.async {
                    weakSelf.hideCentralNVActivity()
                }
            }
        }
    }
}


// MARK: - Firebase auth related method(s)
@available(iOS 13.0, *)
extension SocialViewController {
    func performFirebaseAppleLogin(cred: ASAuthorizationAppleIDCredential) {
        guard let nonce = currentNonce, let token = cred.identityToken, let tokenStr = String(data: token, encoding: .utf8) else { print("Error in firebase apple login"); return }
        let firebaseCred = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenStr, rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCred) {[weak self] (authRes, error) in
            guard let weakSelf = self else { return }
            if let error = error {
                print(" *** Error in firebase apple login response: \(error.localizedDescription) *** ")
            }
            print("email: \(String(describing: authRes?.user.email)), displayName: \(String(describing: authRes?.user.displayName)), userId: \(String(describing: authRes?.user.providerData[0].uid))")
            
            // execute first time when user logging
            if let fName = cred.fullName?.givenName, let lName = cred.fullName?.familyName {
                let changeRequest = authRes?.user.createProfileChangeRequest()
                changeRequest?.displayName = "\(fName) \(lName)"
                changeRequest?.commitChanges(completion: { (error) in
                    if let error = error {
                        print(" *** Error in updating name in firebase: \(error.localizedDescription) *** ")
                    }
                })
            }
            
            var fullName = ""
            if let name = authRes?.user.displayName, !name.isEmpty {
                fullName = name
            } else if let fName = cred.fullName?.givenName, let lName = cred.fullName?.familyName {
                fullName = "\(fName) \(lName)"
            }
            
            DispatchQueue.main.async {
                weakSelf.hideCentralNVActivity()
            }
            
            let fullNameArr = fullName.components(separatedBy: " ")
            guard let appleID = authRes?.user.providerData[0].uid, let email = authRes?.user.email else {
                print(" *** Not getting user info from Firebase *** ")
                return
            }
            var fName = ""
            var lName = ""
            if fullNameArr.count > 1 {
                fName = fullNameArr[0]
                lName = fullNameArr[1]
            } else {
                print(" *** Full name not found *** ")
            }
            
            weakSelf.signInUsingSocial(socialUser: SocialUser(id: authRes?.user.providerData[0].uid ?? "", fName: fName, lName: lName, email: authRes?.user.email ?? "", token: tokenStr)!)
        }
    }
    
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
}
