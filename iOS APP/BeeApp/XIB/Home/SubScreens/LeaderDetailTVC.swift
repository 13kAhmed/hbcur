//
//  LeaderDetailTVC.swift
//  BeeApp
//
//  Created by iOSDev on 22/04/21.
//

import UIKit

class LeaderDetailTVC: YZParentTVC {

    @IBOutlet weak var lblActive: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblInActive: UILabel!
    @IBOutlet weak var lblVisioner: UILabel!
    @IBOutlet weak var lblMember: UILabel!
    
    weak var parentVC: TeamViewVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData() {
        guard let miningModel = parentVC.model else { return }
        lblActive.text = "Active (\(miningModel.totalActiveMining))"
        lblInActive.text = "Inactive (\(miningModel.totalInactiveMining))"
        lblVisioner.text = "\((miningModel.totalInvited)) Community member(s)"
        lblMember.text = "\(miningModel.totalTeamMember) member(s)"
        lblPrice.text = "\(miningModel.parentRate)/hr"
    }
    
    @IBAction func btnInvitePressed(_ sender: UIButton) {
        parentVC.performSegue(withIdentifier: "showInviteSegue", sender: nil)
    }
    
    @IBAction func btnViewTeamPressed(_ sender: UIButton) {
        parentVC.performSegue(withIdentifier: "showTeamEarnings", sender: nil)
    }
    
    @IBAction func btnPingPressed(_ sender: UIButton) {
        parentVC.sendNotificationOnPing()
    }
}
