//
//  PetImageCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 20.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class PetImageCell: UICollectionViewCell {
  @IBOutlet weak var selectedView: RoundedCornersView!
  @IBOutlet weak var petImageView: RoundedCornersImageView!
  
  var selectionColor: UIColor?
  var unSelectionColor: UIColor?
  
  override var selected: Bool {
    didSet {
      super.selected = selected
      selectedView.backgroundColor = selected ? selectionColor : unSelectionColor
    }
  }
  
  override var highlighted: Bool {
    didSet {
      super.highlighted = highlighted
      selectedView.backgroundColor = highlighted ? selectionColor : unSelectionColor
    }
  }
}
