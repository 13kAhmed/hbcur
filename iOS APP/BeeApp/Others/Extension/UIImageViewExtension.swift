//
//  UIImageViewExtension.swift
//

import UIKit
import Kingfisher

//MARK: -
extension UIImageView {

    func setImageWith(_ url: URL?, placeholder: UIImage? = nil, completionBlock: ((Bool, UIImage?, String?)->())? = nil) {
        kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.3))], progressBlock: nil) { (result) in
            switch result {
            case .success(let value):
                completionBlock?(true, value.image, nil)
            case .failure(let error):
                completionBlock?(false, nil, error.localizedDescription)
            }
        }
    }
}
