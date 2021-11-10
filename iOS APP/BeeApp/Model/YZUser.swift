//
//  YZUser.swift
//  BeeApp
//
//  Created by iOSDev on 23/04/21.
//

import UIKit

class Country {
    var code: String!
    var name: String!
    var phoneCode: String!
    var nativeName:String!
    var flag:String!
    var imageName: String!
    
    var displayPhoneCode:String {
        return phoneCode
    }
    
    var URLOfFlag:URL? {
        return URL(string: flag)
    }
    
    var imgName: String {
        if let url = URLOfFlag {
            let name = url.lastPathComponent.withReplacedCharacters(".svg", by: "")
            return String(name.prefix(2))
        }
        return ""
    }
    
    // New Json file
    init(dictCountry: NSDictionary) {
        name = dictCountry.getStringValue(forKey: "name").trimmedString
        if let codes = dictCountry["callingCodes"] as? [String], let dialCode = codes.first {
            phoneCode = dialCode
        } else {
            phoneCode = "-"
        }
        code = dictCountry.getStringValue(forKey: "alpha2Code").trimmedString
        nativeName = dictCountry.getStringValue(forKey: "nativeName")
        flag = dictCountry.getStringValue(forKey: "flag")
        imageName = dictCountry.getStringValue(forKey: "alpha2Code").lowercased()
    }
    
    static func != (leftObj: Country,rightObj: Country) -> Bool{
        return leftObj.phoneCode != rightObj.phoneCode
    }
    
    // MARK:- Get Country List
    class func getCountryList() -> [Country] {
        if let contryPath = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: contryPath))
                var countries : [Country] = []
                if let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary] {
                    for dictCountry in dict {
                        countries.append(Country(dictCountry: dictCountry))
                    }
                }
                return countries
                
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
        }
        return []
    }
}

//
//  YZUser.swift
//

import Foundation
import CoreData
import UIKit

// MARK:- Enum YZUserType
enum YZUserType: String {
    case customer = "customer"
    case worker = "worker"
    case unknown = "unknown"
}

//MARK: - Struct YZLogIn
struct YZLogIn {
    var email: String
    var password: String
    var requestParameters: [String : Any] {
        return ["email" : email, "password" : password]
    }
    
    init() {
        self.email = ""
        self.password = ""
    }
}

// MARK:- Class YZLoggedInUser
class YZLoggedInUser: NSManagedObject, YZParentMO {
    @NSManaged var id: String
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var mobileNumber: String
    @NSManaged var countryCode: String
    @NSManaged var imageUrl: String
    @NSManaged var invitationCode: String
    @NSManaged var nationality: String
    @NSManaged var userName: String
    @NSManaged var signupType: String
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    func initWith(_ dictUserInfo: NSDictionary) {
        id = dictUserInfo.getStringValue(forKey: "id")
        firstName = dictUserInfo.getStringValue(forKey: "first_name")
        lastName = dictUserInfo.getStringValue(forKey: "last_name")
        mobileNumber = dictUserInfo.getStringValue(forKey: "mobile")
        countryCode = dictUserInfo.getStringValue(forKey: "country_code")
        imageUrl = dictUserInfo.getStringValue(forKey: "avtar")
        invitationCode = dictUserInfo.getStringValue(forKey: "invitation_code")
        nationality = dictUserInfo.getStringValue(forKey: "nationality")
        userName = dictUserInfo.getStringValue(forKey: "username")
        signupType = dictUserInfo.getStringValue(forKey: "signup_type")
    }
}
