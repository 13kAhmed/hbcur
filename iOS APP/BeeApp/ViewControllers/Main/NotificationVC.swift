//
//  NotificationVC.swift
//  BeeApp
//
//  Created by iOSDev on 21/04/21.
//

import UIKit

class NotificationModel {
    var id: String
    var title: String
    var message: String
    var createdDate: String
    
    var date: Date? {
        return Date.dateFromServer(createdDate)
    }

    var strDate: String {
        let str = date?.stringFromLocal("dd MMM, yyyy hh:mm a") ?? ""
        return str
    }
    
    init(dict:NSDictionary) {
        self.id = dict.getStringValue(forKey: "id")
        self.title = dict.getStringValue(forKey: "title")
        self.message = dict.getStringValue(forKey: "message")
        self.createdDate = dict.getStringValue(forKey: "created_at")
    }
}

class NotificationVC: YZParentVC {
    @IBOutlet weak var lblNavTitle: UILabel!
    var arrNotifications: [NotificationModel]!
    var objPaging: YZPagingnation = YZPagingnation(1, limit: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        getNotificationList()
        addRefreshControl()
        // Do any additional setup after loading the view.
    }
}

extension NotificationVC {
    func prepareUIs() {
        lblNavTitle.text = YZApp.shared.getLocalizedText("notification")
        registerNIB()
        tableView.tableFooterView = loadMoreActivity
        tableView.tableFooterView?.isHidden = true
    }
    
    func registerNIB() {
        tableView.register(TeamMemberTVC.nib, forCellReuseIdentifier: TeamMemberTVC.identifier)
        tableView.register(NoDataCell.nib, forCellReuseIdentifier: NoDataCell.identifier)
    }
    
    func loadMoreData(_ indexPath: IndexPath) {
        if YZAPI.call.isInternetAvailable() && objPaging.isAllLoaded == false && indexPath.row == arrNotifications.count - 1 && objPaging.isLoading == false {
            tableView.tableFooterView?.isHidden = false
            getNotificationList(nil, isIndicatorShow: false)
        }
    }
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        getNotificationList(refreshControl, isIndicatorShow: false)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotifications == nil ? 0 : arrNotifications.isEmpty ? 1 : arrNotifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrNotifications.isEmpty ? tableView.frame.size.height : 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrNotifications.isEmpty ? NoDataCell.identifier : TeamMemberTVC.identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadMoreData(indexPath)
        if let cell = cell as? NoDataCell {
            cell.lblTitle.text = "No data found!"
            cell.backgroundColor = .white
            cell.contentView.cornerRadius = 10
        }
        if cell is TeamMemberTVC {
            let cellMember = cell as! TeamMemberTVC
            let objNotify = arrNotifications[indexPath.row]
            
            cellMember.lblName.text = objNotify.message
            cellMember.lblName.numberOfLines = 2
            cellMember.imgMain.image = UIImage(named: "hbcuIcon")
            cellMember.lblUserName.text = objNotify.date?.getElapsedInterval()
            cellMember.prepareUIs(fonts: [UIFont.robotoBold(ofSize: 16), UIFont.roboto(ofSize: 14)], colors: [UIColor.app4D4D4D, UIColor.appC48A31])
            
            cellMember.layoutIfNeeded()
            cellMember.backgroundColor = .clear
            cellMember.contentView.backgroundColor = .clear
            if indexPath.row == 0 {
                cellMember.contentView.addCornerRadiusBy([.topLeft,.topRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            } else if indexPath.row == arrNotifications.count - 1 {
                cellMember.contentView.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
            } else {
                cellMember.contentView.addCornerRadiusBy([.topLeft,.topRight], cornerRadii: CGSize(width: 0, height: 0), fillColor: UIColor.white)
            }
            if arrNotifications.count == 1 {
                cellMember.contentView.cornerRadius = 10
            }
        }
    }
}

// MARK: - Api calls
extension NotificationVC {
    
    func getNotificationList(_ refreshControl: UIRefreshControl? = nil, isIndicatorShow: Bool = true) {
        if refreshControl != nil {objPaging = YZPagingnation(1, limit: 10)}

        if isIndicatorShow {self.showCentralNVActivity()}
        objPaging.isLoading = true
        
        YZAPI.call.getNotificationsList(["user_id": YZApp.shared.objLogInUser!.id, "page": "\(self.objPaging.pageNumber)"]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if weakSelf.objPaging.pageNumber == 1 {weakSelf.arrNotifications = []}
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            if let arrHistory = dataDict["notification"] as? [NSDictionary] {
                                for dictNoti in arrHistory {
                                    weakSelf.arrNotifications.append(NotificationModel(dict: dictNoti))
                                }
                            }
                            weakSelf.objPaging.isAllLoaded = weakSelf.arrNotifications.count == dataDict.getIntValue(forKey: "total")
                            weakSelf.objPaging.pageNumber = weakSelf.objPaging.isAllLoaded ? weakSelf.objPaging.pageNumber : weakSelf.objPaging.pageNumber + 1
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    weakSelf.tableView.reloadData()
                }
                weakSelf.prepareDataAfterResponse(refreshControl)
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
                weakSelf.prepareDataAfterResponse(refreshControl)
            }
        }
    }
    
    func prepareDataAfterResponse(_ refreshControl: UIRefreshControl?) {
        //Paging isLoading set to false
        objPaging.isLoading = false
        //Stop animating refreshControl
        refreshControl?.endRefreshing()
        //Reload collection view
        tableView.reloadData()
        //Set table footer view isHidden to true, if all data loaded.
        if objPaging.isAllLoaded {
            tableView.tableFooterView = nil
            tableView.tableFooterView?.isHidden = true
        }else{
            tableView.tableFooterView?.isHidden = !objPaging.isLoading
        }
    }
}
