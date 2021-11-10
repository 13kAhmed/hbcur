//
//  PingTVC.swift
//  BeeApp
//
//  Created by iOSDev on 20/04/21.
//

import UIKit

class PingTVC: YZParentTVC {

    @IBOutlet weak var lblActive: UILabel!
    weak var parentVC: TeamEarningVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btnPingPressed(_ sender: UIButton) {
        parentVC.sendNotificationOnPing()
    }
}
