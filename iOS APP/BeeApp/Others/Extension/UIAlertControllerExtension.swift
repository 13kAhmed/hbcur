//
//  UIAlertControllerExtension.swift
//

import UIKit

//MARK: - UIAlertController Extension(s)
extension UIAlertController {
    
    static func show(with locationInfo: UIView? = nil, title: String?, message: String?, style: UIAlertController.Style, buttons: [String], controller: UIViewController?, userAction: ((_ action: String) -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        buttons.forEach { (buttonTitle) in
            if buttonTitle == YZApp.shared.getLocalizedText("cancel") {
                alertController.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {userAction?(buttonTitle)}
                }))
            }else{
                alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {userAction?(buttonTitle)}
                }))
            }
        }
        
        if let locationInfo = locationInfo, let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = locationInfo
            popoverController.sourceRect = locationInfo.frame
        }
        
        if let parentController = controller {
            DispatchQueue.main.async {
                parentController.present(alertController, animated: true, completion: nil)
            }
        }else{
            _appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
}
