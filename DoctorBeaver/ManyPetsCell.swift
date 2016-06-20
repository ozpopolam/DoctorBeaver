//
//  ManyPetsCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class ManyPetsCell: BasicPetCell {
  
  @IBOutlet weak var petNameLabel: UILabel!
  @IBOutlet weak var petImageView: UIImageView! {
    didSet {
      petImageView.layer.cornerRadius = petImageView.frame.size.width / VisualConfiguration.cornerProportion
      petImageView.clipsToBounds = true
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
