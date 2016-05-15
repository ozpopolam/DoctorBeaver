//
//  PetBasicValues+CoreDataProperties.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PetBasicValues {
  @NSManaged var namePlaceholder: String
  @NSManaged var sectionTitles: String
  @NSManaged var selectedTitle: String
  @NSManaged var selectedForInitialization: Bool
  
  @NSManaged var pets: NSSet
}
