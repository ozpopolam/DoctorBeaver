//
//  UIButton.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 24.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

extension UIButton {
  
  // set image for button, set tint color on it and possibly animate changes
  func setImage(withImage image: UIImage, ofSize iconSize: CGSize, withTintColor tintColor: UIColor, withAnimationDuration animationDuration: NSTimeInterval = 0)  {
    
    let scaledButtonIcon = image.ofSize(iconSize)
    
    self.setImage(scaledButtonIcon.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
    self.setImage(scaledButtonIcon.imageWithRenderingMode(.AlwaysTemplate), forState: .Highlighted)
    
    if animationDuration > 0 {
      self.alpha = 0.0
      UIView.animateWithDuration(animationDuration) {
        self.alpha = 1.0
      }
    }
    
    self.tintColor = tintColor
  }
  
  // set image with imageName, tint color on it and possibly animate changes
  func setImage(withName name: String, ofSize iconSize: CGSize, withTintColor tintColor: UIColor, withAnimationDuration animationDuration: NSTimeInterval = 0)  {
    if let buttonIcon = UIImage(named: name) {
      setImage(withImage: buttonIcon, ofSize: iconSize, withTintColor: tintColor, withAnimationDuration: animationDuration)
    }
  }
  
}