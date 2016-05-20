//
//  SettingTextFieldCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 19.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class MenuTextFieldCell: UITableViewCell {
  
  @IBOutlet weak var textField: DecoratedTextField!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
