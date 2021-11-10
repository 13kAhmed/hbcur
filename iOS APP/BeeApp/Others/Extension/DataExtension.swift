//
//  DataExtension.swift
//

import UIKit

//MARK: -
extension Data {

    var deviceTokenInString: String {
        return "\(reduce("", {$0 + String(format: "%02X", $1)}))"
    }
}
