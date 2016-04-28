//
//  StgDatePickerCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 14.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class StgDatePickerCell: UITableViewCell {
  
  @IBOutlet weak var datePicker: StgDatePicker!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
//  func stopFromValueChanged() {
//    
//    print("remove pickerDidPickDate")
//    
//    datePicker.removeTarget(self, action: "pickerDidPickDate:", forControlEvents: .ValueChanged)
//  }
  
  // datePicker выбрал дату или время
  @IBAction func pickerDidPickDate(sender: UIDatePicker) {
    datePicker.didPick()
  }
  
}
