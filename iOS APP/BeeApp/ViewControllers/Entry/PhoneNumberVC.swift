//
//  PhoneNumberVC.swift
//  BeeApp
//
//  Created by Harshad-M007 on 21/04/21.
//

import Foundation
import UIKit
import Firebase

class PhoneNumberVC: YZParentVC {
   
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var lblCountryCode: UILabel!
    @IBOutlet weak var txtMobileNumber: UITextField!
    var countryCode = "1"
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        self.lblCountry.text = "United States of America +1"
        self.lblCountryCode.text = "+1"
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let countryPickerVC = segue.destination as? CountryPickerVC {
            countryPickerVC.actionBlock = { country in
                self.countryCode = "\(country.phoneCode ?? "")"
                self.lblCountry.text = "\(country.name ?? "") (+\(country.phoneCode ?? ""))"
                self.lblCountryCode.text = "+\(country.phoneCode ?? "")"
            }
        }
        
        if let verificationVC = segue.destination as? VerificationCodeVC {
            verificationVC.countryCode = countryCode
            verificationVC.mobileNumber = txtMobileNumber.text!.trimmedString
        }
    }
}

extension PhoneNumberVC {
    func prepareUIs() {
        
    }
    
    func sendOtpApi() {
        let mobileNumber = "+\(countryCode)\(txtMobileNumber.text!.trimmedString)"
        showCentralNVActivity()
        PhoneAuthProvider.provider().verifyPhoneNumber(mobileNumber, uiDelegate: nil) { (verificationID, error) in
          if let error = error {
            YZValidationToast.shared.showToastOnStatusBar(error.localizedDescription)
            self.hideCentralNVActivity()
            return
          }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.hideCentralNVActivity()
            self.performSegue(withIdentifier: "showVerificationVC", sender: nil)
          // Sign in using the verificationID and the code sent to the user
          // ...
        }
    }
}

extension PhoneNumberVC {
    @IBAction func btnSendSMSPressed(_ sender: UIButton) {
        if txtMobileNumber.text!.isValidMobileNumber() {
            sendOtpApi()
        } else {
            YZValidationToast.shared.showToastOnStatusBar("Enter valid mobile number")
        }
    }
}
