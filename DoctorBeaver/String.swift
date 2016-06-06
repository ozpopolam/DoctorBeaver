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
      //return !isVoid
    }
  }
}

