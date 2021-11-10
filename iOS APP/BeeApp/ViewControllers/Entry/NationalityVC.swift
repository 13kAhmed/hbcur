//
//  NationalityVC.swift
//  BeeApp
//
//  Created by iOSDev on 23/04/21.
//

import UIKit

class NationalityVC: YZParentVC {
    
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfInvitationCode: UITextField!
    @IBOutlet weak var lblDoSupport: UILabel!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var txtNationality: YZPickerTF!
    @IBOutlet weak var nationalityView: UIView!
    @IBOutlet weak var btnYesAlumni: UIButton!
    @IBOutlet weak var btnNoAlumni: UIButton!
    
    @IBOutlet weak var vwFname: UIView!
    @IBOutlet weak var vwLname: UIView!
    @IBOutlet weak var seperatorFirst: UILabel!
    @IBOutlet weak var seperatorSecond: UILabel!
    
    var countryCode = ""
    var mobileNumber = ""
    var socialUser: SocialUser!
    var isAlumni: Bool = false
    var arrCountry: [CountryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCountryList()
        btnYesAlumni.backgroundColor = UIColor.white
        btnNoAlumni.backgroundColor = UIColor.init("C48A31")
        if socialUser != nil {
            tfFirstName.text = socialUser.fName
            tfLastName.text = socialUser.lName
            vwFname.isHidden = true
            vwLname.isHidden = true
            seperatorFirst.isHidden = true
            seperatorSecond.isHidden = true
        }
    }
}

//MARK: Actions
extension NationalityVC {
    @IBAction func btnCheckMarkPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
//        nationalityView.isHidden = sender.isSelected
    }
    
    @IBAction func btnYesPressed(_ sender: UIButton) {
        btnYes.backgroundColor = UIColor.init("C48A31")
        btnNo.backgroundColor = UIColor.white
    }
    
    @IBAction func btnNoPressed(_ sender: UIButton) {
        btnYes.backgroundColor = UIColor.white
        btnNo.backgroundColor = UIColor.init("C48A31")
    }
    
    @IBAction func btnYesAluminyPressed(_ sender: UIButton) {
        btnYesAlumni.backgroundColor = UIColor.init("C48A31")
        btnNoAlumni.backgroundColor = UIColor.white
        isAlumni = true
    }
    
    @IBAction func btnNoAluminyPressed(_ sender: UIButton) {
        btnYesAlumni.backgroundColor = UIColor.white
        btnNoAlumni.backgroundColor = UIColor.init("C48A31")
        isAlumni = false
    }
    
    @IBAction func btnProccedPressed(_ sender: UIButton) {
        if tfFirstName.text!.trimmedString.isEmpty {
            YZValidationToast.shared.showToastOnStatusBar("Please enter first name..")
        } else if tfLastName.text!.trimmedString.isEmpty {
            YZValidationToast.shared.showToastOnStatusBar("Please enter last name..")
        } else if tfInvitationCode.text!.trimmedString.isEmpty {
            YZValidationToast.shared.showToastOnStatusBar("Please enter invitation code..")
        } else if txtNationality.text!.trimmedString.isEmpty {
            YZValidationToast.shared.showToastOnStatusBar("Please choose nationality..")
        } else {
            if socialUser != nil {
                signInUsingSocial()
            } else {
                signUpUsingMobile()
            }
        }
    }
}


//MARK: - API call
extension NationalityVC {
    //    func signInUsing() {
    //        var param: [String: Any] = [:]
    //        param["signup_type"] = "1"
    //        param["mobile"] = "mobile"
    //        param["country_code"] = countryCode
    //        param["first_name"] = "iOS"
    //        param["last_name"] = "1"
    //        param["nationality"] = "1"
    //
    //        YZAPI.call.signIn(param) {[weak self](anyObject, statusCode) in
    //            guard let weakSelf = self else{return}
    //            if statusCode == 200 {
    //                weakSelf.hideIndicatorFromCenter()
    //                if let dictJSON = anyObject as? NSDictionary {
    //                    let statusCode = dictJSON.getIntValue(forKey: "status")
    //                    if statusCode == 200  {
    //                        if let dataDict = dictJSON["data"] as? NSDictionary {
    //                            if let userDict = dataDict["user"] as? NSDictionary {
    //                                YZApp.shared.setUserDetails(userDict)//Store user details to CoreData.
    //                                _appDelegate.navigateToUserTabBar(false)
    //                            }
    //                        }
    //                    } else {
    //                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
    //                    }
    //                }
    //            }else{
    //                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
    //                weakSelf.hideIndicatorFromCenter()
    //            }
    //        }
    //    }
}

// MARK: - Api calls
extension NationalityVC {
    
    func signInUsingSocial() {
        socialUser.fName = tfFirstName.text!.trimmedString
        socialUser.lName = tfLastName.text!.trimmedString
        socialUser.invitationCode = tfInvitationCode.text!.trimmedString
        socialUser.nationality = txtNationality.text!.trimmedString
        socialUser.isAfricanAmerican = btnCheckBox.isSelected
        socialUser.isAlumni = isAlumni
        
        self.showCentralNVActivity()
        YZAPI.call.authorizedUsing(socialUser) {[weak self](anyObject, statusCode) in
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
    
    func signUpUsingMobile() {
        showCentralNVActivity()
        YZAPI.call.signUp(["signup_type": "1", "mobile" : mobileNumber, "country_code": countryCode, "device_type": "iOS", "fcm_token":YZApp.shared.getAPNSDeviceToken() ?? "", "device_token": YZApp.shared.getAPNSDeviceToken() ?? "", "first_name": tfFirstName.text!.trimmedString, "last_name": tfLastName.text!.trimmedString, "invitation_code": tfInvitationCode.text!.trimmedString, "nationality": txtNationality.text!.trimmedString, "is_african_american": btnCheckBox.isSelected ? "1" : "0","is_hbcu_alumni": isAlumni ? "Yes" : "No"]) {[weak self](anyObject, statusCode) in
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
    
    func getCountryList() {
        showCentralNVActivity()
        YZAPI.call.getMetaData(["":""]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            weakSelf.arrCountry = []
                            if let arrCountry = dataDict["countrys"] as? [NSDictionary] {
                                for countryDict in arrCountry {
                                    weakSelf.arrCountry.append(CountryModel(dict: countryDict))
                                }
                            }
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    weakSelf.txtNationality.setPicker(weakSelf.arrCountry.map({$0.name}), autoCompleted: true) { item, index, rowIndex, isDone in
                        weakSelf.txtNationality.text = item as? String
                    }
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
            }
        }
    }
}
