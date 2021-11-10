
//
//  YZPickerTF.swift
//  YZClasses
//
//  Created by Kshitij on 19/02/21.
//

import UIKit

public typealias YZPickerActionBlock = (_ anyObject: Any?, _ component: Int?, _ row: Int?, _ isFinish: Bool) -> Void
public typealias YZDatePickerBlock = (_ date : Date , _ strDate : String, _ isDone : Bool) -> Void

//MARK: - Class YZPickerTF
public class YZPickerTF: UITextField {
    public var arrOfPickerItems = Array<Any>()
    var arrOfItems: [String] = [String]()
    public var pickerBlock: YZPickerActionBlock?
    public var datePickerBlock : YZDatePickerBlock?
    public var selectedComponent = 0
    public var selectedRow = 0
    public var viewPicker: UIPickerView?
    public var datePicker: UIDatePicker?
    public var isAutoCompleted: Bool = false //It will describe to set UITextField is autocomplete when UIPickerItem Changed or Input accessory Tap.
    let dateFormatter = DateFormatter()
    let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
}

//MARK: Override Method(s)
extension YZPickerTF {
    
    public override func awakeFromNib() {super.awakeFromNib()}
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {return false}
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {return bounds.inset(by: padding)}
    
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {return bounds.inset(by: padding)}
    
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {return bounds.inset(by: padding)}
}

//MARK: UIRelated
extension YZPickerTF {
    
    /// It is used to display `UIDatePicker` component.
    /// - Parameters:
    ///   - mode: `UIDatePicker.Mode` type value, to set date picker mode.
    ///   - minDate: `Date` type object, to set minimum date.
    ///   - maxDate: `Date` type object, to set maximum date.
    ///   - dateFormat: `String` type value.
    ///   - autoCompleted: `Bool` type value.
    ///   - block: `YZDatePickerBlock` completion block to handle events.
    public func setDatePicker(_ mode: UIDatePicker.Mode ,
                              minDate: Date? = nil,
                              maxDate: Date? = nil,
                              dateFormat: String,
                              autoCompleted: Bool,
                              block: YZDatePickerBlock?) {
        
        datePickerBlock = block
        dateFormatter.dateFormat = dateFormat
        isAutoCompleted = autoCompleted
        guard let _ = datePicker else {
            datePicker = UIDatePicker(frame: CGRect(x:0, y: 0, width: YZAppConfig.width, height: 200))
            datePicker?.backgroundColor = .white
            datePicker?.datePickerMode = mode
            if let minDate = minDate {
                datePicker?.minimumDate = minDate
            }
            if let maxDate = maxDate {
                datePicker?.maximumDate = maxDate
            }
            datePicker?.addTarget(self, action: #selector(self.dateChanged(_:)), for: .valueChanged)
            inputView = datePicker

            return
        }
    }
    
    @objc fileprivate func dateChanged(_ sender: UIDatePicker) {
        if isAutoCompleted {
            text = dateFormatter.string(from: (datePicker?.date)!)
            datePickerBlock?(sender.date, dateFormatter.string(from: sender.date), false)
        }
    }
    
    /// It is used to display `UIPickerView` component.
    /// - Parameters:
    ///   - data: `[Any]` type object, to display data on `UIPickerView`.
    ///   - autoCompleted: `Bool` type value.
    ///   - block: `YZPickerActionBlock` completion block to handle events.
    public func setPicker(_ data: [Any],
                          autoCompleted: Bool,
                          block: @escaping YZPickerActionBlock) {
        guard let _ = viewPicker else {
            pickerBlock = block
            isAutoCompleted = autoCompleted
            arrOfPickerItems = data
            viewPicker = UIPickerView()
            viewPicker?.backgroundColor = .white
            viewPicker?.delegate = self
            viewPicker?.dataSource = self
            inputView = viewPicker
            return
        }
    }
    
    /// It is used to add input accessory view to `UITextField`.
    /// - Parameters:
    ///   - text: `String` type value to define accessory `UIBarButtonItem` text.
    ///   - textFont: `UIFont` type object to define accessory `UIBarButtonItem` font.
    ///   - tintColor: `UIColor` tyepe object to set tint color of accessory `UIBarButtonItem`
    ///   - rect: `CGRect` type object to set frame of accessory `UIBarButtonItem`.
    public func addPickerInputAccessory(_ text: String, textFont: UIFont, tintColor: UIColor? = nil, rect: CGRect = .zero) {
        let barButtonItem: UIBarButtonItem = UIBarButtonItem(title: text, style: .done, target: self, action: #selector(onPickerBarButtonItemTap(_:)))
        barButtonItem.tintColor = tintColor
        let doneToolbar: UIToolbar = UIToolbar(frame: rect)
        doneToolbar.barStyle = .default
        doneToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), barButtonItem]
        doneToolbar.sizeToFit()
        inputAccessoryView = doneToolbar
    }
    
    @objc fileprivate func onPickerBarButtonItemTap(_ sender: UIBarButtonItem) {
        _ = resignFirstResponder()
        if let _ = viewPicker {
            if arrOfPickerItems.isEmpty == false {
                pickerBlock?(arrOfPickerItems[selectedRow], selectedComponent, selectedRow, true)
                text = String(describing: arrOfPickerItems[selectedRow])
            }
        } else if let datePicker = datePicker {
            datePickerBlock?(datePicker.date, dateFormatter.string(from: datePicker.date), true)
            text = dateFormatter.string(from: datePicker.date)
        }
    }
    
    public func refresh(_ items: [Any]) {
        arrOfPickerItems = items
        viewPicker?.reloadAllComponents()
        viewPicker?.selectRow(0, inComponent: 0, animated: false)
        selectedComponent = 0
        selectedRow = 0
        text = nil
    }
}

//MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension YZPickerTF: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrOfPickerItems.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: arrOfPickerItems[row])
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedComponent = component
        selectedRow = row
        if arrOfPickerItems.isEmpty == false && isAutoCompleted {
            text = String(describing: arrOfPickerItems[selectedRow])
            pickerBlock?(arrOfPickerItems[selectedRow] as Any,selectedComponent,selectedRow,false)
        }
    }
}
