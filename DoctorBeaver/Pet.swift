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
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(Pet.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      
      id = NSDate().timeIntervalSince1970
      name = "Имя питомца"
      selected = false
      image = "noPet"
      tasks = []
      
    } else {
      return nil
    }
  }
  
}
