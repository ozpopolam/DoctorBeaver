//
//  MenuIconTitleCollectionCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 03.06.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class MenuIconTitleCollectionCell: UICollectionViewCell {
  @IBOutlet weak var containerView: RoundedCornersView!
  @IBOutlet weak var iconView: UIImageView!
  @IBOutlet weak var iconTitle: UILabel!
  @IBOutlet weak var selectedView: RoundedCornersView!
  
  var selectionColor: UIColor?
  var unSelectionColor: UIColor?
  
  override var selected: Bool {
    didSet {
      super.selected = selected
      if selected {
        selectedView.backgroundColor = selectionColor
      } else {
        selectedView.backgroundColor = unSelectionColor
      }
    }
  }
  
  override var highlighted: Bool {
    didSet {
      super.highlighted = highlighted
      if highlighted {
        selectedView.backgroundColor = selectionColor
      }
    }
  }
  
}
