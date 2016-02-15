//
//  FilterCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 13.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {
  
  @IBOutlet weak var petImageView: UIImageView! {
    didSet {
      petImageView.layer.cornerRadius = petImageView.frame.size.width / 2
      petImageView.clipsToBounds = true
    }
  }
  @IBOutlet weak var petNameLabel: UILabel!
  @IBOutlet weak var remainTasksLabel: UILabel!
  @IBOutlet weak var checkmarkImageView: UIImageView!
  @IBOutlet weak var selectView: UIView!  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
