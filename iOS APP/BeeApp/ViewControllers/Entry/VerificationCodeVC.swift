//
//  VerificationCodeVC.swift
//  BeeApp
//
//  Created by Harshad-M007 on 21/04/21.
//

import Foundation
import UIKit
import Firebase

class VerificationCodeVC: YZParentVC {
    @IBOutlet weak var txtOTPCode: UITextField!
    var countryCode = ""
    var mobileNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let nationalityVC = segue.destination as? NationalityVC {
            nationalityVC.countryCode = countryCode
            nationalityVC.mobileNumber = mobileNumber
        }
    }
}

extension VerificationCodeVC {
    func prepareUIs() {
        
    }
    
    func verifyOTP() {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let verificationCode = txtOTPCode.text!.trimmedString
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: verificationCode)
        showCentralNVActivity()
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                YZValidationToast.shared.showToastOnStatusBar(error.localizedDescription)
                self.hideCentralNVActivity()
                return
            }
            self.signInUsing()
            // User is signed in
            // ...
        }
    }
}

extension VerificationCodeVC {
    @IBAction func btnConfirmPressed(_ sender: UIButton) {
        verifyOTP()
        
    }
    
    @IBAction func btnResendPressed(_ sender: UIButton) {
        sendOtpApi()
    }
}

//MARK: - API call
extension VerificationCodeVC {
    func signInUsing() {
        showCentralNVActivity()
        YZAPI.call.signIn(["signup_type": "1", "mobile" : mobileNumber, "country_code": countryCode, "device_type": "iOS", "fcm_token":YZApp.shared.getAPNSDeviceToken() ?? "", "device_token": YZApp.shared.getAPNSDeviceToken() ?? ""]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else{return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
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
                        if let _ = dictJSON["data"] as? NSDictionary {
                            YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                        } else {
                            weakSelf.performSegue(withIdentifier: "segueNationality", sender: nil)
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
            }
        }
    }
    
    func sendOtpApi() {
        txtOTPCode.text = ""
        let mobileNumber = "+\(countryCode)\(mobileNumber)"
        showCentralNVActivity()
        PhoneAuthProvider.provider().verifyPhoneNumber(mobileNumber, uiDelegate: nil) { (verificationID, error) in
          if let error = error {
            YZValidationToast.shared.showToastOnStatusBar(error.localizedDescription)
            return
          }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.hideCentralNVActivity()
        }
    }
}
