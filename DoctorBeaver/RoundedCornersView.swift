//
//  RoundedCornersView.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 21.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class RoundedCornersView: UIView {
  
  private var subviewsLaidOutForNewCornerPropotion = false
  
  var cornerProportion: CGFloat? {
    didSet {
      subviewsLaidOutForNewCornerPropotion = false
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if let cornerProportion = cornerProportion {
      if !subviewsLaidOutForNewCornerPropotion {
        layer.cornerRadius = frame.size.width / cornerProportion
        clipsToBounds = true
        subviewsLaidOutForNewCornerPropotion = true
      }
    }
  }
  
}
