//
//  TeamViewVC.swift
//  BeeApp
//
//  Created by iOSDev on 22/04/21.
//

import UIKit
import SafariServices

class TeamViewVC: YZParentVC {

    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var lblPriceRate: UILabel!
    @IBOutlet weak var lblLearnMore: KPLinkLabel!
    
    var model: MiningModel!
    var expandedSections:[Int] = [0]
    var sectionTitles = ["Community member","Guide","Verifier"]
    
    var termText: NSAttributedString {
        let attriString = NSMutableAttributedString()
        attriString.append(NSAttributedString(string:"Learn More About Each Role", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.robotoMedium(ofSize: 14), NSAttributedString.Key.underlineStyle: 1, NSAttributedString.Key.attachment : "learnmore"]))
        
        return attriString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        getMiningDetail()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let vc = segue.destination as? TeamEarningVC {
            vc.isHiddenBackButton = false
        }
    }
}

extension TeamViewVC {
    func prepareUIs() {
        lblLearnMore.setTagText(attriText: termText, linebreak: .byTruncatingTail)
        lblLearnMore.delegate = self
        registerNIB()
        lblPriceRate.text = "\(YZApp.shared.objMiningModel?.ratePerHours ?? 0.0)/hr"
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackAfterTimerStart),
            name: nTimeCallBack,
            object: nil)
    }
    
    @objc private func callBackAfterTimerStart(notification: NSNotification){
        guard let _ = YZApp.shared.objMiningModel else { return }
        self.navTitle.text = YZApp.shared.objMiningModel!.balanceToShow
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TeamLabelTVC {
            cell.prepareUI(NSAttributedString.attributedText(texts: ["Current mining session ends in ", YZApp.shared.objMiningModel!.remainingTimeToShow], attributes: [[NSAttributedString.Key.font : UIFont.roboto(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.app4D4D4D], [NSAttributedString.Key.font : UIFont.robotoMedium(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.appC48A31]]))
        }
    }
    
    func registerNIB() {
        tableView.register(TeamProgressTVC.nib, forCellReuseIdentifier: TeamProgressTVC.identifier)
        tableView.register(TeamLabelTVC.nib, forCellReuseIdentifier: TeamLabelTVC.identifier)
        tableView.register(LeaderDetailTVC.nib, forCellReuseIdentifier: LeaderDetailTVC.identifier)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension TeamViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 76
        } else if expandedSections.contains(indexPath.section) {
            if indexPath.section == 0 {
                return 100
            }else if indexPath.section == 1 {
                return 370
            } else {
                return 150
            }
        }
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TeamProgressTVC.identifier, for: indexPath)
        } else {
            if indexPath.section == 0 || indexPath.section == 2 {
                return tableView.dequeueReusableCell(withIdentifier: TeamLabelTVC.identifier, for: indexPath)
            }
            return tableView.dequeueReusableCell(withIdentifier: LeaderDetailTVC.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedSections.contains(indexPath.section) {
            expandedSections.remove(indexPath.section)
        } else {
            expandedSections.append(indexPath.section)
        }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is TeamProgressTVC {
            let cellTeamHeader = cell as! TeamProgressTVC
            cellTeamHeader.lblTitle.text = YZApp.shared.getLocalizedText(sectionTitles[indexPath.section])
            if let miningModel = YZApp.shared.objMiningModel {
                if indexPath.section == 0 {
                    cellTeamHeader.lblPrice.text = "\(miningModel.userRate)/hr"
                } else if indexPath.section == 1 {
                    cellTeamHeader.lblPrice.text = "\(miningModel.parentRate)/hr"
                } else {
                    cellTeamHeader.lblPrice.text = "0.0/hr"
                }
            }
            
            cellTeamHeader.layoutIfNeeded()
            if expandedSections.contains(indexPath.section) {
                cellTeamHeader.imgVArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                cellTeamHeader.viewContainer?.addCornerRadiusBy([.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            } else {
                cellTeamHeader.imgVArrow.transform = CGAffineTransform(rotationAngle: 0)
                cellTeamHeader.viewContainer?.addCornerRadiusBy([.allCorners], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            }
        } else if cell is TeamLabelTVC {
            let cellLabel = cell as! TeamLabelTVC
            cellLabel.layoutIfNeeded()
            if indexPath.section == 0 {
                cellLabel.prepareUI(NSAttributedString.attributedText(texts: ["Current mining session ends in ", "20:30:40"], attributes: [[NSAttributedString.Key.font : UIFont.roboto(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.app4D4D4D], [NSAttributedString.Key.font : UIFont.robotoMedium(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.appC48A31]]))
            } else {
                cellLabel.prepareUI(NSAttributedString.attributedText(texts: ["Security circle features will  be launched in the next phase."], attributes: [[NSAttributedString.Key.font : UIFont.roboto(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.app4D4D4D]]))
            }
            cellLabel.viewContainer?.addCornerRadiusBy([.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
        } else if cell is LeaderDetailTVC {
            let cellLabel = cell as! LeaderDetailTVC
            cellLabel.layoutIfNeeded()
            cellLabel.parentVC = self
            cellLabel.setData()
            cellLabel.viewContainer?.addCornerRadiusBy([.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
        }
    }
}

// MARK: - Api calls
extension TeamViewVC {
    
    func getMiningDetail() {
        showCentralNVActivity()
        YZAPI.call.getMiningDetail(["user_id": YZApp.shared.objLogInUser!.id]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            weakSelf.model = MiningModel(dict: dataDict)
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

extension TeamViewVC {
    func sendNotificationOnPing() {
        showCentralNVActivity()
        YZAPI.call.sendNotificationToInactiveUser(["user_id": YZApp.shared.objLogInUser!.id]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.hideCentralNVActivity()
            if statusCode == 200 {
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .success)
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

// MARK: - Terms and condition delegate methods
extension TeamViewVC: KPLinkLabelDelagete {
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: KPLinkLabel) {
        if tagName == "learnmore" {
            if let url = URL(string: "https://hbcucrypto.com/White-paper.html") {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true, completion: nil)
            }
        }
    }
    
    func tapOnEmpty(index: IndexPath?) {}
}
