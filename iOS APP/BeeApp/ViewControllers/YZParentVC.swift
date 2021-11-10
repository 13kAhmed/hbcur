//
//  YZParentVC.swift
//
//

import UIKit

//MARK: - Enum YZTableViewMode
enum YZTableViewModeWith {
    case noRecords
    case records
    case searching
}

//MARK: - Class YZParentVC
class YZParentVC: UIViewController {
    //IBOutlet(s)
    @IBOutlet var tableView: UITableView!
    @IBOutlet var viewTopLayoutMargin: UIView?
//    @IBOutlet var viewNavigationBar: YZNavigationBarContainer?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet var viewBottomLayoutMargin: UIView?
    @IBOutlet var viewBottomBar: UIView?
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    static var storyboardIdentifier: String {return String(describing: self)}
    var completionBlock: ((_ isFinish: Bool, _ any: Any?, _ controller: UIViewController?)->())?
    var xActivityConstant: CGFloat!
    var yActivityConstant: CGFloat!
    
    lazy internal var loadMoreActivity : UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .white)
        activity.startAnimating()
        activity.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: YZAppConfig.width, height: CGFloat(44))
        return activity
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.white
        return refreshControl
    }()

    
    //Lazy Variables
    lazy internal var activityIndicator : UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .white)
        activity.color = UIColor.white
        return activity
    }()
    
    lazy internal var customActivityIndicator : YZActivityIndicator = {
        let activity = YZActivityIndicator(UIImage(named: "iconSpinner")!)
        return activity
    }()
    
    lazy internal var centralActivityIndicator : UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .white)
        activity.color = UIColor.white
        return activity
    }()
    
    lazy internal var nvActivityIndicator : NVActivityIndicatorView = {
        let activity = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballRotateChase, color: .darkGray, padding: 50)
        return activity
    }()
    
    deinit{
        removeParentKeyboardObserver()
        removeStatusbarObservers()
        yzPrint(items: "Deallocated: \(self.classForCoder)")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

//MARK: - UIViewController method(s) & Properties
extension YZParentVC {
    
    override var prefersStatusBarHidden: Bool {
        return _appDelegate.isStatusBarHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yzPrint(items: "Allocated: \(self.classForCoder)")
        addStatusbarObservers()
        constraintUpdate()
    }
}

//MARK: - YZNavigationBar
extension YZParentVC {
    
    @objc func navigationBarHandler() {
//        viewNavigationBar?.actionHandlerWith({[weak self](navigationBar, navigationAction, button) in
//            guard let weakSelf = self else{return}
//            if navigationAction == .popController {
//                weakSelf.navigationController?.popViewController(animated: true)
//            }else if navigationAction == .dismissController {
//                weakSelf.dismiss(animated: true, completion: nil)
//            }
//        })
    }
    
    @IBAction func onBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCloseTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - AddObserver(s)
extension YZParentVC {
    
    func addStatusbarObservers() {
        _defaultCenter.addObserver(self, selector: #selector(self.statusBarInLightContent(_:)), name: nfStatusBarInLight, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.statusBarInBlack(_:)), name: nfStatusBarInBlack, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.isHideStatusBar(_:)), name: nfHideStatusBar, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.isShowStatusBar(_:)), name: nfShowStatusBar, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.internetConnectionNotAvailable(_:)), name: nfInternetNotAvailable, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.internetConnectionAvailable(_:)), name: nfInternetAvailable, object: nil)
    }
    
    @objc func statusBarInLightContent(_ notification: Notification) {
        _appDelegate.statusBarStyle = notification.object as! UIStatusBarStyle
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func statusBarInBlack(_ notification: Notification) {
        _appDelegate.statusBarStyle = notification.object as! UIStatusBarStyle
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func isHideStatusBar(_ notification: Notification) {
        _appDelegate.isStatusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func isShowStatusBar(_ notification: Notification) {
        _appDelegate.isStatusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func internetConnectionNotAvailable(_ notification: Notification) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func internetConnectionAvailable(_ notification: Notification) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func removeStatusbarObservers() {
        _defaultCenter.removeObserver(self, name: nfStatusBarInLight, object: nil)
        _defaultCenter.removeObserver(self, name: nfStatusBarInBlack, object: nil)
        _defaultCenter.removeObserver(self, name: nfHideStatusBar, object: nil)
        _defaultCenter.removeObserver(self, name: nfShowStatusBar, object: nil)
        _defaultCenter.removeObserver(self, name: nfInternetNotAvailable, object: nil)
        _defaultCenter.removeObserver(self, name: nTimeCallBack, object: nil)
    }
}

//MARK: - UIRelated
extension YZParentVC {

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
    }

    //This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        xActivityConstant = nvActivityIndicator.frame.size.width/2
        yActivityConstant = nvActivityIndicator.frame.size.height/2

        //Horizontal constraings
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * YZAppConfig.widthRatio
                const.constant = v2
            }
        }
        //Verticle constraings
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * YZAppConfig.heightRatio
                const.constant = v2
            }
        }
    }
    
    func showOrHideTableView(_ shouldShow: Bool, isAnimated: Bool) {
        if shouldShow == true && isAnimated == true {
            tableView.alpha = 0.0
            tableView.isHidden = false
            YZAnimation.fadeIn(view: tableView, outView: nil, completionBlock: nil)
        }else if shouldShow == false && isAnimated == false {
            tableView.alpha = 0.0
            tableView.isHidden = true
        }else if shouldShow == true && isAnimated == false {
            tableView.alpha = 1.0
            tableView.isHidden = false
        }else if shouldShow == false && isAnimated == true {
            tableView.alpha = 1.0
            tableView.isHidden = false
            YZAnimation.fadeIn(view: nil, outView: tableView, completionBlock: nil)
        }
    }
}

//MARK: - UITableView
extension YZParentVC {
    
    func getTableViewCell(row: Int, section: Int) -> UITableViewCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: section))
        return cell
    }
    
    func reloadTableView() {
        if tableView != nil {
            tableView.reloadData()
        }
    }
}

//MARK: - UIActivityIndicator(s)
extension YZParentVC {
    
    /// Show indicator in center of any view(which pass in this method as container)
    /// During activity it will disable user intraction
    ///
    /// - Parameters:
    ///   - container: Container view which contains, indicator view.
    ///   - control: Control which hides when indicator display.
    ///   - color: Color which apply on indicator.
    func showIndicatorIn(_ container: UIView, control: UIView, color: UIColor = .white) {
        activityIndicator.color = color
        container.addSubview(activityIndicator)
        let xConstraint = NSLayoutConstraint(item: self.activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: self.activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        self.activityIndicator.alpha = 0.0
        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            control.alpha = 0.0
        }
    }
    
    /// Hide activity indicator from center of any view(which pass in this method as container)
    /// Enable user intraction after activity completed
    ///
    /// - Parameters:
    ///   - container: Container view which contains, indicator view.
    ///   - control: Control which hides when indicator display.
    func hideIndicatorFrom(_ container: UIView, control: UIView) {
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }) { (isFinish) in
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    /// Show custom indicator in center of any view(which pass in this method as container)
    /// During activity it will disable user intraction
    ///
    /// - Parameters:
    ///   - container: Container view which contains, indicator view.
    ///   - control: Control which hides when indicator display.
    ///   - color: Color which apply on indicator.
    func showCustomIndicatorIn(_ container: UIView, control: UIView, color: UIColor = .white) {
        customActivityIndicator.tintColor = color
        container.addSubview(customActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: self.customActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: -xActivityConstant)
        let yConstraint = NSLayoutConstraint(item: self.customActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: -yActivityConstant)
        self.customActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        self.customActivityIndicator.alpha = 0.0
        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        self.customActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.customActivityIndicator.alpha = 1.0
            control.alpha = 0.0
        }
    }
    
    /// Hide custom activity indicator from center of any view(which pass in this method as container).
    /// Enable user intraction after activity completed.
    ///
    /// - Parameters:
    ///   - container: Container view which contains, indicator view.
    ///   - control: Control which hides when indicator display.
    func hideCustomIndicatorFrom(_ container: UIView, control: UIView) {
        self.view.isUserInteractionEnabled = true
        self.customActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.customActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }) { (isFinish) in
            self.customActivityIndicator.removeFromSuperview()
        }
    }
    
    /// Show custom indicator in center of view.
    /// During activity it will disable user intraction.
    ///
    /// - Parameters:
    ///   - color: Color which apply on indicator.
    func showIndicatorInCenter(_ color: UIColor = .white) {
        activityIndicator.color = color
        view.addSubview(activityIndicator)
        DispatchQueue.main.async {
            let xConstraint = NSLayoutConstraint(item: self.activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            let yConstraint = NSLayoutConstraint(item: self.activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
            self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([xConstraint, yConstraint])
            self.activityIndicator.alpha = 0.0
            self.view.layoutIfNeeded()
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.startAnimating()
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.activityIndicator.alpha = 1.0
            }
        }
    }
    
    /// Hide custom activity indicator from center of any view.
    /// Enable user intraction after activity completed
    func hideIndicatorFromCenter() {
        view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.alpha = 0.0
        }) { (isFinish) in
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    /// Show NVActivityIndicator in center of screen #colorLiteral(red: 0.9999160171, green: 1, blue: 0.9998719096, alpha: 1)
    func showCentralNVActivity(_ color: UIColor = UIColor.init("#39396A")) {
        nvActivityIndicator.padding = 50
        nvActivityIndicator.color = color
        self.view.addSubview(self.nvActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: self.nvActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: self.nvActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: self.nvActivityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40)
        let width = NSLayoutConstraint(item: self.nvActivityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 40)
        self.nvActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint, height, width])
        self.nvActivityIndicator.alpha = 0.0
        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        self.nvActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.nvActivityIndicator.alpha = 1.0
        }
    }
    
    /// Hide activity indicator in center of any view(which pass in this method as container)
    func hideCentralNVActivity() {
        view.isUserInteractionEnabled = true
        self.nvActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.nvActivityIndicator.alpha = 0.0
            
        }) { (isFinish) in
            self.nvActivityIndicator.removeFromSuperview()
        }
    }

    /// Show indicator in center of any view(which pass in this method as container)
    /// During activity it will disable user intraction
    ///
    /// - Parameters:
    ///   - container: Container view which contains, indicator view.
    ///   - control: Control which hides when indicator display.
    ///   - color: Color which apply on indicator.
    func showNVIndicatorIn(_ container: UIView, control: UIView, color: UIColor = .white) {
        nvActivityIndicator.padding = 20
        xActivityConstant = nvActivityIndicator.frame.size.width/2
        yActivityConstant = nvActivityIndicator.frame.size.height/2
        nvActivityIndicator.color = color
        container.addSubview(nvActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: self.nvActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: -xActivityConstant)
        let yConstraint = NSLayoutConstraint(item: self.nvActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: -yActivityConstant)
        self.nvActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        self.nvActivityIndicator.alpha = 0.0
        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        self.nvActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.nvActivityIndicator.alpha = 1.0
            control.alpha = 0.0
        }
    }
    
    /// Hide activity indicator from center of any view(which pass in this method as container).
    /// Enable user intraction after activity completed.
    ///
    /// - Parameters:
    ///   - container: Container view which contains, indicator view.
    ///   - control: Control which hides when indicator display.
    func hideNVIndicatorFrom(_ container: UIView, control: UIView) {
        self.view.isUserInteractionEnabled = true
        self.nvActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2, animations: {
            self.nvActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }) { (isFinish) in
            self.nvActivityIndicator.removeFromSuperview()
        }
    }
}

//MARK: - UINavigation
extension YZParentVC {
    
}

//MARK: - Utility
extension YZParentVC {
    
}

//MARK: - UIResponder
extension YZParentVC {
    
    func addParentKeyboardObservers() {
        _defaultCenter.addObserver(self, selector: #selector(parentKeyboardWillChangeFrame), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(parentKeyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(parentKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func parentKeyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                YZApp.shared.keyboardHeight = keyboardSize.height
            }
        }
    }
    
    @objc func parentKeyboardWillChangeFrame(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let newFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            yzPrint(items: #function + " : " + newFrame.debugDescription)
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: newFrame.height + 10, right: 0)
            tableView.contentInset = contentInset
            tableView.scrollIndicatorInsets = contentInset
        }else{
            yzPrint(items: #function + " : NO FRAME FOUND.")
        }
    }
    
    @objc func parentKeyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets(top: .zero, left: 0, bottom: 0, right: 0)
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    func removeParentKeyboardObserver() {
        _defaultCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        _defaultCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
