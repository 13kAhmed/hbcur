//
//  TeamMemberTVC.swift
//  BeeApp
//
//  Created by iOSDev on 20/04/21.
//

import UIKit

class TeamMemberTVC: YZParentTVC {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgMain: UIImageView!
    
    var teamModel: TeamModel? {
        didSet {
            setData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData() {
        guard let model = teamModel else { return }
        lblName.text = model.fullName
        if model.isParent {
            lblUserName.text = "Guide"
            lblUserName.textColor = UIColor.init("#C48A31")
        } else {
            lblUserName.text = ""
        }
        
        imgMain.setImageWith(model.imageURL, placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
    }
    
    func prepareUIs(fonts: [UIFont], colors: [UIColor]) {
        lblName.font = fonts.first
        lblUserName.font = fonts.last
        
        lblName.textColor = colors.first
        lblUserName.textColor = colors.last
    }
}
