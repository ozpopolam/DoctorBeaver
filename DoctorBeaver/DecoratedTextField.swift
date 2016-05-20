//
//  DecoratedTextField.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 19.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class DecoratedTextField: UITextField {
  
  var textColorResponder: UIColor?
  var textColorNonResponder: UIColor?
  
  override func becomeFirstResponder() -> Bool {
    userInteractionEnabled = true
    let canBecomeFirstResponder = super.becomeFirstResponder()
    textColor = textColorResponder
    //print("becomeFirstResponder")
    return canBecomeFirstResponder
  }
  
  override func resignFirstResponder() -> Bool {
    let canResignFirstResponder = super.resignFirstResponder()
    textColor = textColorNonResponder
    userInteractionEnabled = false
    //print("resignFirstResponder")
    return canResignFirstResponder
  }
  
}
