//
//  YZAnimation.swift
//

import UIKit

//MARK: - YZAnimation
class YZAnimation: NSObject {
    
    //Spring in animation
    class func springInAnimation(view: UIView, duration: TimeInterval = 0.7, completionBlock: ((Bool) -> ())?) {
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8.0, options: .allowUserInteraction, animations: {
            view.transform = .identity
        }) { (isFinished: Bool) in
            DispatchQueue.main.async {
                completionBlock?(isFinished)
            }
        }
    }

    //Spring out animation
    class func springOutAnimation(view: UIView, duration: TimeInterval = 0.7, completionBlock: ((Bool) -> ())?) {
        view.transform = CGAffineTransform.identity
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 8.0, options: .allowUserInteraction, animations: {
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (isFinished: Bool) in
            DispatchQueue.main.async {
                completionBlock?(isFinished)
            }
        }
    }

    //Fade in/out animation
    class func fadeIn(view: UIView?, outView: UIView?, duration: TimeInterval = 0.3, completionBlock: ((Bool) -> ())?) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            view?.alpha = 1.0
            outView?.alpha = 0.0
        }) { (isFinished: Bool) in
            DispatchQueue.main.async {
                completionBlock?(isFinished)
            }
        }
    }
    
    class func fadeIn(forView view: UIView, color: UIColor, duration: TimeInterval = 0.3, completionBlock: ((Bool) -> ())?) {
        UIView.animate(withDuration: duration, animations: {
            view.backgroundColor = color
        }) { (isFinished: Bool) in
            DispatchQueue.main.async {
                completionBlock?(isFinished)
            }
        }
    }
    
    //Rotation animation
    class func rotate(view: UIView, toValue: CGFloat = (3.14 * 2.0), repeatCount: Float = HUGE, duration: CFTimeInterval = 1.0) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.repeatCount = repeatCount
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.fromValue = 0.0
        animation.toValue = toValue
        view.layer.add(animation, forKey: "rotate")
    }
    
    class func rotate(layer: CALayer, toValue: CGFloat = (3.14 * 2.0), duration: CFTimeInterval = 1.0) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.repeatCount = HUGE
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.fromValue = 0.0
        animation.toValue = toValue
        layer.add(animation, forKey: "rotate")
    }
    
    class func rotate(view: UIView, fromValue: CGFloat = 0.0, toValue: CGFloat = (3.14 * 2.0), duration: CFTimeInterval = 1.0, isRepeat: Bool = true) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.repeatCount = isRepeat ? HUGE : 1
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.fromValue = fromValue
        animation.toValue = toValue
        view.layer.add(animation, forKey: "rotate")
    }
    
    class func rotate(view: UIView, angle: CGFloat) {
        let radians = angle/180.0 * CGFloat.pi
        view.transform = CGAffineTransform(rotationAngle: radians)
    }
}
