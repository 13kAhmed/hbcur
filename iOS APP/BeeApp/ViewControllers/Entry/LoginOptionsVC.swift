//
//  LoginOptionsVC.swift
//  BeeApp
//
//  Created by iOSDev on 15/04/21.
//

import UIKit
import SafariServices

class LoginOptionsVC: SocialViewController {
    
    @IBOutlet weak var lblTnC: KPLinkLabel!
    @IBOutlet var lblOptions: [UILabel]!
    
//    "By logging in, you agree to the Terms of Service and Privacy Policy.";
    var termText: NSAttributedString {
        let attriString = NSMutableAttributedString()
        attriString.append(NSAttributedString(string: "By logging in, you agree to the ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16)]))
        attriString.append(NSAttributedString(string:"Terms of Service", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16), NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.attachment : "Terms of Service"]))
        attriString.append(NSAttributedString(string: " and ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16)]))
        attriString.append(NSAttributedString(string: "Privacy Policy", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16) , NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.attachment : "Privacy Policy"]))
        
        return attriString
    }
    
    var optionsKey = ["continue_fb","continue_google","continue_apple","continue_mobile"]
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        // Do any additional setup after loading the view.
    }
}

extension LoginOptionsVC {
    func prepareUIs() {
        lblTnC.setTagText(attriText: termText, linebreak: .byTruncatingTail)
        lblTnC.delegate = self
        for(i, lbl) in lblOptions.enumerated() {
            lbl.text =  YZApp.shared.getLocalizedText(optionsKey[i])
        }
        
    }
}


extension LoginOptionsVC {
    @IBAction func btnPhoneNumberPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showPhoneNumberVC", sender: nil)
    }
    
    @IBAction func btnFacebookPressed(_ sender: UIButton) {
        connectToFacebook()
    }
    
    @IBAction func btnGooglePressed(_ sender: UIButton) {
        connectToGoogle()
    }
    
    @IBAction func btnApplePressed(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            connectToApple()
        }
    }
}

// MARK: - Terms and condition delegate methods
extension LoginOptionsVC: KPLinkLabelDelagete {
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: KPLinkLabel) {
        if tagName == "Terms of Service" {
            if let url = URL(string: "https://hbcucrypto.com/terms-services.html") {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        } else {
            if let url = URL(string: "https://hbcucrypto.com/privacy-policy.html") {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        }
    }
    
    func tapOnEmpty(index: IndexPath?) {}
}
