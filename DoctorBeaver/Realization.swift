//
//  SpecificDateTask.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import RealmSwift

class Realization: Object {
  dynamic var task: Task?
  
  dynamic var date = NSDate()
  
  // -1 - task shoudn't be performed
  // 0 - task hasn't performed yet
  // 1 - task was performed
  private dynamic var done_: RealmIntArray?
  var done: [Int] {
    get {
      if let done_ = done_ {
        return done_.toArray()
      } else { return [] }
    }
    set {
      if done_ == nil {
        done_ = RealmIntArray()
      }
      done_?.updateWith(newValue)
    }
  }
  
  override static func ignoredProperties() -> [String] {
    return ["done"]
  }
}
