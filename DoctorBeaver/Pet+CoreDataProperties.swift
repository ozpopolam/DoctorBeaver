//
//  Pet+CoreDataProperties.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pet {
  @NSManaged var id: Double
  @NSManaged var basicValues: PetBasicValues
  
  @NSManaged var name: String
  @NSManaged var selected: Bool
  @NSManaged var imageName: String
  
  @NSManaged var tasks: NSSet
}
