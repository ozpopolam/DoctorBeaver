//
//  TableViewCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol StateSwitchDelegate: class {
  func stateSwitch(stateSwitch: UISwitch, didSetOn setOn: Bool)
}

class MenuTitleSwitchCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var stateSwitch: UISwitch!
  
  weak var delegate: StateSwitchDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  @IBAction func toggleEqualSwitch(sender: UISwitch) {
    delegate?.stateSwitch(sender, didSetOn: sender.on)
  }
  
}
