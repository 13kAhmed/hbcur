//
//  CountryPickerCell.swift
//  SocietyApp
//
//

import UIKit

class CountryPickerCell: YZParentTVC {

    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    
    var objCountry: Country! {
        didSet{
             prepareUI(objCountry)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepareUI(_ obj: Country) {
        imgFlag.image = UIImage(named: obj.imageName)
        lblTitle.text = obj.name
        lblCode.text = obj.displayPhoneCode
    }
    
}
