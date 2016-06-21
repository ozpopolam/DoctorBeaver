//
//  String.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 12.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

extension String {
  
  var isVoid: Bool {
    get {
      return self.isEmpty || self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty
    }
  }
  
  var isFilledWithSomething: Bool {
    get {
      return !isEmpty
    }
  }
  
  static func getOneDimArrayOfStrings(fromUnseparatedString string: String, withSeparator separator: Character) -> [String] {
    let oneDimArray = string.characters.split(separator, maxSplit: string.characters.count, allowEmptySlices: true).map{String($0)}
    return oneDimArray
  }
  
  static func getTwoDimArrayOfStrings(fromUnseparatedString string: String, withSeparator separator: Character) -> [[String]] {
    
    let twoDimSeparator = String(separator) + String(separator)
    var twoDimArray = [[String]]()
    
    let twoDimStringElements = string.componentsSeparatedByString(twoDimSeparator)
    for twoDimStringElement in twoDimStringElements {
      twoDimArray.append(getOneDimArrayOfStrings(fromUnseparatedString: twoDimStringElement, withSeparator: separator))
    }
    //return twoDimArray
    return (twoDimArray.filter{ !$0.isEmpty }).isEmpty ? [] : twoDimArray
  }
  
}

