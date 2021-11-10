//
//  ProfileVC.swift
//  BeeApp
//
//  Created by Harshad-M007 on 22/04/21.
//

import Foundation
import UIKit
import SafariServices

//ProfileCellsWithIcon
enum EnumForProfileCells {
    case startInviting, socialMediaCell, accountInfo,googleVerified, about, appleVerified, fbVerified, phoneVerified, whitePaper, faq, contact, logout, username, invitationCode
    
    var cellIdentifier: String {
        switch self {
        case .startInviting:
            return "StartInvitingCell"
        case .socialMediaCell:
            return "SocialMediaCell"
        case .accountInfo, .about:
            return TitleHeaderTVC.identifier
        case .appleVerified, .fbVerified, .phoneVerified, .whitePaper, .faq, .contact, .logout, .googleVerified:
            return ProfileCellsWithIcon.identifier
        case .username, .invitationCode:
            return ProfileCellsWithNumber.identifier
        default:
            return ""
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .startInviting:
            return 95
        case .socialMediaCell:
            return 124
        case .accountInfo, .about:
            return 79
        case .appleVerified, .fbVerified, .phoneVerified, .whitePaper, .faq, .contact, .logout, .username, .invitationCode, .googleVerified:
            return 72
        default:
            return 0
        }
    }
    
    var titleText: String {
        switch self {
        case .accountInfo:
            return  "Account Info"
        case .about:
            return "About"
        case .startInviting:
            return ""
        case .socialMediaCell:
            return ""
        case .googleVerified:
            return "Google Verified"
        case .appleVerified:
            return "Apple Verified"
        case .fbVerified:
            return "Facebook Verified"
        case .phoneVerified:
            return "Phone Verified"
        case .whitePaper:
            return "White Paper"
        case .faq:
            return "FAQ"
        case .contact:
            return "Contact"
        case .logout:
            return "Logout"
        case .username:
            return "Username"
        case .invitationCode:
            return "Invitation Code"
        }
    }
    
    var iconName: String {
        switch self {
        case .whitePaper:
            return "iconPhoneBook"
        case .faq:
            return "iconFaq"
        case .contact:
            return "iconCallContact"
        case .logout:
            return "iconLogout"
        default:
            return ""
        }
    }
    
}

class ProfileVC: YZParentVC {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    var arrCells: [EnumForProfileCells] = [.startInviting, .socialMediaCell, .accountInfo,.username, .invitationCode, .googleVerified, .fbVerified,.appleVerified, .phoneVerified, .about, .whitePaper, .faq, .contact, .logout]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        registerNIB()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUI()
    }
}

extension ProfileVC {
    
    func prepareUI() {
        lblName.text = YZApp.shared.objLogInUser?.fullName
        lblUserName.text = YZApp.shared.objLogInUser?.userName
        imgUser.setImageWith(URL(string: YZApp.shared.objLogInUser!.imageUrl), placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
    }
    
    func registerNIB() {
        
    }
}

//MARK: UIActions
extension ProfileVC {
    @IBAction func btnEditProfilePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showEditProfileSegue", sender: nil)
    }
    
    @IBAction func btnFBPressed(_ sender: UIButton) {
        if let url = URL(string: "https://www.facebook.com/HBCU-Crypto-107240228282653"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnTwitterPressed(_ sender: UIButton) {
        if let url = URL(string: "https://twitter.com/CryptoHbcu"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnInstaPressed(_ sender: UIButton) {
        if let url = URL(string: "https://www.instagram.com/hbcucrypto"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func btnYoutoubePressed(_ sender: UIButton) {
        if let url = URL(string: "https://www.youtube.com/channel/UCW6J58vGprzh0OCpkhM2ryQ"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellIdentifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ProfileCellsWithIcon {
            cell.bgView.layoutIfNeeded()
            cell.bgView.backgroundColor = .clear
            cell.cellType = arrCells[indexPath.row]
        }
        
        if let cell = cell as? ProfileCellsWithNumber {
            cell.cellType = arrCells[indexPath.row]
        }
        
        if let cell = cell as? TitleHeaderTVC {
            cell.bgView.layoutIfNeeded()
            cell.bgView.backgroundColor = .clear
            cell.cellType = arrCells[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if arrCells[indexPath.row] == .faq {
            if let url = URL(string: "https://hbcucrypto.com/faq.html") {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        } else if arrCells[indexPath.row] == .whitePaper {
            if let url = URL(string: "https://hbcucrypto.com/White-paper.html") {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        }
        
        if arrCells[indexPath.row] == .logout {
            UIAlertController.show(title: _appName, message: YZApp.shared.getLocalizedText("logout_alert"), style: .actionSheet, buttons: [YZApp.shared.getLocalizedText("log_out"), YZApp.shared.getLocalizedText("cancel")], controller: self) { (tapped) in
                if tapped == YZApp.shared.getLocalizedText("log_out") {
                    self.logoutAPI()
                }
            }
        } else if arrCells[indexPath.row] == .startInviting {
            performSegue(withIdentifier: "showInviteScreen", sender: nil)
        } else if arrCells[indexPath.row] == .contact {
            let email = "admin@hbcucrypto.com"
            if let url = URL(string: "mailto:\(email)") {
              if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
              } else {
                UIApplication.shared.openURL(url)
              }
            }
        }
    }
}

// MARK: - Api calls
extension ProfileVC {
    
    func logoutAPI() {
        showCentralNVActivity()
        YZAPI.call.logout(["user_id": YZApp.shared.objLogInUser!.id,"device_token": YZApp.shared.getAPNSDeviceToken() ?? ""]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        _appDelegate.logout()
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                }
                weakSelf.hideCentralNVActivity()
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
            }
        }
    }
}
