//
//  SettingTextFieldCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 19.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class StgTextFieldCell: UITableViewCell {

  @IBOutlet weak var textField: UITextField!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
