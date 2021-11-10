//
//  TeamEarningVC.swift
//  BeeApp
//
//  Created by iOSDev on 20/04/21.
//

import UIKit

class EarningsModel {
    var availableBalance: Double
    var totalActiveMining: Int
    var totalInactiveMining: Int
    var totalInvited: Int
    var totalTeamMember: Int
    var totalEarnings: String
    var parentUser: ParentUser?
    
    
    init(dict: NSDictionary) {
        let arrParentUser = dict["parent_user"] as! [NSDictionary]
        for userDict in arrParentUser {
            parentUser = ParentUser(dict: userDict)
        }
        self.availableBalance = dict["avail_balance"] as? Double ?? 0
        self.totalActiveMining = dict.getIntValue(forKey: "total_active_mining")
        self.totalInactiveMining = dict.getIntValue(forKey: "total_inactive_mining")
        self.totalInvited = dict.getIntValue(forKey: "total_invited")
        self.totalTeamMember = dict.getIntValue(forKey: "total_team_member")
        self.totalEarnings = dict.getStringValue(forKey: "total_earning")
    }
}

class ParentUser {
    var id :String
    var userName :String
    var firstName :String
    var lastName :String
    var imageUrlStr :String
    var invitationCode :String
    var nationality :String
    var isAmerican :String
    var parentId :Double
    var isStartMining :Bool
    
    var imageURL: URL? {
        return URL(string: imageUrlStr)
    }
    
    init(dict: NSDictionary) {
        self.id = dict.getStringValue(forKey: "id")
        self.userName = dict.getStringValue(forKey: "username")
        self.firstName = dict.getStringValue(forKey: "first_name")
        self.lastName = dict.getStringValue(forKey: "last_name")
        self.imageUrlStr = dict.getStringValue(forKey: "avtar")
        self.invitationCode = dict.getStringValue(forKey: "invitation_code")
        self.nationality = dict.getStringValue(forKey: "nationality")
        self.isAmerican = dict.getStringValue(forKey: "is_african_american")
        self.parentId = dict.getDoubleValue(forKey: "parent_id")
        self.isStartMining = dict.getBooleanValue(forKey: "is_start_mining")
    }
}


class TeamEarningVC: YZParentVC {
    @IBOutlet weak var navTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    var arr = [["u_team_has","Community member(s)"], ["currently_mining","0 active member(s)"]]

    var earningsModel: EarningsModel!
    var isHiddenBackButton: Bool = true
    
    var selectedMenuIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        showCentralNVActivity()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navTitle.text = YZApp.shared.objMiningModel?.balanceToShow ?? "0"
        getTeamEarnings()
    }
}

//MARK: Init
extension TeamEarningVC {
    func prepareUIs() {
        registerNIB()
        tableView.tableHeaderView?.backgroundColor = .clear
        
        btnBack.isHidden = isHiddenBackButton
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackAfterTimerStart),
            name: nTimeCallBack,
            object: nil)
    }
    
    @objc private func callBackAfterTimerStart(notification: NSNotification){
        guard let _ = YZApp.shared.objMiningModel else { return }
        self.navTitle.text = YZApp.shared.objMiningModel!.balanceToShow
    }
    
    func registerNIB() {
        tableView.register(SegmentHFV.nib, forHeaderFooterViewReuseIdentifier: SegmentHFV.identifier)
        tableView.register(TwoRowTVC.nib, forCellReuseIdentifier: TwoRowTVC.identifier)
        tableView.register(TeamMemberTVC.nib, forCellReuseIdentifier: TeamMemberTVC.identifier)
        tableView.register(PingTVC.nib, forCellReuseIdentifier: PingTVC.identifier)
        tableView.register(SecurityCircleTVC.nib, forCellReuseIdentifier: SecurityCircleTVC.identifier)
        tableView.register(NextPhaseTVC.nib, forCellReuseIdentifier: NextPhaseTVC.identifier)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension TeamEarningVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedMenuIndex == 0 {
            return section == 0 ? 2 : 2
        } else {
            return section == 0 ? 1 : 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let HFV = tableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentHFV.identifier) as! SegmentHFV
            HFV.prepareTitles(["earning_team", "security_crircle"])
            HFV.selectedSegment = selectedMenuIndex
            HFV.delegate = self
            return HFV
        } else {
            let view =  UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            view.backgroundColor = .clear
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 61 : 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedMenuIndex == 0 {
            if indexPath.section == 0 {
                return 80
            } else {
                if indexPath.row == 0 {
                    return 80
                } else {
                    return 60
                }
            }
        } else {
            return indexPath.section == 0 ? 205 : 140
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedMenuIndex == 0 {
            if indexPath.section == 0 {
                return tableView.dequeueReusableCell(withIdentifier: TwoRowTVC.identifier, for: indexPath)
            } else {
                if indexPath.row == 0 {
                    return tableView.dequeueReusableCell(withIdentifier: TeamMemberTVC.identifier, for: indexPath)
                } else {
                    return tableView.dequeueReusableCell(withIdentifier: PingTVC.identifier, for: indexPath)
                }
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: indexPath.section == 0 ? SecurityCircleTVC.identifier : NextPhaseTVC.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is TwoRowTVC {
            let cellTwoRow = cell as! TwoRowTVC
            cellTwoRow.prepareUIs(arr[indexPath.row], leftFont: [UIFont.robotoBold(ofSize: 18), UIFont.roboto(ofSize: 14)], leftColors: [UIColor.app4D4D4D, UIColor.appC48A31])
            cellTwoRow.layoutIfNeeded()
            if indexPath.row == 1 {
                cellTwoRow.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            } else {
                cellTwoRow.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 0, height: 0), fillColor: UIColor.white)
            }
        } else if cell is TeamMemberTVC {
            let cellMember = cell as! TeamMemberTVC
            cellMember.layoutIfNeeded()
            cellMember.backgroundColor = .clear
            cellMember.contentView.backgroundColor = .clear
            cellMember.contentView.addCornerRadiusBy([.topLeft,.topRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            
            if let parentUserModel = earningsModel?.parentUser {
                cellMember.lblName.text = "\(parentUserModel.firstName) \(parentUserModel.lastName)"
                cellMember.lblUserName.text = "@\(parentUserModel.userName.prefix(3))*******"
                cellMember.imgMain.setImageWith(parentUserModel.imageURL, placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
            }
        }  else if cell is PingTVC {
            let cellPing = cell as! PingTVC
            cellPing.parentVC = self
            cellPing.layoutIfNeeded()
            cellPing.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            if let parentUserModel = earningsModel?.parentUser {
                cellPing.lblActive.text = "\(parentUserModel.isStartMining ? "Active" : "Inactive") - Referred you"
            }
        } else if cell is SecurityCircleTVC {
            let cellSecurity = cell as! SecurityCircleTVC
            cellSecurity.layoutIfNeeded()
            cellSecurity.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
        }
    }
    
}

extension TeamEarningVC: YZUserTapDelegate {
    func didTapOn(_ text: String, headerFooter: YZParentHFV?, anyObject: Any?) {
        if text == "1" {
            YZValidationToast.shared.showToastOnStatusBar("Coming soon...")
//            selectedMenuIndex = 1
        } else {
            selectedMenuIndex = 0
        }
        reloadTableView()
    }
}

extension TeamEarningVC {
    
    func getTeamEarnings() {
       
        YZAPI.call.getTeamEarnings(["user_id":YZApp.shared.objLogInUser!.id]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            weakSelf.earningsModel = EarningsModel(dict: dataDict)
                            weakSelf.arr = [ ["u_team_has","\(weakSelf.earningsModel.totalTeamMember) Community member(s)"], ["currently_mining","\(weakSelf.earningsModel.totalActiveMining) active member(s)"]]
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    weakSelf.tableView.reloadData()
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
            }
        }
    }
    
    func sendNotificationOnPing() {
        guard let parentId = earningsModel?.parentUser?.id else { return }
        showCentralNVActivity()
        YZAPI.call.sendNotificationOnPing(["user_id": parentId]) {[weak self](anyObject, statusCode) in
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
