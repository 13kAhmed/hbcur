//
//  YZSignUp.swift
//  BeeApp
//
//  Created by Harshad-M007 on 18/05/21.
//

import Foundation
import GoogleSignIn
import AuthenticationServices

//MARK: - Enum SignUpUsing
enum SignUpUsing: String {
    case manual = "manual"
    case facebook = "facebook"
    case google = "google"
    case apple = "apple"
}

//MARK: - Struct YZSignUp
struct YZSignUp {
    let imageParameter: String = "profile"
    var image: UIImage?
    var facebookID: String
    var googleID: String
    var appleID: String
    var fullName: String
    var mobileNumber: String
    var email: String
    var password: String
    var using: SignUpUsing = .manual
    var isImageChoosed: Bool {
        return image != nil
    }
    var valid: (isValid: Bool, message: String) {
        /*if image != nil { //Optional for now
            return (false, YZApp.shared.getLocalizedText("choose_valid_picture"))
        }else*/
        if !fullName.isNameValid {
            return (false, YZApp.shared.getLocalizedText("enter_valid_name"))
        }else if !mobileNumber.trimmingWhiteSpaces.isEmpty && !mobileNumber.isValidMobileNumber() {
            return (false, YZApp.shared.getLocalizedText("enter_valid_mobile_number"))
        }else if email.trimmingWhiteSpaces.isEmpty {
            return (false, YZApp.shared.getLocalizedText("enter_email_address"))
        }else if !email.isEmailAddressValid {
            return (false, YZApp.shared.getLocalizedText("enter_valid_email"))
        }else if !password.isPasswordValid {
            return (false, YZApp.shared.getLocalizedText("enter_valid_password"))
        }else{
            return (true, "")
        }
    }
    var dataOfImage: Data? {
        return image?.scaleAndManageAspectRatio((414 * 3))?.jpegData(compressionQuality: 0.8)
    }
    var requestParameters: [String : Any] {
        return [
            "name": fullName,
            "email": email,
            "contact_number": mobileNumber,
            "password": password
        ]
    }
    var requestParameterForFacebook: [String : Any] {
        return [
            "facebook_id": facebookID,
            "name": fullName,
            "email": email,
            "type": using.rawValue
        ]
    }
    var requestParameterForGoogle: [String : Any] {
        return [
            "google_id": googleID,
            "name": fullName,
            "email": email,
            "type": using.rawValue
        ]
    }
    
    var requestParameterForApple: [String: Any] {
        return [
            "apple_id": appleID,
            "name": fullName,
            "email": email,
            "type": using.rawValue
        ]
    }

    init() {
        facebookID = ""
        googleID = ""
        appleID = ""
        fullName = ""
        mobileNumber = ""
        email = ""
        password = ""
    }
    
    init(_ dictFacebook: Dictionary<String, Any>) {
        facebookID = dictFacebook["id"] as! String
        googleID = ""
        appleID = ""
        fullName = dictFacebook["name"] as! String
        mobileNumber = ""
        email = dictFacebook["email"] as! String
        password = ""
        using = .facebook
    }
    
    init(_ google: GIDGoogleUser) {
        googleID = google.userID
        facebookID = ""
        appleID = ""
        fullName = google.profile.name
        mobileNumber = ""
        email = google.profile.email
        password = ""
        using = .google
    }

    @available(iOS 13.0, *)
    init(_ credential: ASAuthorizationAppleIDCredential) {
        googleID = ""
        facebookID = ""
        appleID =  credential.user
        if let fName = credential.fullName?.givenName, let lName = credential.fullName?.familyName {
            fullName = "\(fName) \(lName)"
        } else {
            fullName = ""
        }
        mobileNumber = ""
        email = credential.email ?? ""
        password = ""
        using = .apple
    }
    
    init(appleID:String, email: String, fullName: String) {
        googleID = ""
        facebookID = ""
        self.appleID = appleID
        self.fullName = fullName
        mobileNumber = ""
        self.email = email
        password = ""
        using = .apple
    }
}
