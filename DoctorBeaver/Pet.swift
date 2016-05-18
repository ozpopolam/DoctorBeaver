//
//  Pet.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

class Pet: NSManagedObject {
  static var entityName: String {
    get {
      return "Pet"
    }
  }
  
  enum Keys: String {
    case selected = "selected"
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(Pet.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      
      id = NSDate().timeIntervalSince1970
      
      tasks = []
      
    } else {
      return nil
    }
  }
  
  func configure(withTypeItem typeItem: TaskTypeItem) {
    name = ""
    selected = false
    image = ""
  }
  
  var separator: Character {
    get {
      return basicValues.separator.characters.first ?? " "
    }
  }
  
  func getOneDimArrayOfStrings(fromUnseparatedString string: String, withSeparator separator: Character) -> [String] {
    let oneDimArray = string.characters.split(separator, maxSplit: string.characters.count, allowEmptySlices: false).map{String($0)}
    return oneDimArray
  }
  
  var sectionTitles: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: basicValues.sectionTitles, withSeparator: separator)
    }
  }
  
  var namePlaceholder: String {
    get {
      return basicValues.namePlaceholder
    }
  }
  
  var selectedTitle: String {
    get {
      return basicValues.selectedTitle
    }
  }
  
  // считаем, сколько неоконченных заданий у питомца
  func countActiveTasks(forDate date: NSDate) -> Int {
    var actTsks = 0
    
    for task in tasks {
      if let task = task as? Task {
        if DateHelper.calendar.compareDate(task.startDate, toDate: date, toUnitGranularity: .Minute) != .OrderedDescending &&
          DateHelper.calendar.compareDate(date, toDate: task.endDate, toUnitGranularity: .Minute) != .OrderedDescending
        {
          actTsks += 1
        }
      }
    }
    return actTsks
  }
  
  func tasksSorted() -> [Task] {
    
    var tskSrt = [Task]()
    
    for task in tasks {
      if let task = task as? Task {
        tskSrt.append(task)
      }
    }
    
    tskSrt.sortInPlace{DateHelper.compareDatesToMinuteUnit(firstDate: $0.endDate, secondDate: $1.endDate)}
    
    
    
    return tskSrt
  }
  
}
