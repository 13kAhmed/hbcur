//
//  UIColorExtension.swift
//

import UIKit

extension UIColor {
    static let TOASTSUCCESS = UIColor(named: "218B00")
    static let TOASTERROR = UIColor(named:"FF3B30")
    static let TOASTWARNINGA = UIColor.from("FF9907")
    static let appD8D8D8 = UIColor.from("D8D8D8")
    static let app51BA6C = UIColor.from("51BA6C")
    static let app152C53 = UIColor.from("152C53")
    static let app78849E = UIColor.from("78849E")
    static let app2185D0 = UIColor.from("2185D0")
    static let appE6E8EC = UIColor.from("E6E8EC")
    static let appF4F4F6 = UIColor.from("F4F4F6")
    static let appFAFAFA = UIColor.from("FAFAFA")
    static let app43425D = UIColor.from("43425D")
    static let appE5E5E5 = UIColor.from("E5E5E5")
    static let appBA5151 = UIColor.from("BA5151")
    static let app18385E = UIColor.from("18385E")
    static let appCAD2E1 = UIColor.from("CAD2E1")
    static let appE6E6E6 = UIColor.from("E6E6E6")
    static let appC6C6C6 = UIColor.from("C6C6C6")
    static let app8994A8 = UIColor.from("8994A8")
    static let appF2F2F2 = UIColor.from("F2F2F2")
    static let appEDF0F5 = UIColor.from("EDF0F5")
    static let appEAF0F4 = UIColor.from("EAF0F4")
    static let appAB313C = UIColor.from("AB313C")
    static let appFFAF41 = UIColor.from("FFAF41")
    static let app989898 = UIColor.from("989898")
    static let appF1F2F5 = UIColor.from("F1F2F5")
    static let appD69734 = UIColor.from("#D69734")
    static let app4D4D4D = UIColor.from("#4D4D4D")
    static let appC48A31 = UIColor.from("#C48A31")
    static let app2B2953 = UIColor.from("#2B2953")
    
    //MARK:- New Colors
    static let appWhite = UIColor("FFFFFF")
    static let app26282C = UIColor("26282C")
    
    class func from(_ hexaValue: String, alpha: Double = 1.0) -> UIColor {
        var cString: String = hexaValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if cString.count != 6 {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}
