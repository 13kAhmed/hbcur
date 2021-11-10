//
//  HomeScreenModels.swift
//  BeeApp
//
//  Created by Harshad-M007 on 24/05/21.
//

import Foundation

class MiningModel {
    
    
    var availableBalance: Double
    var totalActiveMining: Int
    var totalInactiveMining: Int
    var totalInvited: Int
    var totalTeamMember: Int
    
    var id: String
    var startTime: String
    var spentTime: String
    var status: String
    var totalAmount: String
    var ratePerHours: Double
    var userRate: Double
    var parentRate: Double
    var valueForSpentTime: Double = 0
    var timer: Timer!
    
    var remainingTimeToShow: String = "00:00:00"
    var balanceToShow: String = "0"
    
    var spentTimeValueForCircle: Int {
        return (spentTime.secondFromString * 360) / 86400
    }
    
    var remaningTimeSecond: Double = 0
    
    var ratePerSecond: Double {
        let doublePerHours = Double(userRate)
        return (doublePerHours/3600.0)
    }
    
    
    func fireTimerMethod() {
        YZApp.shared.objMiningModel!.timer?.invalidate()
        YZApp.shared.objMiningModel!.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer() {
        YZApp.shared.objMiningModel!.valueForSpentTime =  YZApp.shared.objMiningModel!.valueForSpentTime + YZApp.shared.objMiningModel!.ratePerSecond
        let doubleStr = String(format: "%.2f", ceil((self.valueForSpentTime + YZApp.shared.objMiningModel!.availableBalance)*100)/100)
        balanceToShow = "\(doubleStr)"
        YZApp.shared.objMiningModel!.remaningTimeSecond = YZApp.shared.objMiningModel!.remaningTimeSecond - 1
        if YZApp.shared.objMiningModel!.remaningTimeSecond > 0 {
            YZApp.shared.objMiningModel!.remainingTimeToShow = "\(YZApp.shared.objMiningModel!.remaningTimeSecond.asString(style: .positional))"
        } else {
            YZApp.shared.objMiningModel!.remainingTimeToShow = "00:00:00"
        }
        NotificationCenter.default.post(name: nTimeCallBack, object: nil, userInfo: nil)
    }
    
    init(dict: NSDictionary) {
        let miningDict = dict["mining"] as! NSDictionary
        self.availableBalance = dict.getDoubleValue(forKey: "avail_balance")
        self.totalActiveMining = dict.getIntValue(forKey: "total_active_mining")
        self.totalInactiveMining = dict.getIntValue(forKey: "total_inactive_mining")
        self.totalInvited = dict.getIntValue(forKey: "total_invited")
        self.totalTeamMember = dict.getIntValue(forKey: "total_team_member")
        
        self.id = miningDict["id"] as? String ?? ""
        self.startTime = miningDict["start_time"] as? String ?? ""
        self.spentTime = miningDict["spent_time"] as? String ?? ""
        self.status = miningDict["status"] as? String ?? ""
        self.totalAmount = miningDict["total_amount"] as? String ?? ""
        self.ratePerHours = miningDict.getDoubleValue(forKey: "rate")
        
        self.userRate = miningDict["user_rate"] as? Double ?? 0.0
        
        self.parentRate = miningDict.getDoubleValue(forKey: "parent_rate")
        self.valueForSpentTime = Double(spentTime.secondFromString) * ratePerSecond
        self.remaningTimeSecond = Double(86400 - spentTime.secondFromString)
        balanceToShow =  String(format: "%.2f", ceil(availableBalance*100)/100)
    }
}


class TeamModel {
    var id: Int
    var userName: String
    var firstName: String
    var lastName: String
    var mobile: String
    var imageUrlStr: String
    var isParent: Bool = false
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var imageURL: URL? {
        return URL(string: imageUrlStr)
    }
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as? Int ?? 0
        self.userName = dict["username"] as? String ?? ""
        self.firstName = dict["first_name"] as? String ?? ""
        self.lastName = dict["last_name"] as? String ?? ""
        self.mobile = dict["mobile"] as? String ?? ""
        self.imageUrlStr = dict["avtar"] as? String ?? ""
    }
}


class NewsModel {
    var id: Int
    var title: String
    var description: String
    var urlNews: String
    var imageUrlStr: String
    var status: String
    var createdDate: String
    
    var date: Date? {
        return Date.dateFromServer(createdDate,format: "yyyy-MM-dd HH:mm:ss")
    }
    
    var imageURL: URL? {
        return URL(string: "https://hbcucrypto.com/admin/public/images/news/\(imageUrlStr)")
    }
    
    var strDate: String {
        let str = date?.stringFromLocal("dd-MMM yyyy, hh:mm a") ?? ""
        return str
    }
    
    init(dict: NSDictionary) {
        self.id = dict["id"] as? Int ?? 0
        self.title = dict["title"] as? String ?? ""
        self.description = dict["description"] as? String ?? ""
        self.urlNews = dict["url"] as? String ?? ""
        self.imageUrlStr = dict["image"] as? String ?? ""
        self.status = dict["status"] as? String ?? ""
        self.createdDate = dict["created_at"] as? String ?? ""
    }
}


extension String{

    var integer: Int {
        return Int(self) ?? 0
    }

    var secondFromString : Int{
        let components: Array = self.components(separatedBy: ":")
        let hours = components[0].integer
        let minutes = components[1].integer
        let seconds = components[2].integer
        return Int((hours * 60 * 60) + (minutes * 60) + seconds)
    }
}

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
