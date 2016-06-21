//
//  SpecificDateTask.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

extension Realization {
  @NSManaged var task: Task
  
  @NSManaged var date: NSDate
  
  // -1 - task shoudn't be performed
  // 0 - task hasn't performed yet
  // 1 - task was performed
  @NSManaged var done: [Int]
}

class Realization: NSManagedObject {
  
  static var entityName: String {
    get {
      return "Realization"
    }
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(Realization.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      date = NSDate()
      done = []
    } else {
      return nil
    }
  }
}
