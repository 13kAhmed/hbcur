//
//  NationalityVC.swift
//  BeeApp
//
//  Created by iOSDev on 23/04/21.
//

import UIKit
import Photos

class EditProfileVC: YZParentVC {
    
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var imgUser: UIImageView!
    var imageData: UIImage?
    var objImagePicker: YZImagePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfFirstName.text = YZApp.shared.objLogInUser?.firstName
        tfLastName.text = YZApp.shared.objLogInUser?.lastName
        objImagePicker = YZImagePicker(self, delegate: self, imagePickerConfig: YZImagePickerConfig(.square))
        imgUser.setImageWith(URL(string: YZApp.shared.objLogInUser!.imageUrl), placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
    }
    
}

//MARK: Actions
extension EditProfileVC {
    @IBAction func btnUpdatePressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if tfFirstName.text!.trimmedString.isEmpty {
            YZValidationToast.shared.showToastOnStatusBar("Please enter first name..")
        } else if tfLastName.text!.trimmedString.isEmpty {
            YZValidationToast.shared.showToastOnStatusBar("Please enter last name..")
        } else {
            updateProfile()
        }
    }
    
    @IBAction func btnCameraPressed(_ sender: UIButton) {
        UIAlertController.show(title: nil, message: nil, style: .actionSheet, buttons: [
            "Take a photo",
            "Gallery",
            "Cancel"
        ] , controller: self) {[weak self](tappedString) in
            guard let weakSelf = self else{return}
            if tappedString == "Take a photo" {
                weakSelf.objImagePicker!.takePhoto()
            } else if tappedString == "Gallery" {
                weakSelf.objImagePicker!.chooseFromLibrary()
            }
        }
    }
}

//MARK: YZImagePickerDelegate
extension EditProfileVC: YZImagePickerDelegate {
    
    func imagePickerDidSelected(image: UIImage?, anyObject: Any?) {
        if image != nil {
            imgUser.image =  image
            imageData = image
        }
    }
    
    func imagePickerPermissionDidChanged(status: Int, isGranted: Bool, anyObject: Any?) {
        if (PHAuthorizationStatus.denied.rawValue == status || PHAuthorizationStatus.restricted.rawValue == status) && isGranted == false {
            YZValidationToast.shared.showToastOnStatusBar("You have denied access permission. Please allow access from Settings->HBCU", color: UIColor.TOASTERROR!)
        }
    }
}

// MARK: - Api calls
extension EditProfileVC {
    
    func updateProfile() {
        self.showCentralNVActivity()
        YZAPI.call.updateProfile(imageData?.jpegData(compressionQuality: 0.9),["user_id": YZApp.shared.objLogInUser!.id, "first_name": tfFirstName.text!.trimmedString, "last_name": tfLastName.text!.trimmedString]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else{return}
            weakSelf.hideCentralNVActivity()
            if statusCode == 200 {
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            if let userDict = dataDict["user"] as? NSDictionary {
                                YZApp.shared.setUserDetails(userDict)//Store user details to CoreData.
                                YZAPI.call.showAPIMessage(anyObject, messageFor: .success)
                                weakSelf.navigationController?.popViewController(animated: true)
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
}
