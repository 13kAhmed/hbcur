//
//  TwoRowTVC.swift
//  BeeApp
//
//  Created by iOSDev on 20/04/21.
//

import UIKit

class TwoRowTVC: YZParentTVC {
    @IBOutlet weak var lblLeft1:UILabel!
    @IBOutlet weak var lblLeft2:UILabel!
    @IBOutlet weak var lblRight1:UILabel!
    @IBOutlet weak var lblRight2:UILabel!
    
    var selectedTab: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackAfterTimerStart),
            name: nTimeCallBack,
            object: nil)
    }
    
    @objc private func callBackAfterTimerStart(notification: NSNotification){
        guard let _ = YZApp.shared.objMiningModel else { return }
        if tag == 0 {
            self.lblRight1.text = "+"+String(format: "%.4f", ceil((YZApp.shared.objMiningModel!.valueForSpentTime)*10000)/10000)
        }
    }
    
    var transactionModel: TransactionModel? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        guard let model = transactionModel else { return }
        if selectedTab == 0 {
            lblLeft2.text = tag == 0 ? "Currently Mining" : model.strStartTimeDate
        } else {
            lblLeft2.text = model.strStartTimeDate
        }
        
        if tag != 0 {
            lblRight1.text = "+\(model.creditAmount)"
        }
        lblLeft1.text = model.type == "commission_of_mining" ? "Earned referal bonus for \(model.fullName)" : "Daily Mining"
        lblLeft2.textColor = tag == 0 ? UIColor.init("#C48A31") : UIColor.init("#4D4D4D")
//        imgMain.setImageWith(model.imageURL, placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
    }
}

extension TwoRowTVC {
    func prepareUIs(_ leftTitle:[String], leftFont:[UIFont], leftColors:[UIColor], rightTitles: [String] = [], rightFont: [UIFont] = [],  rightColors:[UIColor] = []) {
        
        lblLeft1.text = YZApp.shared.getLocalizedText(leftTitle.first!)
        lblLeft2.text = leftTitle.last
        lblLeft1.font = leftFont.first
        lblLeft2.font = leftFont.last
        lblLeft1.textColor = leftColors.first
        lblLeft2.textColor = leftColors.last
        
        if rightTitles.isEmpty {
            lblRight1.isHidden = true
            lblRight2.isHidden = true
        } else {
            lblRight1.text = rightTitles.first
            lblRight2.text = rightTitles.last
            lblRight1.font = rightFont.first
            lblRight2.font = rightFont.last
            lblRight1.textColor = rightColors.first
            lblRight2.textColor = rightColors.last

        }
    }
}
