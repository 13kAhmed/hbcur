//
//  RankingSegmentTVC.swift
//  BeeApp
//
//  Created by iOSDev on 21/04/21.
//

import UIKit

class RankingSegmentTVC: YZParentTVC {

    @IBOutlet weak var viewFirst: UIView!
    @IBOutlet weak var viewSecond: UIView!
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    @IBOutlet weak var imgVFlag: UIImageView!

    weak var delegate: YZUserTapDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareUI(0)
        // Initialization code
    }
    
    func prepareUI(_ index: Int) {
        viewFirst.backgroundColor = .white
        viewSecond.backgroundColor = .white
        lblFirst.textColor = UIColor.app2B2953
        lblSecond.textColor = UIColor.app2B2953
        if index == 0 {
            viewFirst.backgroundColor = .app2B2953
            lblFirst.textColor = UIColor.white
        } else {
            viewSecond.backgroundColor = .app2B2953
            lblSecond.textColor = UIColor.white
        }
    }
}

extension RankingSegmentTVC {
    @IBAction func onValueChange(_ sender: UIButton) {
        delegate?.didTapOn?(sender.tag.description, tableCell: self, anyObject: nil)
    }
}
