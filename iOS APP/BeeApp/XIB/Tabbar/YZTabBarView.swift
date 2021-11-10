//
//  YZTabBarView.swift
//


import UIKit

//MARK: - Enum YZTabBarOption
enum YZTabBarOption: Int {
    case first = 0
    case second = 1
    case third = 2
    case fourth = 3
    case unknown = 4
}

//MARK: - Protocol YZTabBarDelegate
protocol YZTabBarDelegate: class {
    func didTapOnTab(_ option: YZTabBarOption?)
}

//MARK: - Class YZTabBarView
class YZTabBarView: YZParentView {
    @IBOutlet weak var viewStackContainer: UIView!
    @IBOutlet weak var viewStack: UIStackView!
    @IBOutlet weak var viewFirst: UIView?
    @IBOutlet weak var btnFirst: UIButton?
    @IBOutlet weak var imgVFirst: UIImageView?
    @IBOutlet weak var viewSecond: UIView?
    @IBOutlet weak var btnSecond: UIButton?
    @IBOutlet weak var imgVSecond: UIImageView?
    @IBOutlet weak var viewThird: UIView?
    @IBOutlet weak var btnThird: UIButton?
    @IBOutlet weak var imgVThird: UIImageView?
    @IBOutlet weak var viewFourth: UIView?
    @IBOutlet weak var btnFourth: UIButton?
    @IBOutlet weak var imgVForth: UIImageView?
    weak var delegate: YZTabBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

//MARK: IBAction(s)
extension YZTabBarView {

    @IBAction func onTabTap(_ sender: UIButton) {
        let objTabBarOption = YZTabBarOption(rawValue: sender.tag)
        selectedTab(objTabBarOption)
        delegate?.didTapOnTab(objTabBarOption)
    }
}

//MARK: Other(s)
extension YZTabBarView {
    
    //Prepare all tabs in default states.
    func setTabDefaultState(){
        imgVFirst?.isHighlighted = false
        imgVSecond?.isHighlighted = false
        imgVThird?.isHighlighted = false
        imgVForth?.isHighlighted = false
    }

    //Prepare view as per selected tab.
    func selectedTab(_ tabOption: YZTabBarOption?){
        setTabDefaultState()
        switch tabOption {
        case .first:
            imgVFirst?.isHighlighted = true
        case .second:
            imgVSecond?.isHighlighted = true
        case .third:
            imgVThird?.isHighlighted = true
        case .fourth:
            imgVForth?.isHighlighted = true
        default:
            fatalError(#function + " NO MORE TAB OPTION.")
        }
    }
}
