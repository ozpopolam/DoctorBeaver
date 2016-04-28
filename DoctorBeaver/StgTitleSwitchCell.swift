//
//  TableViewCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol EqualSwitchDelegate: class {
  func equalSwitch(eqSwt: UISwitch, didSetOn setOn: Bool)
}

class StgTitleSwitchCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var equalSwitch: UISwitch!
  
  weak var delegate: EqualSwitchDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  @IBAction func toggleEqualSwitch(sender: UISwitch) {
    delegate?.equalSwitch(sender, didSetOn: sender.on)
  }
  
}
