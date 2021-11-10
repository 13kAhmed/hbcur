//
//  UIFontExtension.swift
//

import UIKit

//MARK: -
extension UIFont {

    /*
     Font Family Name = [Cera Basic]
     Font Names = [["CeraBasic-Bold", "CeraBasic-Regular", "CeraBasic-Black", "CeraBasic-RegularItalic"]]
     Font Names = [["RobotoMono-Regular", "RobotoMono-Italic", "RobotoMono-ExtraLight", "RobotoMono-Thin", "RobotoMono-ExtraLightItalic", "RobotoMono-ThinItalic", "RobotoMono-Light", "RobotoMono-LightItalic", "RobotoMono-Medium", "RobotoMono-MediumItalic", "RobotoMono-SemiBold", "RobotoMono-SemiBoldItalic", "RobotoMono-Bold"]]

    */
    
    @objc static func roboto(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoMono-Regular", size: size)!
    }
    
    @objc static func robotoBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoMono-Bold", size: size)!
    }
        
    @objc static func robotoMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoMono-Medium", size: size)!
    }
}
