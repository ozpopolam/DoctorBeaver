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
  
//  class func mercuryColor() -> UIColor {
//    // #E6E6E6
//    return UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)
//  }
  
  convenience init?(rgbHexName: String, alpha: CGFloat = 1.0) {
    // только шестибуквенное имя цвета
    guard rgbHexName.characters.count == 6 else { return nil }
    
    let hexDigits = "0123456789ABCDEF"
    let name = rgbHexName.uppercaseString
    
    // проверяем, является ли строка hex-числом
    for ch in name.characters {
      var found = false
      
      if hexDigits.characters.contains(ch) {
        found = true
        break
      }
      if !found {
        return nil
      }
    }
    
    // переводим в rgb-числа
    let redString = name.substringWithRange(Range<String.Index>(start: name.startIndex, end: name.startIndex.advancedBy(2)))
    let greenString = name.substringWithRange(Range<String.Index>(start: name.startIndex.advancedBy(2), end: name.startIndex.advancedBy(4)))
    let blueString = name.substringWithRange(Range<String.Index>(start: name.startIndex.advancedBy(4), end: name.startIndex.advancedBy(6)))
    
    let red: CGFloat = CGFloat(UInt8(strtoul(redString, nil, 16)))
    let green: CGFloat = CGFloat(UInt8(strtoul(greenString, nil, 16)))
    let blue: CGFloat = CGFloat(UInt8(strtoul(blueString, nil, 16)))
    
    // используем стандартный инициализатор
    self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
  }
  
}
