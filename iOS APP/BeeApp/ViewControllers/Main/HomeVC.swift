//
//  HomeVC.swift
//  BeeApp
//
//  Created by iOSDev on 19/04/21.
//

import UIKit
import KDCircularProgress
import SocketIO

class HomeVC: YZParentVC {
    @IBOutlet weak var viewCircleContainer: UIView!
    @IBOutlet weak var lblInvites: UILabel!
    @IBOutlet weak var lblInviteFrds: UILabel!
    @IBOutlet weak var lblTeam: UILabel!
    @IBOutlet weak var lblNews: UILabel!
    @IBOutlet weak var _leadingLblBar: NSLayoutConstraint!
    
    @IBOutlet weak var lblBalTxt: UILabel!
    @IBOutlet weak var lblBal: UILabel!
    @IBOutlet weak var lblPerHour: UILabel!
    @IBOutlet weak var lblRemianingTime: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnAboveBalance: UIButton!
    
    var arrNews: [NewsModel]!
    var arrTeams: [TeamModel]!
    var objPagingForTeams: YZPagingnation = YZPagingnation(1, limit: 10)
    var objPagingForNews: YZPagingnation = YZPagingnation(1, limit: 10)
//    let socketManager = KPSocketManager()
    
    var progressView: KDCircularProgress!
    var miningModel: MiningModel?
    
    var selectedSegment: Int! {
        didSet {
            updateSegmentUI()
        }
    }
    
    deinit {
//        socketManager.disConnect()
        _defaultCenter.removeObserver(self)
        yzPrint(items: "Deallocated: \(self.classForCoder)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareProgressBar()
        addRefreshControl()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        prepareSocket()
//        socketManager.send(event: .get_mingin_balance, param: ["user_id": YZApp.shared.objLogInUser!.id])
        getNews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}

extension HomeVC {
    
    func prepareUI() {
        registerNIB()
        selectedSegment = 0
        lblInvites.text = YZApp.shared.getLocalizedText("start_inviting")
        lblInviteFrds.text = YZApp.shared.getLocalizedText("Invite_friend")
        lblTeam.text = YZApp.shared.getLocalizedText("team")
        lblNews.text = YZApp.shared.getLocalizedText("news")
        lblBalTxt.font = lblBalTxt.font.withSize(20 * YZAppConfig.heightRatio)
        lblBal.font = lblBalTxt.font.withSize(40 * YZAppConfig.heightRatio)
        lblPerHour.font = lblBalTxt.font.withSize(18 * YZAppConfig.heightRatio)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.callBackAfterTimerStart),
            name: nTimeCallBack,
            object: nil)
        btnStart.isHidden = true
        btnAboveBalance.isHidden = true
    }
    
    @objc private func callBackAfterTimerStart(notification: NSNotification){
        guard let _ = YZApp.shared.objMiningModel else { return }
        self.lblBal.text = YZApp.shared.objMiningModel!.balanceToShow
        self.lblRemianingTime.text = YZApp.shared.objMiningModel!.remainingTimeToShow
    }
    
    func registerNIB() {
        tableView.register(NewsTVC.nib, forCellReuseIdentifier: NewsTVC.identifier)
        tableView.register(TeamMemberTVC.nib, forCellReuseIdentifier: TeamMemberTVC.identifier)
        tableView.register(NoDataCell.nib, forCellReuseIdentifier: NoDataCell.identifier)
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        if selectedSegment == 0 {
            getTeams(refreshControl, isIndicatorShow: false)
        } else {
            getNews(refreshControl, isIndicatorShow: false)
        }
    }
    
    func updateValueLabels() {
        guard let _ = YZApp.shared.objMiningModel else { return }
        lblPerHour.text = "+\(YZApp.shared.objMiningModel!.ratePerHours) /hr"
        btnStart.isHidden = YZApp.shared.objMiningModel!.status != "completed"
        btnAboveBalance.isHidden = YZApp.shared.objMiningModel!.status == "completed"
        progressView.angle = Double(YZApp.shared.objMiningModel!.spentTimeValueForCircle)
        progressView.animate(fromAngle: Double(YZApp.shared.objMiningModel!.spentTimeValueForCircle), toAngle: 360, duration: 86400 - Double(YZApp.shared.objMiningModel!.spentTime.secondFromString)) { isDone in
            if isDone { YZApp.shared.objMiningModel!.timer?.invalidate() }
        }
        if YZApp.shared.objMiningModel!.status == "start" {
            YZApp.shared.objMiningModel!.fireTimerMethod()
        }
    }
    
    func prepareProgressBar() {
        
        progressView = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 300 * YZAppConfig.heightRatio, height: 300 * YZAppConfig.heightRatio))
        progressView.startAngle = -90
        progressView.progressThickness = 0.2
        progressView.trackThickness = 0.2
        progressView.clockwise = true
        progressView.gradientRotateSpeed = 2
        progressView.roundedCorners = false
        progressView.glowMode = .forward
        progressView.glowAmount = 0
        progressView.trackColor = UIColor.white.withAlphaComponent(0.8)
        progressView.set(colors: UIColor.appD69734)
        progressView.angle = 0
        viewCircleContainer.addSubview(progressView)
    }
    
    func updateSegmentUI() {
        if !isViewLoaded { return }
        lblTeam.font = UIFont.robotoMedium(ofSize: 20)
        lblNews.font = UIFont.robotoMedium(ofSize: 20)
        if selectedSegment == 0 {
            lblTeam.font = UIFont.robotoBold(ofSize: 20)
            lblTeam.textColor = UIColor.init("#C48A31")
            lblNews.textColor = UIColor.init("#2B2953")
            _leadingLblBar.constant = 0
        } else {
            lblNews.font = UIFont.robotoBold(ofSize: 20)
            lblNews.textColor = UIColor.init("#C48A31")
            lblTeam.textColor = UIColor.init("#2B2953")
            _leadingLblBar.constant = (YZAppConfig.width - 30) / 2
        }
        reloadTableView()
    }
}

//MARK: UIActions
extension HomeVC {
    @IBAction func onSegmentChange(_ sender: UIButton) {
        selectedSegment = sender.tag
    }
    
    @IBAction func btnStartPressed(_ sender: UIButton) {
        startMining()
    }
    
    @IBAction func btnAboveBalancePressed(_ sender: UIButton) {
        performSegue(withIdentifier: YZSegues.teamView, sender: self)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegment == 0 {
            return arrTeams == nil ? 0 : arrTeams.isEmpty ? 1 : arrTeams.count
        } else {
            
        }
        return arrNews == nil ? 0 : arrNews.isEmpty ? 1 : arrNews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedSegment == 0 ? arrTeams.isEmpty ? tableView.frame.height : 90 : arrNews.isEmpty ? tableView.frame.height : 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedSegment == 0 {
            if arrTeams.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
            }
            return tableView.dequeueReusableCell(withIdentifier: TeamMemberTVC.identifier, for: indexPath)
        } else {
            if arrNews.isEmpty {
                return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
            }
            return tableView.dequeueReusableCell(withIdentifier: NewsTVC.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? TeamMemberTVC {
            cell.teamModel = arrTeams[indexPath.row]
        } else if let cell = cell as? NewsTVC {
            cell.newsModel = arrNews[indexPath.row]
            cell.parentVC = self
        } else if let cell = cell as? NoDataCell {
            cell.lblTitle.text = "Results not found"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedSegment == 0 && !arrTeams.isEmpty {
            //            performSegue(withIdentifier: YZSegues.teamView, sender: self)
        }
    }
}

// MARK: - Socket method(s)
extension HomeVC {
    
//    func prepareSocket() {
//        YZApp.shared.socketManager = socketManager
//        socketManager.connectSockect()
//
//        socketManager.statusCHCall = {[weak self] (status) in
//            guard let weakSelf = self else { return }
//            if status == SocketIOStatus.connected {
////                weakSelf.showCentralNVActivity()
//                weakSelf.socketManager.send(event: .get_mingin_balance, param: ["user_id": YZApp.shared.objLogInUser!.id])
//            }
//        }
//
//        socketManager.listnerCall = {[weak self] (type, data) in
//            guard let weakSelf = self else { return }
//            switch type {
//            case .getTeamsResponse:
//
//                if let arrdict = data as? [NSDictionary], !arrdict.isEmpty {
//                    let dictJSON = arrdict[0]
//                    let statusCode = dictJSON.getIntValue(forKey: "status")
//                    let userId = dictJSON.getStringValue(forKey: "userID")
//                    if YZApp.shared.objLogInUser!.id != userId { return }
//
//                    if statusCode == 200  {
//                        if let dataDict = dictJSON["data"] as? NSDictionary {
//                            weakSelf.arrTeams = []
//                            if let teamDictArr = dataDict["parent"] as? [NSDictionary] {
//                                for dict in teamDictArr {
//                                    weakSelf.arrTeams.append(TeamModel(dict: dict))
//                                }
//                            }
//                            if let teamDictArr = dataDict["teams"] as? [NSDictionary] {
//                                for dict in teamDictArr {
//                                    weakSelf.arrTeams.append(TeamModel(dict: dict))
//                                }
//                            }
//                        }
//                    } else {
//                        YZAPI.call.showAPIMessage(dictJSON, messageFor: .error)
//                    }
//                    weakSelf.tableView.reloadData()
//                }
//
//            case .getNewsResponse:
//                if let arrdict = data as? [NSDictionary], !arrdict.isEmpty {
//                    let dictJSON = arrdict[0]
//                    let statusCode = dictJSON.getIntValue(forKey: "status")
//
//                    if statusCode == 200  {
//                        if let dataDict = dictJSON["data"] as? NSDictionary {
//                            weakSelf.arrNews = []
//                            if let newsDictArr = dataDict["news"] as? [NSDictionary] {
//                                for dict in newsDictArr {
//                                    weakSelf.arrNews.append(NewsModel(dict: dict))
//                                }
//                            }
//                        }
//                    } else {
//                        YZAPI.call.showAPIMessage(dictJSON, messageFor: .error)
//                    }
//                    weakSelf.tableView.reloadData()
//                }
//
//            case .get_mingin_balance_response:
//
//                if let arrdict = data as? [NSDictionary], !arrdict.isEmpty {
//                    let dictJSON = arrdict[0]
//                    let statusCode = dictJSON.getIntValue(forKey: "status")
//                    let userId = dictJSON.getStringValue(forKey: "userID")
//                    if YZApp.shared.objLogInUser!.id != userId { return }
//
//                    if statusCode == 200  {
//                        if let dataDict = dictJSON["data"] as? NSDictionary {
//                            YZApp.shared.objMiningModel?.timer?.invalidate()
//                            YZApp.shared.objMiningModel = nil
//                            YZApp.shared.objMiningModel = MiningModel(dict: dataDict)
//                            weakSelf.updateValueLabels()
//                        }
//                    } else if statusCode == 401 {
//                        weakSelf.btnStart.isHidden = false
//                        weakSelf.btnAboveBalance.isHidden = true
//                    } else {
//                        YZAPI.call.showAPIMessage(dictJSON, messageFor: .error)
//                    }
//                }
//                weakSelf.hideCentralNVActivity()
//                weakSelf.socketManager.send(event: .getTeams, param: ["user_id": YZApp.shared.objLogInUser!.id])
//                weakSelf.socketManager.send(event: .getNews, param: [:])
//            case .startMiningResponse:
////                weakSelf.hideCentralNVActivity()
//                if let arrdict = data as? [NSDictionary], !arrdict.isEmpty {
//                    let dictJSON = arrdict[0]
//                    let statusCode = dictJSON.getIntValue(forKey: "status")
//                    let userId = dictJSON.getStringValue(forKey: "userID")
//                    if YZApp.shared.objLogInUser!.id != userId { return }
//                    if statusCode == 200  {
//                        if let dataDict = dictJSON["data"] as? NSDictionary {
//
//                        }
//                    } else {
//                        YZAPI.call.showAPIMessage(dictJSON, messageFor: .error)
//                    }
//                    weakSelf.tableView.reloadData()
//                }
//                weakSelf.socketManager.send(event: .get_mingin_balance, param: ["user_id": YZApp.shared.objLogInUser!.id])
//            default: break
//            }
//        }
//    }
//
//    func startMiningSocketCall() {
////        showCentralNVActivity()
//        socketManager.send(event: .startMining, param: ["user_id": YZApp.shared.objLogInUser!.id])
//    }
    
}

// MARK: - Api calls
extension HomeVC {
    
    func getMiningDetail() {
        YZAPI.call.getMiningDetail(["user_id": YZApp.shared.objLogInUser!.id]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            YZApp.shared.objMiningModel?.timer?.invalidate()
                            YZApp.shared.objMiningModel = nil
                            YZApp.shared.objMiningModel = MiningModel(dict: dataDict)
                            weakSelf.updateValueLabels()
                        }
                    } else if statusCode == 401 {
                        weakSelf.btnStart.isHidden = false
                        weakSelf.btnAboveBalance.isHidden = true
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                }
            } else if statusCode == 401 {
                weakSelf.btnStart.isHidden = false
                weakSelf.btnAboveBalance.isHidden = true
                weakSelf.hideCentralNVActivity()
            } else {
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
            }
        }
    }
    
    func getNews(_ refreshControl: UIRefreshControl? = nil, isIndicatorShow: Bool = true) {
        if isIndicatorShow {showCentralNVActivity()}
        
        YZAPI.call.getNews(nil) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if refreshControl == nil { weakSelf.getTeams() }
            if statusCode == 200 {
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            weakSelf.arrNews = []
                            if let newsDictArr = dataDict["news"] as? [NSDictionary] {
                                for dict in newsDictArr {
                                    weakSelf.arrNews.append(NewsModel(dict: dict))
                                }
                            }
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    weakSelf.tableView.reloadData()
                    refreshControl?.endRefreshing()
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
                refreshControl?.endRefreshing()
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    func getTeams(_ refreshControl: UIRefreshControl? = nil, isIndicatorShow: Bool = true) {
        
        YZAPI.call.getTeams(["user_id": YZApp.shared.objLogInUser!.id]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if refreshControl == nil { weakSelf.getMiningDetail() }
            if statusCode == 200 {
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            weakSelf.arrTeams = []
                            if let teamDictArr = dataDict["parent"] as? [NSDictionary] {
                                for dict in teamDictArr {
                                    let objP = TeamModel(dict: dict)
                                    objP.isParent = true
                                    weakSelf.arrTeams.append(objP)
                                }
                            }
                            if let teamDictArr = dataDict["teams"] as? [NSDictionary] {
                                for dict in teamDictArr {
                                    weakSelf.arrTeams.append(TeamModel(dict: dict))
                                }
                            }
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    refreshControl?.endRefreshing()
                    weakSelf.tableView.reloadData()
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.hideCentralNVActivity()
                refreshControl?.endRefreshing()
                weakSelf.tableView.reloadData()
            }
        }
    }
    
    func startMining() {
        showCentralNVActivity()
        YZAPI.call.startMining(["user_id": YZApp.shared.objLogInUser!.id]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            weakSelf.getMiningDetail()
            if statusCode == 200 {
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            
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
}
