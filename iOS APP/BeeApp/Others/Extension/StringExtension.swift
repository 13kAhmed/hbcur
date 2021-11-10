//
//  StringExtension.swift
//

import UIKit
import PhoneNumberKit

//MARK: - Validation
extension String {
    
    var isNumericField: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
    
    var isNameValid: Bool {
        return trimmedString.isEmpty == false && count >= 1
    }

    var isPasswordValid: Bool {
        return trimmedString.isEmpty == false && count >= 8
    }
    
    var isPhoneValid: Bool {
        return trimmedString.isEmpty == false && count >= 6
    }
    
    static func randomStringIn(_ length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    var addSpace:String {
        return self + " "
    }
    
    func withReplacedCharacters(_ oldChar: String, by newChar: String) -> String {
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
    
    func isValidMobileNumber() -> Bool {
        let numkit = PhoneNumberKit()
        do{
            let mobile = try numkit.parse(self, ignoreType: true)
            yzPrint(items: "Mobile number : \(mobile.numberString)")
            return true
        }catch{
            return false
        }
    }

    var trimmingWhiteSpaces: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
}
