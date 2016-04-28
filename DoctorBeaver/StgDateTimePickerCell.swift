//
//  SettingDateTimePickerCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 27.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class StgDateTimePickerCell: UITableViewCell {
  
  @IBOutlet weak var dateTimePickerView: DateTimePickerView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
