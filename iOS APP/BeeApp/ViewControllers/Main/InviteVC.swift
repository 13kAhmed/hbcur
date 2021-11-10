//
//  InviteVC.swift
//  BeeApp
//
//  Created by iOSDev on 22/04/21.
//

import ContactsUI
import UIKit
import SafariServices

class InviteVC: YZParentVC {

    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblTermsAndPolicy: KPLinkLabel!
    
    var termText: NSAttributedString {
        let attriString = NSMutableAttributedString()
        attriString.append(NSAttributedString(string:"Terms of Service", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16), NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.attachment : "Terms of Service"]))
        attriString.append(NSAttributedString(string: " and ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16)]))
        attriString.append(NSAttributedString(string: "Privacy Policy", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 16) , NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.attachment : "Privacy Policy"]))
        
        return attriString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCode.text = YZApp.shared.objLogInUser!.invitationCode
        KPContactManager.shared.contactMustContain = [.phone]
        // Do any additional setup after loading the view.
        
        lblTermsAndPolicy.setTagText(attriText: termText, linebreak: .byTruncatingTail)
        lblTermsAndPolicy.delegate = self
        
    }
    
    @IBAction func btnSharePressed(_ sender: UIButton) {
        let website = "Website: https://hbcucrypto.com/"
        let applink = "App link: https://apps.apple.com/us/app/hbcu-crypto/id1576103910"
        let data = ["Here is my invitation code for HBCU: \(YZApp.shared.objLogInUser!.invitationCode) \n \(applink) \n \(website)"] as [Any]
        let activityController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        if let popoverController = activityController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = self.view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func btnInviteContacPressed(_ sender: UIButton) {
        let contactPicker = CNContactPickerViewController()
               contactPicker.delegate = self
               contactPicker.displayedPropertyKeys =
                   [CNContactGivenNameKey
                       , CNContactPhoneNumbersKey]
               self.present(contactPicker, animated: true, completion: nil)
//        let pickerVC = UIStoryboard(name: "KPContact", bundle: nil).instantiateViewController(withIdentifier: "KPContactPickerVC") as! KPContactPickerVC
//        let website = "Website: https://hbcucrypto.com/"
//        let applink = "App link: https://apps.apple.com/us/app/hbcu-crypto/id1576103910"
//        pickerVC.selectionBlock = { [weak self] contact in
//            if !contact.phoneNo.isEmpty {
//                let sms: String = "sms:\(contact.phoneNo[0].phoneNumber)&body=Here is my invitation code for HBCU: \(YZApp.shared.objLogInUser!.invitationCode) \n \(applink) \n \(website)"
//                let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
//            }
//        }
//        self.navigationController?.pushViewController(pickerVC, animated: true)
    }
    
    @IBAction func btnCopyPressed(_ sender: UIButton) {
        UIPasteboard.general.string = YZApp.shared.objLogInUser!.invitationCode
        YZValidationToast.shared.showToastOnStatusBar("Code copied successfully", color: UIColor.TOASTSUCCESS!)
    }
    
    @IBAction func btnTermsPressed(_ sender: UIButton) {
        if let url = URL(string: "https://hbcucrypto.com/terms-services.html") {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Terms and condition delegate methods
extension InviteVC: KPLinkLabelDelagete {
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

extension InviteVC: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // You can fetch selected name and number in the following way

        // user name
        let userName:String = contact.givenName

        // user phone number
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        if !userPhoneNumbers.isEmpty {
            let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
            // user phone number string
            let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
            
            print(primaryPhoneNumberStr)
            self.dismiss(animated: true) {
                if !primaryPhoneNumberStr.isEmpty {
                    let website = "Website: https://hbcucrypto.com/"
                    let applink = "App link: https://apps.apple.com/us/app/hbcu-crypto/id1576103910"
                    let sms: String = "sms:\(primaryPhoneNumberStr)&body=Here is my invitation code for HBCU: \(YZApp.shared.objLogInUser!.invitationCode) \n \(applink) \n \(website)"
                    let strURL: String = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    UIApplication.shared.open(URL.init(string: strURL)!, options: [:], completionHandler: nil)
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {

    }
}
