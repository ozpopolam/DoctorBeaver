//
//  HexColor.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

// расширение для UIColor
extension UIColor {
  
  // светло-оранжевый
  class func lightOrangeColor() -> UIColor {
    return UIColor(red: 240/255.0, green: 173/255.0, blue: 48/255.0, alpha: 1.0)
  }
  
  // сизый
  class func fogColor() -> UIColor {
    // #605A68
    return UIColor(red: 96/255.0, green: 90/255.0, blue: 104/255.0, alpha: 1.0)
  }
  
  // очень светло-серый
  class func mercuryColor() -> UIColor {
    // #E6E6E6
    return UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
  }
  
}
