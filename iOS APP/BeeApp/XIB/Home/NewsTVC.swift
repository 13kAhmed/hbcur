//
//  NewsTVC.swift
//  BeeApp
//
//  Created by iOSDev on 20/04/21.
//

import UIKit
import SafariServices

class NewsTVC: YZParentTVC {

    @IBOutlet weak var imgMain: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    weak var parentVC: HomeVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var newsModel: NewsModel? {
        didSet {
            setData()
        }
    }
    func setData() {
        guard let model = newsModel else { return }
        imgMain.setImageWith(model.imageURL, placeholder: UIImage(named: "iconUserPlaceholder"), completionBlock: nil)
        lblTitle.text = model.title
        lblDate.text = model.strDate
    }
    
    @IBAction func btnMorePressed(_ sender: UIButton) {
        guard let model = newsModel else { return }
        
        if let url = URL(string: model.urlNews) {
            let safariVC = SFSafariViewController(url: url)
            parentVC.present(safariVC, animated: true, completion: nil)
        }
    }
}
