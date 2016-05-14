//
//  DataPickerView.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 03.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol DataPickerViewDelegate: class {
  func dataPicker(picker: DataPickerView, didPickValues values: [String])
  func dataStillNeeded(fromPicker picker: DataPickerView) -> Bool
}

class DataPickerView: UIView {
  
  weak var view: UIView!
  @IBOutlet weak var pickerView: UIPickerView!
  weak var delegate: DataPickerViewDelegate?
  
  let minCircularRows = 300
  let minCircularRowsMultiplier = 3
  
  var font = UIFont.systemFontOfSize(17.0)
  var textColor = UIColor.blackColor()
  
  var rowsInComponent: [Int] = []
  var options: [[String]] = [] {
    didSet {
      rowsInComponent = []
      for component in 0..<options.count {
        rowsInComponent.append(circularNumberOfRowsFor(numberOfSourceRows: options[component].count))
      }
    }
  }
  var initialValues: [String] = []
  var selectedValues: [String] = []
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
  }
  
  
  func xibSetup() {
    view = loadViewFromNib()
    view.frame = bounds
    view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    addSubview(view)
    
    pickerView.dataSource = self
    pickerView.delegate = self
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: "DataPickerView", bundle: bundle)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    return view
  }
  
  func configure(withOptions options: [[String]], andInitialValues initialValues: [String], andDelegate delegate: DataPickerViewDelegate) {
    self.options = options
    self.initialValues = initialValues
    self.delegate = delegate
    pickerView.reloadAllComponents()
    setPickerToValues(initialValues)
  }
  
  func setPickerToValues(initialValues: [String]) {
    for component in 0..<initialValues.count {
      if let rowInd = options[component].indexOf(initialValues[component]) {
        let row = ( rowsInComponent[component] / options[component].count / 2 ) * options[component].count + rowInd
        pickerView.selectRow(row, inComponent: component, animated: true)
      }
    }
  }
  
  func cleanAllData() {
    rowsInComponent = []
    options = []
    initialValues = []
    selectedValues = []
  }
  
}

extension DataPickerView: UIPickerViewDataSource {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return rowsInComponent.count
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return rowsInComponent[component]
  }
  
  // число рядов таким образом, чтобы барабан выглядит зацикленным
  func circularNumberOfRowsFor(numberOfSourceRows rows: Int) -> Int {
    var circularRows = 0
    if rows >= minCircularRows {
      circularRows = rows * minCircularRowsMultiplier
    } else {
      if minCircularRows % rows == 0 {
        circularRows = minCircularRows
      } else {
        circularRows = rows * (minCircularRows / rows + 1)
      }
    }
    return circularRows
  }
  
}

extension DataPickerView: UIPickerViewDelegate {
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
  {
    var title: UILabel
    
    if let ttl = view as? UILabel {
      title = ttl
    } else {
      title = UILabel()
    }
    
    title.textAlignment = NSTextAlignment.Center
    title.font = font
    title.textColor = textColor
    
    let sourceRow = row % options[component].count
    title.text = options[component][sourceRow]
    return title
  }
  
  // комбинация со всеми пустыми рядами
  func impossibleCombination(selectedValues: [String]) -> Bool {
    var selectedString = ""
    for s in selectedValues {
      selectedString += s
    }
    
    if selectedString.isVoid {
      return true
    } else {
      return false
    }
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    selectedValues = []
    var value: String
    var selectedRow: Int
    
    for ind in 0..<options.count {
      selectedRow = pickerView.selectedRowInComponent(ind)
      let sourceRow = selectedRow % options[ind].count
      value = options[ind][sourceRow]
      selectedValues.append(value)
    }
    
    selectedRow = pickerView.selectedRowInComponent(component)
    // невозможна комбинация со всеми пустыми рядами
    if impossibleCombination(selectedValues) {
      selectedRow += 1
      let sourceRow = (selectedRow) % options[component].count
      selectedValues[component] = options[component][sourceRow]
      pickerView.selectRow(selectedRow, inComponent: component, animated: true)
    }
    
    if let delegate = delegate {
      if delegate.dataStillNeeded(fromPicker: self) {
        delegate.dataPicker(self, didPickValues: selectedValues)
      }
    }
    
//    if delegate?.dataStillNeeded() {
//      delegate?.dataPicker(self, didPickValues: selectedValues)
//    }
  }
  
}

