//
//  UIButton.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 24.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

extension UIButton {
//  // добавляем кнопке иконку
//  func setImage(withName name: String, ofSize iconSize: CGSize, forButtonState state: UIControlState, withAnimationDuration animationDuration: NSTimeInterval = 0) {
//    
//    // проверяем, чтобы существовала картинка
//    if let buttonIcon = UIImage(named: name) {
//      let scaledButtonIcon = buttonIcon.ofSize(iconSize)
//      
//      self.setImage(scaledButtonIcon.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), forState: state)
//      
//      if animationDuration > 0 {
//        self.alpha = 0.0
//        UIView.animateWithDuration(animationDuration) {
//          self.alpha = 1.0
//        }
//      }
//    }
//  }
  
  func setImage(withName name: String, ofSize iconSize: CGSize, withTintColor tintColor: UIColor, withAnimationDuration animationDuration: NSTimeInterval = 0)  {
    // проверяем, чтобы существовала картинка
    if let buttonIcon = UIImage(named: name) {
      setImage(withImage: buttonIcon, ofSize: iconSize, withTintColor: tintColor, withAnimationDuration: animationDuration)
    }
  }
  
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
  
}