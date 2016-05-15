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
  
}
