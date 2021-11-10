//
//  YZApp.swift
//

import Foundation
import UIKit

//MARK: App Global Variable(s)
let _userDefaults           = UserDefaults.standard
let _defaultCenter          = NotificationCenter.default
let _appDelegate            = UIApplication.shared.delegate as! AppDelegate
let _appName                = YZApp.shared.infoPlistInDictionary.getStringValue(forKey: "CFBundleName")
let _appStoreID             = ""
let bottomInset: CGFloat    = 20
var _currency: String {
    return YZApp.shared.getLocalizedText("currency_code")
}

var _hr: String {
    return YZApp.shared.getLocalizedText("_hr")
}
// MARK: - AppBased Keys
let kAPNSDeviceToken        = "APNSDeviceToken"
let kLanguagePreference     = "LanguagePreference"
let kAuthorization          = "access_token"
let kLastActiveAs           = "LastActiveAs"
let kEntryFlowDone          = "kEntryFlowDone"
let kRememberMe             = "kRememberMe"
let kPassUser               = "kPassUser"
let kEmailUser              = "kEmailUser"
let kUserType               = "kUserType"
let kPushNotificationEnable = "PushNotificationEnable"
let isCustomerActive = "isCustomerActive"
let isWorkerActive = "isWorkerActive"

//MARK: - Notification
let nfStatusBarInLight          = Notification.Name("NotificationStatusBarInLight")
let nfStatusBarInBlack          = Notification.Name("NotificationStatusBarInBlack")
let nfHideStatusBar             = Notification.Name("NotificationHideStatusBar")
let nfShowStatusBar             = Notification.Name("NotificationShowStatusBar")
let nfInternetNotAvailable      = Notification.Name("InternetNotAvailable")
let nfInternetAvailable         = Notification.Name("InternetAvailable")
let nfLanguagePreferenceUpdated = NSNotification.Name("LanguagePreferenceUpdated")
let nfGigUpdate                 = NSNotification.Name("GigUpdated")
let nTimeCallBack                 = NSNotification.Name("timeCalled")

//MARK: - Global Methods
//Comment in release modea
func yzPrint(items: Any...) {
    #if DEBUG
    for item in items {
        print(item)
    }
    #endif
}
//

//It will print app custom fonts name
func yzPrintFonts(font: UIFont?) {
    if let _ = font{
        yzPrint(items: "------------------------------")
        yzPrint(items: "Font Family Name = [\(font!.familyName)]")
        let names = UIFont.fontNames(forFamilyName: font!.familyName)
        yzPrint(items: "Font Names = [\(names)]")
    }else{
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            yzPrint(items: "------------------------------")
            yzPrint(items: "Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            yzPrint(items: "Font Names = [\(names)]")
        }
    }
}
//

/// It will use to display version and build number in setting screen.
///
/// - Returns: A string of version and build number.
func getVersionBuild() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "Version : \(version)\nBuild : \(build)"
}

/// It will use to display version number in support screen.
///
/// - Returns: A string of version and build number.
func getVersion() -> String {
    let dictionary = Bundle.main.infoDictionary!
    return "v" + (dictionary["CFBundleShortVersionString"] as! String)
}

//MARK: - Enum YZLinkableTexts
enum YZLinkableTexts {
    case forgotPassword, doNotAccount, alreadyHaveAccount, termsPrivacyPolicy, cancellationPolicy, termConditions, VatDetails
    
    var attributedString: NSAttributedString {
        switch self {
        case .forgotPassword:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: YZApp.shared.getLocalizedText("forgot_password"), attributes: [
                .font : UIFont.roboto(ofSize: 12),
                .foregroundColor : UIColor.app2185D0,
                .attachment : YZApp.shared.getLocalizedText("forgot_password"),
                .paragraphStyle : paragraphStyle,
                .underlineStyle : NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.app2185D0
            ]))
            return attributedString
            
        case .doNotAccount:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: YZApp.shared.getLocalizedText("do_not_have_an_account_create"), attributes: [
                .font : UIFont.roboto(ofSize: 12),
                .foregroundColor : UIColor.app2185D0,
                .attachment : YZApp.shared.getLocalizedText("do_not_have_an_account_create"),
                .paragraphStyle : paragraphStyle,
                .underlineStyle : NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.app2185D0
            ]))
            return attributedString
            
        case .alreadyHaveAccount:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: YZApp.shared.getLocalizedText("already_have_account_login"), attributes: [
                .font : UIFont.roboto(ofSize: 12),
                .foregroundColor : UIColor.app2185D0,
                .attachment : YZApp.shared.getLocalizedText("already_have_account_login"),
                .paragraphStyle : paragraphStyle,
                .underlineStyle : NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.app2185D0
            ]))
            return attributedString
            
        case .termsPrivacyPolicy:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            return NSAttributedString.add([
                YZApp.shared.getLocalizedText("by_signing_up_you_agree"),
                YZApp.shared.getLocalizedText("terms_of_service"),
                YZApp.shared.getLocalizedText("and"),
                YZApp.shared.getLocalizedText("privacy_policy")
                ], attributes: [
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app152C53,
                    .paragraphStyle : paragraphStyle,
                ],
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app2185D0,
                    .paragraphStyle : paragraphStyle,
                    .attachment : YZApp.shared.getLocalizedText("terms_of_service"),
                ],
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app152C53,
                    .paragraphStyle : paragraphStyle,
                ],
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app2185D0,
                    .paragraphStyle : paragraphStyle,
                    .attachment : YZApp.shared.getLocalizedText("privacy_policy"),
                ]
            ])
        case .VatDetails:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            
            return NSAttributedString.add([
                YZApp.shared.getLocalizedText("VAT_tn"),
                YZApp.shared.getLocalizedText("click_here"),
                YZApp.shared.getLocalizedText("vat_malta")
                ], attributes: [
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app152C53,
                    .paragraphStyle : paragraphStyle,
                ],
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app2185D0,
                    .paragraphStyle : paragraphStyle,
                    .attachment : YZApp.shared.getLocalizedText("click_here"),
                ],
                [
                    .font : UIFont.roboto(ofSize: 13),
                    .foregroundColor : UIColor.app152C53,
                    .paragraphStyle : paragraphStyle,
                ]
            ])
        case .cancellationPolicy:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: YZApp.shared.getLocalizedText("cancellation_policy"), attributes: [
                .font : UIFont.roboto(ofSize: 11),
                .foregroundColor : UIColor.app152C53,
                .attachment : YZApp.shared.getLocalizedText("cancellation_policy"),
                .paragraphStyle : paragraphStyle,
                .underlineStyle : NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.app152C53
            ]))
            return attributedString
        case .termConditions:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(NSAttributedString(string: YZApp.shared.getLocalizedText("terms_conditions"), attributes: [
                .font : UIFont.roboto(ofSize: 11),
                .foregroundColor : UIColor.app2185D0,
                .attachment : YZApp.shared.getLocalizedText("terms_conditions"),
                .paragraphStyle : paragraphStyle,
                .underlineStyle : NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.app2185D0
            ]))
            return attributedString

        }
    }
}

//MARK: - Enum YZLanguage
enum YZLanguage: Int {
    case english = 0
    var displayString : String {
        switch self {
        case .english:
            return YZApp.shared.getLocalizedText("english")
        }
    }
    var apiParameter : String {
        switch self {
        case .english:
            return "english"
        }
    }
}

//MARK: - Struct YZSegues
struct YZAppURLs {
    static let termsConditions  = URL(string: "https://www.gigify.mt/terms-condition?m=true")!
    static let privacyPolicy    = URL(string: "https://www.gigify.mt/privacy-policy?m=true")!
    static let appStore         = URL(string: "https://itunes.apple.com/us/app/\(_appName)/id\(_appStoreID)?mt=8")!
}

//MARK: - Struct YZSegues
struct YZSegues {
    static let login                    = "loginSegue"
    static let teamView                 = "segueTeamView"
    
}

//MARK: - Struct YZUnwindSegueParameters
struct YZUnwindSegueParameters {
    var fromController: UIViewController
    var toController: UIViewController
    
    init(_ fromController: UIViewController, toController: UIViewController) {
        self.fromController = fromController
        self.toController = toController
    }
}

//MARK: - Enum YZDynamicLinksType
enum YZDynamicLinksType: String {
    case type1 = ""
}

//MARK: - Class YZRedirection
class YZRedirection: NSObject {
    var type: YZDynamicLinksType
    var anyObject: Any?
    
    init?(_ dynamicLinks: URL) {
        if dynamicLinks.absoluteString.contains(YZDynamicLinksType.type1.rawValue) {
            type = .type1
            anyObject = dynamicLinks.absoluteString.components(separatedBy: YZDynamicLinksType.type1.rawValue).last
        }else{
            return nil
        }
    }
}

//MARK: - Structure YZPagingnation
/// It will used to get more datas from server
struct YZPagingnation {
    var pageNumber = 1
    var limit = 10
    var isAllLoaded = false
    var isLoading = false
    var offSet: Int {
        return pageNumber * limit
    }
    init(_ pageNumber: Int = 1, limit: Int = 10) {
        self.pageNumber = pageNumber
        self.limit = limit
    }
    
    func getRequestParameters() -> [String : Any] {
        return ["offset" : offSet, "limit" : limit]
    }
}

//MARK: - Class YZApp
//It's used to globally access any information or data
class YZApp: NSObject {
    @objc static var shared = YZApp()
    var keyboardHeight:CGFloat = 0.0
    var objLogInUser: YZLoggedInUser?
    var objMiningModel: MiningModel?
    var socketManager: KPSocketManager?
//    var userType: YZUserType!
//    var arrOrCountriesList: [Country]!

    var infoPlistInDictionary: NSDictionary {
        return NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)!
    }
    
    var language: YZLanguage {
        get {return YZLanguage(rawValue: _userDefaults.integer(forKey: kLanguagePreference))!}
        set {
            _userDefaults.set(newValue.rawValue, forKey: kLanguagePreference)
            _defaultCenter.post(name: nfLanguagePreferenceUpdated, object: nil)
        }
    }
    
    var isCustomerHidden: Bool {
        let statusFlag = _userDefaults.string(forKey: isCustomerActive)
        if statusFlag == nil {
            return false
        } else {
            return statusFlag == "1" ? false : true
        }
    }
    
    lazy var userDocumentDirectory: String = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }()
    
    override init() {
        super.init()
//        arrOrCountriesList = getListOfCountryName()

    }
    
    func openGoogleMap(late:Double, long:Double, name:String){
        //\(late),\(long)
        let strq =  name.replacingOccurrences(of: " ", with: "+")
        let urlString = "geo:\(late),\(long)&q=\(strq)"
        if let urlmaps = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(urlmaps){
            //            let urlString = "q=\(strq)&center:\(late),\(long)"
            if let url = URL(string: "comgooglemaps://?\(urlString)"),UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                return
            }
        }
        
        if let url = URL(string: "http://maps.google.com/maps?\(urlString)"){
            if UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func getListOfCountryName() -> [Country] {
        var countries = [Country]()
        let contryPath = Bundle.main.path(forResource: "country", ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: contryPath))
        do {
            if let list = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String:Any]] {
                for countryInfo in list {
                    let objContry = Country(dictCountry: countryInfo as NSDictionary)
                    countries.append(objContry)
                }
                return countries
            }else{
                return countries
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return countries
        }
    }

}

//MARK: - User's specific
extension YZApp {
    
    /// It will use to disable or enalbe idle timer
    ///
    /// - Parameter isDisabled: Boolean value
    func setIdleTimer(_ isDisabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = isDisabled
    }
}

//MARK: - Special method(s)
extension YZApp {
    
    func storeAuthorizationToken(_ token: String) {
        _userDefaults.set(token, forKey: kAuthorization)
        _userDefaults.synchronize()
    }
    
    func getAuthorizationToken() -> String? {
        return _userDefaults.value(forKey: kAuthorization) as? String
    }
    
    func removedAuthoriaztionToken() {
        _userDefaults.removeObject(forKey: kAuthorization)
        _userDefaults.synchronize()
    }
    
    /// It will call when APNS return device token information.
    /// It will call from appdelegate didReceived deviceToken.
    /// It will used stored device token to user default.
    ///
    /// - Parameter deviceToken: It contains string value.
    func setAPNS(deviceToken: String?) {
        if let deviceToken = deviceToken {
            yzPrint(items: "APNS Device Token: \(deviceToken)")
            _userDefaults.set(deviceToken, forKey: kAPNSDeviceToken)
            _userDefaults.synchronize()
        }else{
            yzPrint(items: "APNS Device Token removed: \(String(describing: deviceToken))")
            _userDefaults.removeObject(forKey: kAPNSDeviceToken)
            _userDefaults.synchronize()
        }
    }
    
    /// It will call from every getUserProfile API.
    /// It will used to stored user information.
    ///
    /// - Parameter dictUserProfile: It contains user information returning by API.
    func setUserDetails(_ data: NSDictionary) {
        //Fetch own server user detail information
//        if let dbUserDetail = data["data"] as? NSDictionary {
            let id = data.getStringValue(forKey: "id")
            let objUser = YZLoggedInUser.addUpdateEntity(key: "id", value: id)
            objUser.initWith(data)
            YZApp.shared.objLogInUser = objUser
            _appDelegate.saveContext()
//        }
    }
    
    /// It will call when user enable push notification.
    /// It will return device token from stored user default.
    ///
    /// - Returns: It's return APNSDeviceToken string value which is stored in userDefaults
    func getAPNSDeviceToken() -> String? {
        return _userDefaults.string(forKey: kAPNSDeviceToken)
    }
}

//MARK: - Utility
extension YZApp {
    
    /// Settings Version Maintenance & Localize text
    func getLocalizedText(_ key: String) -> String {
        if language == .english {
            return NSLocalizedString(key, tableName: "English", bundle: Bundle.main, value: "", comment: "")
        }else {
            return NSLocalizedString(key, tableName: "Spanish", bundle: Bundle.main, value: "", comment: "")
        }
    }
}

// MARK: - Attributed
extension NSAttributedString {
    
    // This will give combined string with respective attributes
    class func attributedText(texts: [String], attributes: [[NSAttributedString.Key : Any]]) -> NSAttributedString {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        return attbStr
    }
}

//MARK: - Class YZUserTapDelegate
/// It is used to get user tap event on text for tableCell, collectionCell, and headerFooter views.
@objc public protocol YZUserTapDelegate: class {
    @objc optional func didTapOn(_ text: String, tableCell: YZParentTVC?, anyObject: Any?)
    @objc optional func didTapOn(_ text: String, collectionCell: YZParentCVC?, anyObject: Any?)
    @objc optional func didTapOn(_ text: String, headerFooter: YZParentHFV?, anyObject: Any?)
}

/*---------------------------------------------------
 Facebook
 ---------------------------------------------------*/
struct FBConfig {
    static let facebookPermission              = ["public_profile", "email"]
    static let facebookMeUrl                   = "me"
    static let facebookAlbumUrl                = "me/albums"
    static let facebookUserField: [String:Any] = ["fields" : "id,first_name,last_name,email,picture.height(700)"]
    static let facebookJobSchoolField          = ["fields" : "education,work"]
    static let facebookAlbumField              = ["fields":"id,name,count,picture"]
    static let facebookPhotoField              = ["fields":"id,picture"]
}
