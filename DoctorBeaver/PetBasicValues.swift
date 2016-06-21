//
//  PetBasicValues.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

extension PetBasicValues {
  @NSManaged var basicName: String
  @NSManaged var namePlaceholder: String
  @NSManaged var separator: String
  
  @NSManaged var sectionTitles: String
  @NSManaged var selectedTitle: String
  @NSManaged var selectedForInitialization: Bool
  
  @NSManaged var pets: NSSet
}

class PetBasicValues: NSManagedObject {
  
  static var entityName: String {
    get {
      return "PetBasicValues"
    }
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(PetBasicValues.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      pets = []
    } else {
      return nil
    }
  }
  
}
