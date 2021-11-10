//
//  CountryPickerVC.swift
//  BeeApp
//
//  Created by iOSDev on 23/04/21.
//

import UIKit

class CountryPickerVC: YZParentVC {
    
    var actionBlock : ((_ text: Country) -> ())?
    var arrCountryData: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForFillData()
        registerNIBs()
    }
}

//MARK:- UI Related
extension CountryPickerVC {
    func registerNIBs() {
        tableView.register(CountryPickerCell.nib, forCellReuseIdentifier: CountryPickerCell.identifier)
    }
    
    func prepareForFillData() {
        arrCountryData = Country.getCountryList()
    }
}

//MARK:- Actions
extension CountryPickerVC {
    func handleBlockAction(_ block: @escaping (_ text: Country) -> ()){
        actionBlock = block
    }
}

extension CountryPickerVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCountryData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CountryPickerCell.identifier, for: indexPath) as! CountryPickerCell
        cell.objCountry = arrCountryData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actionBlock?(arrCountryData[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
