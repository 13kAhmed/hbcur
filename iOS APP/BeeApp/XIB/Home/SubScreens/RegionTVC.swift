//
//  RegionTVC.swift
//  BeeApp
//
//  Created by iOSDev on 21/04/21.
//

import UIKit

class RegionTVC: YZParentTVC {
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var countryModel: CountryModel? {
        didSet {
            setData()
        }
    }
    
    func setData() {
        guard let model = countryModel else { return }
        lblName.text = model.name
    }
}
