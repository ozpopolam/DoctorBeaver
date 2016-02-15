//
//  VisualConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import Foundation

// оформление приложения
struct VisualConfiguration {
  let backgroundColor = UIColor.lightOrangeColor()
  
  let navigationIconSize = CGSize(width: 25, height: 25)
  
  
  var basicFont: UIFont {
    get {
      if let font = UIFont(name: "", size: 17.0) { return font }
        else { return UIFont.systemFontOfSize(17.0) }
    }
  }
  
  var petsNamesFont: UIFont {
    get {
      if let font = UIFont(name: "Noteworthy-Light", size: 22.0) { return font }
      else { return UIFont.systemFontOfSize(22.0) }
    }
  }
  
  var navigationBarFont: UIFont
  
  init() {
    
    if let font = UIFont(name: "GillSans-SemiBold", size: 15.0) {
      navigationBarFont = font
    } else {
      navigationBarFont = UIFont.systemFontOfSize(17.0)
    }
    
    
  }
  
}