//
//  SpecificDateTask.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData


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
