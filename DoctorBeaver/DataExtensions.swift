//
//  DataExtensions.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 02.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

extension Pet {
  func printInBlock() {
    print("PET name: \(name)")
    print("selected: \(selected)")
    print("image: \(image)")
    
    for task in tasks {
      if let task = task as? Task {
        task.printInBlock()
      }
    }
    print("")
  }
}

extension Task {
  func printInBlock() {
    print("   TASK of \(pet.name)")
    print("   name: \(name)")
    print("   type: \(type.toString())")
    print("   timesPerDay: \(timesPerDay)")
    
    var s: String = ""
    for mft in minutesForTimes {
      s += String(whitespace)
      
      let h = mft / 60
      if h < 10 {
        s += "0"
      }
      s += "\(h):"
      
      let m = mft % 60
      if m < 10 {
        s += "0"
      }
      s += "\(m)"
    }
    print("   minutesForTimes: [" + s + " ]")
    
    s = ""
    for dft in doseForTimes {
      s += " \(dft)"
    }
    print("   doseForTimes: [" + s + " ]")
    print("   specialFeature: \(specialFeature)")
    print("   startDate: \(DateHelper.dateToString(startDate))")
    
    s = ""
    for f in frequency {
      s += " \(f)"
    }
    print("   frequency: [" + s + " ]")
    
    if endDaysOrTimes < 0 {
      print("   endDays: \(-endDaysOrTimes)")
    } else {
      if endDaysOrTimes > 0 {
        print("   endTimes: \(endDaysOrTimes)")
      }
    }
    
    print("   endDate: \(DateHelper.dateToString(endDate))")
    
    if comment.isEmpty {
      print("   comment: #")
    } else {
      print("   comment: \(comment)")
    }
    
    for r in realizations {
      if let r = r as? Realization {
        r.printInBlock()
      }
    }
    
    print("")
  }
}

extension Realization {
  func printInBlock() {
    print("      Realization of \(task.name)")
    print("      date: \(DateHelper.dateToString(date))")
    
    var s: String = ""
    
    for ind in 0..<done.count {
      switch done[ind] {
      case 0:
        s += " \(DateHelper.minutesToString(task.minutesForTimes[ind])) -"
      case 1:
        s += " \(DateHelper.minutesToString(task.minutesForTimes[ind])) +"
      default:
        break
      }
    }
    print("      done: [" + s + " ]")
    print("")
  }
}