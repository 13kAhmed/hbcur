//
//  SegmentHFV.swift
//  BeeApp
//
//  Created by iOSDev on 20/04/21.
//

import UIKit

class SegmentHFV: YZParentHFV {
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    @IBOutlet weak var _leadingLblBar: NSLayoutConstraint!
    
    var delegate: YZUserTapDelegate?
    
    var normalFont: UIFont = UIFont.robotoMedium(ofSize: 16)
    var selectedFont: UIFont = UIFont.robotoBold(ofSize: 16)
    var selectedSegment = 0 {
        didSet {
            updateSegment()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension SegmentHFV {
    
    func prepareTitles(_ titles:[String]) {
        lblFirst.text = YZApp.shared.getLocalizedText(titles.first!)
        lblSecond.text = YZApp.shared.getLocalizedText(titles.last!)
    }
    
    func updateSegment() {
        lblFirst.font = normalFont
        lblSecond.font = normalFont
        if selectedSegment == 0 {
            lblFirst.font = selectedFont
            _leadingLblBar.constant = 0
        } else {
            lblSecond.font = selectedFont
            _leadingLblBar.constant = (self.frame.width) / 2
        }
    }
}

//MARK: UIActions
extension SegmentHFV {
    @IBAction func onChangeValue(_ sender: UIButton) {
        delegate?.didTapOn?(sender.tag.description, headerFooter: self, anyObject: nil)
    }
}
