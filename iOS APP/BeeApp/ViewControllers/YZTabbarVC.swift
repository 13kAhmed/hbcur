//
//  YZTabbarVC.swift
//  BeeApp
//
//  Created by iOSDev on 19/04/21.
//

import UIKit

class YZTabbarVC: UITabBarController {
    var viewTabBar: YZTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //initialiseTabBarView
        initialiseTabBarView()

        // Do any additional setup after loading the view.
    }
}

//MARK: - UIRelated
extension YZTabbarVC {
    
    //Initialise custom YZTabBarView and add to native tabBar.
    func initialiseTabBarView() {
        if viewTabBar == nil {
            viewTabBar = Bundle.main.loadNibNamed("YZTabBarView", owner: self, options: nil)![0] as? YZTabBarView
            viewTabBar.delegate = self
            viewTabBar.frame = CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
            viewTabBar.setTabDefaultState()
            viewTabBar.selectedTab(.first)
            tabBar.shadowImage = nil
            tabBar.clipsToBounds = true
            tabBar.addSubview(viewTabBar)
            tabBar.layoutIfNeeded()
        }
    }
    
    func selectFromOutSide(_ tabOption: YZTabBarOption?) {
        viewTabBar.selectedTab(tabOption)
        didTapOnTab(tabOption)
    }
}

//MARK: - UIButton action(s)
extension YZTabbarVC: YZTabBarDelegate {
    
    func didTapOnTab(_ option: YZTabBarOption?) {
        if let option = option {
            switch option {
            case .first:
                selectedIndex = 0
            case .second:
                selectedIndex = 1
            case .third:
                selectedIndex = 2
            case .fourth:
                selectedIndex = 3
            default:
                fatalError("NO MORE TABs.")
            }
        }
    }
}
