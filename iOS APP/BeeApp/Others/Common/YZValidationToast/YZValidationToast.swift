//
//  YZValidationToast.swift
//

import UIKit

//MARK: - Class YZValidationToast
//It will use to display toast view with message
class YZValidationToast {
    
    static var shared = YZValidationToast()
    
    init() {
       
    }
    
//    @discardableResult func showOnStatusBar(_ message: String, font: UIFont = .segoeUIBold(ofSize: 14), color: UIColor = .TOASTERROR, autoHide: Bool = true) {
//        let toast = UINib(nibName: "YZValidationToastView", bundle: nil).instantiate(withOwner: nil, options: nil)[ScreenSize.safeAreaInsets.top > 20 ? 1 : 0] as! YZValidationToastView
//
//    }
    
    /// It will use to display toast message on status bar
    ///
    /// - Parameters:
    ///   - message: Message in string to display on status bar.
    ///   - font: Font to apply on toast message.
    ///   - color: UIColor for toast background.
    ///   - autoHide: Boolean value for toast is automatically hide or not. If yes then hide automatically else you need to manually hide using YZValidationToast type object.
    /// - Returns: YZValidationToast type object.
    @discardableResult func showToastOnStatusBar(_ message: String, font: UIFont = UIFont.systemFont(ofSize: 14), color: UIColor = UIColor.TOASTERROR!, autoHide: Bool = true) -> YZValidationToastView {
        let toast = UINib(nibName: "YZValidationToastView", bundle: nil).instantiate(withOwner: nil, options: nil)[YZAppConfig.safeAreaInsets.top > 20 ? 1 : 0] as! YZValidationToastView
        let messageHeight = message.heightForFixed((YZAppConfig.width - 16), font: font)
        let height = (((YZAppConfig.safeAreaInsets.top + messageHeight + 20) < YZAppConfig.heightOfNavigationBar) ? (YZAppConfig.heightOfNavigationBar) : (YZAppConfig.safeAreaInsets.top + messageHeight + 20))
        toast.animatingViewBottomConstraint.constant = height
        toast.animatingView.backgroundColor = color
        toast.setToastMessage(message, font: font)
        _appDelegate.window?.addSubview(toast)
        var newFrame = CGRect.zero
        newFrame = UIScreen.main.bounds
        newFrame.size.height = height
        toast.frame = newFrame
        toast.layoutIfNeeded()
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
            if autoHide {
                toast.animateOut(duration: 0.2, delay: 3.0, completion: { () -> () in
                    toast.removeFromSuperview()
                })
            }
        })
        return toast
    }
}

//MARK: - Class YZValidationToastView
//It will graphics represented views.
class YZValidationToastView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var animatingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var animatingView: UIView!
    
    deinit {
        yzPrint(items: "YZValidationToastView Deallocated")
    }
    
    // MARK: Toast Functions
    
    /// It will set message on UILabel
    ///
    /// - Parameters:
    ///   - message: String type parameter
    ///   - font: UIFont type parameter
    func setToastMessage(_ message: String, font: UIFont) {
        messageLabel.text = message
    }
    
    // MARK: Toast Functions

    /// It will display toast message with animation.
    ///
    /// - Parameters:
    ///   - duration: TimerInterval for animation execution
    ///   - delay: TimerInterval for start animation after some delay
    ///   - completion: Block handler
    func animateIn(duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                completion?()
        }
    }
    
    /// It will hide toast message with animation.
    ///
    /// - Parameters:
    ///   - duration: TimerInterval for animation execution
    ///   - delay: TimerInterval for start animation after some delay
    ///   - completion: Block handler
    func animateOut(duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = frame.size.height
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                completion?()
        }
    }
}
