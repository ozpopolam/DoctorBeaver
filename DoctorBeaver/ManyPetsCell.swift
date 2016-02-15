//
//  ManyPetsCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class ManyPetsCell: UITableViewCell {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var taskTitleLabel: UILabel!
  @IBOutlet weak var taskDetailLabel: UILabel!
  @IBOutlet weak var petNameLabel: UILabel!
  @IBOutlet weak var petImageView: UIImageView! {
    didSet {
      petImageView.layer.cornerRadius = petImageView.frame.size.width / 2
      petImageView.clipsToBounds = true
    }
  }
  @IBOutlet weak var selectView: UIView!
  @IBOutlet weak var checkmarkImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
      //selectView.hidden = true

        // Configure the view for the selected state
    }

}
