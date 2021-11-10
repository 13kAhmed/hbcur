//
//  TransactionVC.swift
//  BeeApp
//
//

import UIKit

class TransactionModel {
    var id: String = ""
    var trans_id: String = ""
    var type: String = ""
    var creditAmount: String = ""
    var debitAmount: String = ""
    var availableBalance: String = ""
    var transactionStatus: String = ""
    var transactionCreatedDate: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var spentTime: String = ""
    var status: String = ""
    var fullName: String = ""
    
    init(price: String) {
        creditAmount = price
    }
    
    var startDate: Date? {
        return Date.dateFromServer(startTime,format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }
    
    var strStartTimeDate: String {
        let str = startDate?.stringFromLocal("dd MMM, yyyy hh:mm a") ?? ""
        return str
    }
    
    init(dict:NSDictionary) {
        self.id = dict.getStringValue(forKey: "id")
        self.trans_id = dict.getStringValue(forKey: "trans_id")
        self.type = dict.getStringValue(forKey: "type")
        self.creditAmount = dict.getStringValue(forKey: "credit_amount")
        self.debitAmount = dict.getStringValue(forKey: "debit_amount")
        self.availableBalance = dict.getStringValue(forKey: "avail_balance")
        self.transactionStatus = dict.getStringValue(forKey: "trans_status")
        self.transactionCreatedDate = dict.getStringValue(forKey: "trans_created")
        self.startTime = dict.getStringValue(forKey: "start_time")
        self.endTime = dict.getStringValue(forKey: "end_time")
        self.spentTime = dict.getStringValue(forKey: "spent_time")
        self.status = dict.getStringValue(forKey: "status")
        self.fullName = dict.getStringValue(forKey: "full_name")
    }
}

class TransactionVC: YZParentVC {
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var lblTotalBalance: UILabel!
    var arrTransactions: [TransactionModel]!
    var arrFirstTabTransaction: [TransactionModel] = []
    var arrSecondTabTransaction: [TransactionModel] = []
    
    var objPaging: YZPagingnation = YZPagingnation(1, limit: 10)
    var selectedTab: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        objPaging = YZPagingnation(1, limit: 10)
//        showCentralNVActivity()
//        prepareSocket()
//        YZApp.shared.socketManager?.send(event: .getMiningTransactionHistory, param: ["user_id": YZApp.shared.objLogInUser!.id])
        getMiningTransactionHistory()
    }
}

//MARK: Init
extension TransactionVC {
    func prepareUIs() {
        lblNavTitle.text = YZApp.shared.getLocalizedText("tansactions")
        registerNIB()
        addRefreshControl()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackAfterTimerStart),
            name: nTimeCallBack,
            object: nil)
        self.lblTotalBalance.text = YZApp.shared.objMiningModel?.balanceToShow ?? "0"
    }
    
    @objc private func callBackAfterTimerStart(notification: NSNotification){
        guard let _ = YZApp.shared.objMiningModel else { return }
        self.lblTotalBalance.text = YZApp.shared.objMiningModel!.balanceToShow
    }
    
    func registerNIB() {
        tableView.register(TwoRowTVC.nib, forCellReuseIdentifier: TwoRowTVC.identifier)
        tableView.register(NoDataCell.nib, forCellReuseIdentifier: NoDataCell.identifier)
        tableView.register(SegmentHFV.nib, forHeaderFooterViewReuseIdentifier: SegmentHFV.identifier)
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        getMiningTransactionHistory(refreshControl, isIndicatorShow: false)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension TransactionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedTab == 0 {
            return arrTransactions == nil ? 0 : arrFirstTabTransaction.isEmpty ? 1 : arrFirstTabTransaction.count
        } else {
            return arrTransactions == nil ? 0 : arrSecondTabTransaction.isEmpty ? 1 : arrSecondTabTransaction.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedTab == 0 {
            return arrFirstTabTransaction.isEmpty ? tableView.frame.size.height : 72
        } else {
            return arrSecondTabTransaction.isEmpty ? tableView.frame.size.height : "Earned referal bonus for \(arrSecondTabTransaction[indexPath.row].fullName)".heightForFixed(YZAppConfig.width - 40, font: UIFont.robotoBold(ofSize: 18)) + 50
        }
//        return arrTransactions.isEmpty ? tableView.frame.size.height : 72
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let HFV = tableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentHFV.identifier) as! SegmentHFV
        HFV.prepareTitles(["myearning", "referalearning"])
        HFV.selectedSegment = selectedTab
        HFV.delegate = self
        return HFV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedTab == 0 {
            return tableView.dequeueReusableCell(withIdentifier: arrFirstTabTransaction.isEmpty ? NoDataCell.identifier : TwoRowTVC.identifier, for: indexPath)
//            return arrFirstTabTransaction.isEmpty ? tableView.frame.size.height : 72
        } else {
            return tableView.dequeueReusableCell(withIdentifier: arrSecondTabTransaction.isEmpty ? NoDataCell.identifier : TwoRowTVC.identifier, for: indexPath)
//            return arrSecondTabTransaction.isEmpty ? tableView.frame.size.height : 72
        }
        return tableView.dequeueReusableCell(withIdentifier: arrTransactions.isEmpty ? NoDataCell.identifier : TwoRowTVC.identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.lblTitle.text = "No data found!"
            cell.backgroundColor = .white
            cell.contentView.cornerRadius = 10
        }
        
        if let cell = cell as? TwoRowTVC {
            cell.selectedTab = selectedTab
            cell.tag = indexPath.row
            
            if selectedTab == 0 {
                cell.transactionModel = arrFirstTabTransaction[indexPath.row]
            } else {
                cell.transactionModel = arrSecondTabTransaction[indexPath.row]
            }
            cell.layoutIfNeeded()
            if selectedTab == 0 {
                if indexPath.row == arrFirstTabTransaction.count - 1 {
                    cell.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
                } else {
                    cell.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 0, height: 0), fillColor: UIColor.white)
                }
            } else {
                if indexPath.row == arrSecondTabTransaction.count - 1 {
                    cell.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10), fillColor: UIColor.white)
                } else {
                    cell.viewContainer?.addCornerRadiusBy([.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 0, height: 0), fillColor: UIColor.white)
                }
            }
//            if arrTransactions.count == 1 {
//                cell.viewContainer?.cornerRadius = 10
//                cell.viewContainer?.clipsToBounds = true
//            }
        }
    }
}

// MARK: - Api calls
extension TransactionVC {
    
    func getMiningTransactionHistory(_ refreshControl: UIRefreshControl? = nil, isIndicatorShow: Bool = true) {
        if isIndicatorShow {showCentralNVActivity()}
        if refreshControl != nil {objPaging = YZPagingnation(1, limit: 10)}
        //YZApp.shared.objLogInUser!.id
        YZAPI.call.getMiningHistory(["user_id": YZApp.shared.objLogInUser!.id,"page": objPaging.pageNumber]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
//                            if weakSelf.objPaging.pageNumber == 1 {weakSelf.arrTransactions = []}
                            weakSelf.arrTransactions = []
                            weakSelf.arrSecondTabTransaction = []
                            weakSelf.arrFirstTabTransaction = []
                            //                            weakSelf.lblTotalBalance.text = dataDict.getStringValue(forKey: "available_balance")
                            if let arrHistory = dataDict["mining_transaction_history"] as? [NSDictionary] {
                                if let _ = YZApp.shared.objMiningModel {
                                    weakSelf.arrFirstTabTransaction.append(TransactionModel(price: "0"))
                                }
                                for dictTransaction in arrHistory {
                                    let objT = TransactionModel(dict: dictTransaction)
                                    if objT.type == "commission_of_mining" {
                                        weakSelf.arrSecondTabTransaction.append(objT)
                                    } else {
                                        weakSelf.arrFirstTabTransaction.append(objT)
                                    }
                                    weakSelf.arrTransactions.append(objT)
                                }
                            }
                            weakSelf.objPaging.isAllLoaded = weakSelf.arrTransactions.count == dataDict.getIntValue(forKey: "total")
                            weakSelf.objPaging.pageNumber = weakSelf.objPaging.isAllLoaded ? weakSelf.objPaging.pageNumber : weakSelf.objPaging.pageNumber + 1
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    weakSelf.tableView.reloadData()
                    weakSelf.objPaging.isLoading = false
                    refreshControl?.endRefreshing()
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
                weakSelf.objPaging.isLoading = false
                refreshControl?.endRefreshing()
            }
        }
    }
    
//    func prepareSocket() {
//        self.lblTotalBalance.text = YZApp.shared.objMiningModel?.balanceToShow ?? "0"
//        YZApp.shared.socketManager?.listnerCall = {[weak self] (type, data) in
//            guard let weakSelf = self else { return }
//            switch type {
//            case .getMiningTransactionHistoryResponse:
//
//                if let arrdict = data as? [NSDictionary], !arrdict.isEmpty {
//                    let dictJSON = arrdict[0]
//                    let statusCode = dictJSON.getIntValue(forKey: "status")
//                    let userId = dictJSON.getStringValue(forKey: "userID")
//                    if YZApp.shared.objLogInUser!.id != userId { return }
//
//                    if statusCode == 200  {
//                        if let dataDict = dictJSON["data"] as? NSDictionary {
//                            weakSelf.arrTransactions = []
//                            if let arrHistory = dataDict["mining_transaction_history"] as? [NSDictionary] {
//                                if let _ = YZApp.shared.objMiningModel {
//                                    weakSelf.arrTransactions.append(TransactionModel(price: "0"))
//                                }
//                                for dictTransaction in arrHistory {
//                                    weakSelf.arrTransactions.append(TransactionModel(dict: dictTransaction))
//                                }
//                            }
//                        }
//                    } else {
//                        YZAPI.call.showAPIMessage(dictJSON, messageFor: .error)
//                    }
//                    weakSelf.tableView.reloadData()
//                }
//                weakSelf.refreshControl.endRefreshing()
//                weakSelf.hideCentralNVActivity()
//            default: break
//            }
//        }
//    }
    
}


//MARK: YZUserTapDelegate
extension TransactionVC: YZUserTapDelegate {

    
    func didTapOn(_ text: String, headerFooter: YZParentHFV?, anyObject: Any?) {
        if text == "1" {
            selectedTab = 1
        } else {
            selectedTab = 0
        }
        reloadTableView()
    }
}
