//
//  DateExtension.swift
//

import UIKit
import Foundation

let _serverFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    //2017-06-23 11:53:53
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}()

let _localFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE, dd-MMM-yyyy, hh:mm a"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    //    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    
    return dateFormatter
}()

let _UTCFormat: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter
}()

//MARK: -
extension Date {
    
    func getReadableDateString() -> String {
        _localFormatter.dateFormat = "dd MMMM yyyy"
        return _localFormatter.string(from: self)
    }
    
    func getReadableDateDDMMYYYYTimeString() -> String {
        _localFormatter.dateFormat = "dd/MM/yyyy"
        return _localFormatter.string(from: self)
    }
    
    func getReadableDateTimeString1() -> String {
        _localFormatter.dateFormat = "MM-dd"
        return _localFormatter.string(from: self)
    }
    
    func getReadableYYYYMMDDHHmmsssString() -> String {
        return _serverFormatter.string(from: self)
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            return true
        }
        return false
    }
    
    func getWeekDay() -> String {
        return dayNameFrom(Calendar.current.component(Calendar.Component.weekday, from: self))
    }
    
    static func getDateFrom( _ hoursMinutesSecond: String) -> Date? {
        let currentOpeningDateString = Date().getReadableDateDDMMYYYYTimeString() + " " + hoursMinutesSecond
        return Date.dateFromServer(currentOpeningDateString, format: "dd/MM/yyyy HH:mm")!
    }
    
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}

//MARK: -
extension Date {
    
    //Initialise date from server response
    static func dateFromServer(_ dateString: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? {
        _serverFormatter.dateFormat = format
        return _serverFormatter.date(from: dateString)
    }
    
    func stringFromLocal(_ format: String = "dd.MM.yyyy") -> String {
        _localFormatter.dateFormat = format
        return _localFormatter.string(from: self)
    }
    
    func stringFromUTC(_ format: String = "yyyy-MM-dd'T'HH:mm:ss") -> String {
        _UTCFormat.dateFormat = format
        return _UTCFormat.string(from: self)
        
    }
    
    func displayMediaTimeLine() -> NSAttributedString {
        let strArray = stringFromLocal("dd-MMM-yyyy").components(separatedBy: "-")
        let strDateFormat = (strArray[0] + "\n" + strArray[1].uppercased())
        return NSAttributedString(string: strDateFormat)
    }
    
    static func reminderScheduleInterval() -> TimeInterval {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentTime = dateFormatter.string(from: Date())
        //let currentTime = _timeFormatter.string(from: Date())
        let hh = currentTime.split(separator: ":").first!.description
        
        var currentDateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second, .timeZone], from: Date())
        currentDateComponents.setValue(hh.toInt! < 13 ? 13 + 5 : 13 + 22, for: .hour)
        currentDateComponents.setValue(0, for: .minute)
        currentDateComponents.setValue(0, for: .second)
        var calendar = Calendar.current
        calendar.timeZone = currentDateComponents.timeZone!
        let futureDate = calendar.date(from: currentDateComponents)
        return futureDate!.timeIntervalSince1970 - Date().timeIntervalSince1970
    }
    
    func ordinalStringIn(_ format: String = "MMM yyyy HH:mm") -> String {
        let dateComponents = Calendar.current.component(.day, from: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        if let day = numberFormatter.string(from: NSNumber(value: dateComponents)) {
            _localFormatter.dateFormat = format
            _localFormatter.timeZone = TimeZone.current
            return day + " " + _localFormatter.string(from: self) //let dateString = "\(day!) \(dateFormatter.string(from: date))"
        }else{
            return ""
        }
    }
    
    func dayNameFrom(_ int : Int ) -> String {
        switch int {
        case 1:
            return YZApp.shared.getLocalizedText("sunday")
        case 2:
            return YZApp.shared.getLocalizedText("monday")
        case 3:
            return YZApp.shared.getLocalizedText("tuesday")
        case 4:
            return YZApp.shared.getLocalizedText("wednesday")
        case 5:
            return YZApp.shared.getLocalizedText("thursday")
        case 6:
            return YZApp.shared.getLocalizedText("friday")
        case 7:
            return YZApp.shared.getLocalizedText("saturday")
        default:
            fatalError("NO MORE WEEKDAYs IN WORLD.")
        }
    }
    
    func timeAgoSinceDate(_ numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(self)
        let latest = (earliest == now as Date) ? self : now as Date
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return components.year!.description + " " + YZApp.shared.getLocalizedText("years_ago")
        } else if (components.year! >= 1){
            if (numericDates){
                return components.year!.description + " " + YZApp.shared.getLocalizedText("year_ago")
            } else {
                return YZApp.shared.getLocalizedText("last_year")
            }
        } else if (components.month! >= 2) {
            return components.month!.description + " " + YZApp.shared.getLocalizedText("months_ago")
        } else if (components.month! >= 1){
            if (numericDates){
                return components.month!.description + " " + YZApp.shared.getLocalizedText("month_ago")
            } else {
                return YZApp.shared.getLocalizedText("last_month")
            }
        } else if (components.weekOfYear! >= 2) {
            return components.weekOfYear!.description + " " + YZApp.shared.getLocalizedText("weeks_ago")
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return components.weekOfYear!.description + " " + YZApp.shared.getLocalizedText("week_ago")
            } else {
                return YZApp.shared.getLocalizedText("last_week")
            }
        } else if (components.day! >= 2) {
            return components.day!.description + " " + YZApp.shared.getLocalizedText("days_ago")
        } else if (components.day! >= 1){
            if (numericDates){
                return components.day!.description + " " + YZApp.shared.getLocalizedText("day_ago")
            } else {
                return YZApp.shared.getLocalizedText("last_day")
            }
        } else if (components.hour! >= 2) {
            return components.hour!.description + " " + YZApp.shared.getLocalizedText("hours_ago")
        } else if (components.hour! >= 1){
            if (numericDates){
                return components.hour!.description + " " + YZApp.shared.getLocalizedText("hour_ago")
            } else {
                return YZApp.shared.getLocalizedText("last_hour")
            }
        } else if (components.minute! >= 2) {
            return components.minute!.description + " " + YZApp.shared.getLocalizedText("minutes_ago")
        } else if (components.minute! >= 1){
            if (numericDates){
                return components.minute!.description + " " + YZApp.shared.getLocalizedText("minute_ago")
            } else {
                return YZApp.shared.getLocalizedText("last_minute")
            }
        } else if (components.second! >= 3) {
            return components.second!.description + " " + YZApp.shared.getLocalizedText("seconds_ago")
        } else {
            return YZApp.shared.getLocalizedText("just_now")
        }
    }
}

//MARK: -
extension Date {
    
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
    
    var ordinalFormate: String {
        let calendar = Calendar.current
        let dateComponents = calendar.component(.day, from: self)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let day = numberFormatter.string(from: dateComponents as NSNumber)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        let dateString = "\(day!) \(dateFormatter.string(from: self))"
        return dateString
    }
}

extension Date {
    
    func getElapsedInterval() -> String {
        
        let interval = Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year" :
                "\(year)" + " " + "years"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month" :
                "\(month)" + " " + "months"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day" :
                "\(day)" + " " + "days"
        } else {
            return "today"
        }
        
    }
}
