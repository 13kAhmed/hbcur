//
//  TitleHeaderTVC.swift
//  BeeApp
//
//  Created by Harshad-M007 on 22/04/21.
//

import Foundation
import UIKit

class TitleHeaderTVC: YZParentTVC {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var cellType: EnumForProfileCells? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        guard let type = cellType else { return }
        lblTitle.text = type.titleText
        bgView.addCornerRadiusBy([.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20), fillColor: .white)
    }
    
}



class ProfileCellsWithIcon: YZParentTVC {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var imgRoudError: UIImageView!
    
    var cellType: EnumForProfileCells? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        guard let type = cellType else { return }
        lblTitle.text = type.titleText
        imgIcon.image = UIImage(named: type.iconName)
        imgIcon.isHidden = false
        imgRoudError.isHidden = false
        imgArrow.isHidden = false
        
        switch type {
        case .appleVerified, .fbVerified, .phoneVerified, .googleVerified:
            imgIcon.isHidden = true
            imgArrow.isHidden = true
        case .whitePaper, .faq, .contact:
            imgRoudError.isHidden = true
        case .logout:
            imgRoudError.isHidden = true
            imgArrow.isHidden = true
        default:
            break
        }
        
        if type == .logout || type == .phoneVerified {
            bgView.addCornerRadiusBy([.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20, height: 20), fillColor: .white)
        } else {
            bgView.addCornerRadiusBy([.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 0, height: 0), fillColor: .white)
        }
        
        if type == .phoneVerified {
            imgRoudError.image = YZApp.shared.objLogInUser!.signupType == "1" ? UIImage(named: "iconCorrect") : UIImage(named: "iconMissing")
        } else if type == .appleVerified {
            imgRoudError.image = YZApp.shared.objLogInUser!.signupType == "4" ? UIImage(named: "iconCorrect") : UIImage(named: "iconMissing")
        } else if type == .fbVerified {
            imgRoudError.image = YZApp.shared.objLogInUser!.signupType == "2" ? UIImage(named: "iconCorrect") : UIImage(named: "iconMissing")
        }else if type == .googleVerified {
            imgRoudError.image = YZApp.shared.objLogInUser!.signupType == "3" ? UIImage(named: "iconCorrect") : UIImage(named: "iconMissing")
        }
    }
    
}



class ProfileCellsWithNumber: YZParentTVC {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    
    var cellType: EnumForProfileCells? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        guard let type = cellType else { return }
        lblTitle.text = type.titleText
        if type == .username {
            lblNumber.text = YZApp.shared.objLogInUser?.userName
        } else if type == .invitationCode {
            lblNumber.text = YZApp.shared.objLogInUser?.invitationCode
        }
    }
    
}
