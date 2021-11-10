//
//  LabelTVC.swift
//  BeeApp
//
//  Created by iOSDev on 22/04/21.
//

import UIKit

class TeamLabelTVC: YZParentTVC {

    @IBOutlet weak var lblTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func prepareUI(_ attri: NSAttributedString) {
        lblTxt.attributedText = attri
    }
}
