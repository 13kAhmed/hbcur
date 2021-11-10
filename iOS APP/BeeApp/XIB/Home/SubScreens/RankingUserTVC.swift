//
//  RankingUserTVC.swift
//  BeeApp
//
//  Created by iOSDev on 21/04/21.
//

import UIKit

class RankingUserTVC: YZParentTVC {
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgMain: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var rankingModel: RankingModel? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        guard let model = rankingModel else { return }
        lblFullName.text = model.fullName
        lblUserName.text = model.availableBalance + " " + "HBCU"
        imgMain.setImageWith(model.imageURL, placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
    }
}
