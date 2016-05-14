//
//  StgDataDateTimePickerCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 02.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import UIKit

protocol StgComplexPickerCellDelegate: class {
  func getPickerOptionsAndInitialValues(bySelectedSegment index: Int, andByTag tag: Int) -> (options: [[String]], initialValues: [String], delegate: DataPickerViewDelegate)
  func getPickerInitialDate(bySelectedSegment index: Int, andByTag tag: Int) -> (iDate: NSDate, mDate: NSDate, delegate: DatePickerDelegate)
}

class StgComplexPickerCell: UITableViewCell {
  
  weak var delegate: StgComplexPickerCellDelegate?
  
  @IBOutlet weak var tripleOptionSgCtrl: UISegmentedControl!
  
  @IBOutlet weak var firstDataPickerView: DataPickerView!
  @IBOutlet weak var secondDataPickerView: DataPickerView!
  @IBOutlet weak var datePicker: StgDatePicker!
  
  var dataPickerViews: [DataPickerView] = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    tripleOptionSgCtrl.tintColor = VisualConfiguration.segmentTintColor
    tripleOptionSgCtrl.setTitleTextAttributes([NSFontAttributeName: VisualConfiguration.segmentFont], forState: .Normal)
    tripleOptionSgCtrl.sizeToFit()
    
    firstDataPickerView.font = VisualConfiguration.pickerFont
    firstDataPickerView.textColor = VisualConfiguration.pickerTextColor
    secondDataPickerView.font = VisualConfiguration.pickerFont
    secondDataPickerView.textColor = VisualConfiguration.pickerTextColor
    
    dataPickerViews.append(firstDataPickerView)
    dataPickerViews.append(secondDataPickerView)
  }
  
  func configureVisibilityOfPickerViews(bySegmentAtIndex index: Int) {
    switch index {
    case 0:
      firstDataPickerView.hidden = false
      secondDataPickerView.hidden = true
      datePicker.hidden = true
    case 1:
      firstDataPickerView.hidden = true
      secondDataPickerView.hidden = false
      datePicker.hidden = true
    case 2:
      firstDataPickerView.hidden = true
      secondDataPickerView.hidden = true
      datePicker.hidden = false
    default:
      break
    }
  }
  
  func configure(withTag tag: Int, andDelegate delegate: StgComplexPickerCellDelegate) {
    self.tag = tag
    self.delegate = delegate
    
    firstDataPickerView.tag = tag
    secondDataPickerView.tag = tag + 1
    datePicker.tag = tag + 2
    
    datePicker.needToReload = true
  }
  
  func configure(withSegmentValues segmentValues: [String], andSelectedSegment index: Int) {
    if tripleOptionSgCtrl.numberOfSegments == segmentValues.count {
      for ind in 0..<segmentValues.count {
        tripleOptionSgCtrl.setTitle(segmentValues[ind], forSegmentAtIndex: ind)
      }
    }
    tripleOptionSgCtrl.selectedSegmentIndex = index
    
    configureVisibilityOfPickerViews(bySegmentAtIndex: index)
  }
  
  func configure(withTitles titles: [[String]], andWithInitialValues initialValues: [String], andDelegate delegate: DataPickerViewDelegate)
  {
    let index = tripleOptionSgCtrl.selectedSegmentIndex
    if index == 0 || index == 1 {
      dataPickerViews[index].configure(withOptions: titles, andInitialValues: initialValues, andDelegate: delegate)
    }
  }
  
  func configure(withDelegate delegate: DatePickerDelegate, selectedDate sDate: NSDate, andMinimumDate mDate: NSDate) {
    if tripleOptionSgCtrl.selectedSegmentIndex == 2 {
      datePicker.configure(withDelegate: delegate, selectedDate: sDate, andMinimumDate: mDate)
    }
  }
  
  func hidden(forTag tag: Int) -> Bool {
    
    switch tag {
    case firstDataPickerView.tag:
      return firstDataPickerView.hidden
    case secondDataPickerView.tag:
      return secondDataPickerView.hidden
    case datePicker.tag:
      return datePicker.hidden
    default:
      return false
    }
    
  }
  
  @IBAction func selectSegment(sender: UISegmentedControl) {
    let index = sender.selectedSegmentIndex
    configureVisibilityOfPickerViews(bySegmentAtIndex: sender.selectedSegmentIndex)
    
    if let delegate = delegate {
      if index != 2 {
        if dataPickerViews[index].rowsInComponent.isEmpty {
          
          var titles: [[String]]
          var initialValues: [String]
          var pickerDelegate: DataPickerViewDelegate
          
          (titles, initialValues, pickerDelegate) = delegate.getPickerOptionsAndInitialValues(bySelectedSegment: index, andByTag: dataPickerViews[index].tag)
          
          dataPickerViews[index].configure(withOptions: titles, andInitialValues: initialValues, andDelegate: pickerDelegate)
        }
        
      } else {
        if datePicker.needToReload == true {
          
          datePicker.needToReload = false
          
          var iDate: NSDate
          var mDate: NSDate
          var pickerDelegate: DatePickerDelegate
          (iDate, mDate, pickerDelegate) = delegate.getPickerInitialDate(bySelectedSegment: 2, andByTag: datePicker.tag)
          
          datePicker.configure(withDelegate: pickerDelegate, selectedDate: iDate, andMinimumDate: mDate)
        }
      }
    }
    
    var selectedRow: Int
    // сменился сегмент - сменилось выбранное значение на pickerView
    if index != 2 {
      let pickerView = dataPickerViews[index].pickerView
      selectedRow = pickerView.selectedRowInComponent(0)
      dataPickerViews[index].pickerView(pickerView, didSelectRow: selectedRow, inComponent: 0)
    } else {
      datePicker.didPick()
    }
    
  }
  
  // datePicker выбрал дату или время
  @IBAction func pickerDidPickDate(sender: UIDatePicker) {
    datePicker.didPick()
  }
  
}