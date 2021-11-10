//
//  RankingVC.swift
//  BeeApp
//
//  Created by iOSDev on 21/04/21.
//

import UIKit

class CountryModel {
    var id: String = ""
    var name: String = ""
    var isoCode2: String = ""
    var isoCode3: String = ""
    var phoneCode: String = ""
    
    init(dict:NSDictionary) {
        self.id = dict.getStringValue(forKey: "id")
        self.name = dict.getStringValue(forKey: "name")
        self.isoCode2 = dict.getStringValue(forKey: "iso_code_2")
        self.isoCode3 = dict.getStringValue(forKey: "iso_code_3")
        self.phoneCode = dict.getStringValue(forKey: "phone_code")
    }
}

class RankingModel {
    var id: String = ""
    var userName: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var imageUrlStr: String = ""
    var invitationCode: String = ""
    var nationality: String = ""
    var isAfricanAmerican: String = ""
    var parentId: String = ""
    var availableBalance: String = ""
    var fullName: String = ""
    
    var imageURL: URL? {
        return URL(string: imageUrlStr)
    }
    
    init(dict:NSDictionary) {
        
        self.id = dict.getStringValue(forKey: "id")
        self.userName = dict.getStringValue(forKey: "username")
        self.firstName = dict.getStringValue(forKey: "first_name")
        self.lastName = dict.getStringValue(forKey: "last_name")
        self.imageUrlStr = dict.getStringValue(forKey: "avtar")
        self.invitationCode = dict.getStringValue(forKey: "invitation_code")
        self.nationality = dict.getStringValue(forKey: "nationality")
        self.isAfricanAmerican = dict.getStringValue(forKey: "is_african_american")
        self.parentId = dict.getStringValue(forKey: "parent_id")
        self.availableBalance = dict.getStringValue(forKey: "available_balance")
        self.fullName = dict.getStringValue(forKey: "fullname")
        
    }
}


class RankingVC: YZParentVC {
    
    @IBOutlet weak var lblNavTitle: UILabel!
    var arrRankingRegional: [RankingModel] = []
    var arrRankingGlobal: [RankingModel] = []
    var arrCountry: [CountryModel] = []
    
    var selectedMenuIndex:Int = 0
    var selectedRegionIndex:Int = 0
    var objPagingForRegional: YZPagingnation = YZPagingnation(1, limit: 10)
    var objPagingForGlobal: YZPagingnation = YZPagingnation(1, limit: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUIs()
        getRankingList()
    }
}

extension RankingVC {
    
    func prepareUIs() {
        lblNavTitle.text = YZApp.shared.getLocalizedText("ranking")
        registerNIB()
        addRefreshControl()
    }
    
    func registerNIB() {
        tableView.register(SegmentHFV.nib, forHeaderFooterViewReuseIdentifier: SegmentHFV.identifier)
        tableView.register(RankingUserTVC.nib, forCellReuseIdentifier: RankingUserTVC.identifier)
        tableView.register(RankingSegmentTVC.nib, forCellReuseIdentifier: RankingSegmentTVC.identifier)
        tableView.register(RegionTVC.nib, forCellReuseIdentifier: RegionTVC.identifier)
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.didPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        getRankingList(refreshControl, isIndicatorShow: false)
    }
    
    func loadMoreData(_ indexPath: IndexPath) {
        
        if selectedRegionIndex == 0 {
            if arrRankingRegional.count == 100 { return }
            if YZAPI.call.isInternetAvailable() && objPagingForRegional.isAllLoaded == false && indexPath.row == arrRankingRegional.count && objPagingForRegional.isLoading == false {
                getRankingList(nil, isIndicatorShow: false)
            }
        } else {
            if arrRankingGlobal.count == 100 { return }
            if YZAPI.call.isInternetAvailable() && objPagingForGlobal.isAllLoaded == false && indexPath.row == arrRankingGlobal.count && objPagingForGlobal.isLoading == false {
                getRankingList(nil, isIndicatorShow: false)
            }
        }
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension RankingVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedMenuIndex == 0 {
            return selectedRegionIndex == 0 ? arrRankingRegional.count + 1 : arrRankingGlobal.count + 1
        } else {
            return arrCountry.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let HFV = tableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentHFV.identifier) as! SegmentHFV
        HFV.prepareTitles(["_HBCU", "user_region"])
        HFV.selectedSegment = selectedMenuIndex
        HFV.delegate = self
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedMenuIndex == 0 {
            if indexPath.row == 0 {
                return 64
            } else {
                return 80
            }
        }
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedMenuIndex == 0 {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: RankingSegmentTVC.identifier, for: indexPath)
            } else {
                return tableView.dequeueReusableCell(withIdentifier: RankingUserTVC.identifier, for: indexPath)
            }
        } else {
            return tableView.dequeueReusableCell(withIdentifier: RegionTVC.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is RankingUserTVC {
            let cellRanking = cell as! RankingUserTVC
            cellRanking.rankingModel = selectedRegionIndex == 0 ? arrRankingRegional[indexPath.row-1] : arrRankingGlobal[indexPath.row-1]
            cellRanking.lblNumber.text = indexPath.row.description
            loadMoreData(indexPath)
        } else if cell is RankingSegmentTVC {
            let cellSegment = cell as! RankingSegmentTVC
            cellSegment.delegate = self
            cellSegment.prepareUI(selectedRegionIndex)
        } else if cell is RegionTVC {
            let cellRanking = cell as! RegionTVC
            cellRanking.lblNumber.text = (indexPath.row + 1).description
            cellRanking.countryModel = arrCountry[indexPath.row]
        }
    }
}

//MARK: YZUserTapDelegate
extension RankingVC: YZUserTapDelegate {
    
    func didTapOn(_ text: String, tableCell: YZParentTVC?, anyObject: Any?) {
        if text == "1" {
            selectedRegionIndex = 1
            if arrRankingGlobal.isEmpty { getRankingList()  }
        } else {
            selectedRegionIndex = 0
            if arrRankingRegional.isEmpty { getRankingList()  }
        }
        reloadTableView()
    }
    
    func didTapOn(_ text: String, headerFooter: YZParentHFV?, anyObject: Any?) {
        if text == "1" {
            selectedMenuIndex = 1
        } else {
            selectedMenuIndex = 0
        }
        reloadTableView()
    }
}

// MARK: - Api calls
extension RankingVC {
    
    func getRankingList(_ refreshControl: UIRefreshControl? = nil, isIndicatorShow: Bool = true) {
        if isIndicatorShow {showCentralNVActivity()}
        var paramDict: [String:Any] = ["user_id": YZApp.shared.objLogInUser!.id,"type": selectedRegionIndex == 0 ? "regional" : "global"]
        if selectedRegionIndex == 0 {
            if refreshControl != nil {objPagingForRegional = YZPagingnation(1, limit: 10)}
            objPagingForRegional.isLoading = true
            paramDict["page"] = objPagingForRegional.pageNumber
        } else {
            if refreshControl != nil {objPagingForGlobal = YZPagingnation(1, limit: 10)}
            objPagingForGlobal.isLoading = true
            paramDict["page"] = objPagingForGlobal.pageNumber
        }
        YZAPI.call.getRankingList(paramDict) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                if isIndicatorShow || refreshControl != nil { weakSelf.getCountryList() }
//                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {

                            if weakSelf.selectedRegionIndex == 0 {
                                if weakSelf.objPagingForRegional.pageNumber == 1 {weakSelf.arrRankingRegional = []}
                            } else {
                                if weakSelf.objPagingForGlobal.pageNumber == 1 {weakSelf.arrRankingGlobal = []}
                            }
                            
                            if let arrRanking = dataDict["ranking"] as? [NSDictionary] {
                                for dictRanking in arrRanking {
                                    if weakSelf.selectedRegionIndex == 0 {
                                        weakSelf.arrRankingRegional.append(RankingModel(dict: dictRanking))
                                    } else {
                                        weakSelf.arrRankingGlobal.append(RankingModel(dict: dictRanking))
                                    }
                                }
                            }
                            if weakSelf.selectedRegionIndex == 0 {
                                weakSelf.objPagingForRegional.isAllLoaded = weakSelf.arrRankingRegional.count == dataDict.getIntValue(forKey: "total")
                                weakSelf.objPagingForRegional.pageNumber = weakSelf.objPagingForRegional.isAllLoaded ? weakSelf.objPagingForRegional.pageNumber : weakSelf.objPagingForRegional.pageNumber + 1
                            } else {
                                weakSelf.objPagingForGlobal.isAllLoaded = weakSelf.arrRankingGlobal.count == dataDict.getIntValue(forKey: "total")
                                weakSelf.objPagingForGlobal.pageNumber = weakSelf.objPagingForGlobal.isAllLoaded ? weakSelf.objPagingForGlobal.pageNumber : weakSelf.objPagingForGlobal.pageNumber + 1
                            }
                        }
                    } else {
                        YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                    }
                    weakSelf.prepareReviewDataAfterResponse(refreshControl)
                }
            }else{
                YZAPI.call.showAPIMessage(anyObject, messageFor: .error)
                weakSelf.prepareReviewDataAfterResponse(refreshControl)
            }
        }
    }
    
    func prepareReviewDataAfterResponse(_ refreshControl: UIRefreshControl?) {
        if selectedRegionIndex == 0 {
            objPagingForRegional.isLoading = false
        } else {
            objPagingForGlobal.isLoading = false
        }
        //Stop animating refreshControl
        refreshControl?.endRefreshing()
        //Hide indicator
        hideCentralNVActivity()
        //Reload collection view
        tableView.reloadData()
    }
    
    func getCountryList() {
        YZAPI.call.getCountryList(["":""]) {[weak self](anyObject, statusCode) in
            guard let weakSelf = self else {return}
            if statusCode == 200 {
                weakSelf.hideCentralNVActivity()
                if let dictJSON = anyObject as? NSDictionary {
                    let statusCode = dictJSON.getIntValue(forKey: "status")
                    if statusCode == 200  {
                        if let dataDict = dictJSON["data"] as? NSDictionary {
                            weakSelf.arrCountry = []
                            if let arrCountry = dataDict["countrys"] as? [NSDictionary] {
                                for countryDict in arrCountry {
                                    weakSelf.arrCountry.append(CountryModel(dict: countryDict))
                                }
                            }
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
