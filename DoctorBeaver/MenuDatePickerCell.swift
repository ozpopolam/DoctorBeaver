//
//  MenuDatePickerCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 14.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class MenuDatePickerCell: UITableViewCell {
  
  @IBOutlet weak var datePicker: MenuDatePicker!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  @IBAction func pickerDidPickDate(sender: UIDatePicker) {
    datePicker.didPick()
  }
  
}
