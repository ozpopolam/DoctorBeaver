//
//  Task+CoreDataProperties.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Task {
  @NSManaged var pet: Pet
  
  @NSManaged var name: String
  @NSManaged var typeId: Int
  @NSManaged var typeItem: TaskTypeItem
  
  @NSManaged var timesPerDay: Int
  @NSManaged var minutesForTimes: [Int]
  @NSManaged var doseForTimes: [String]
  @NSManaged var specialFeature: String
  
  @NSManaged var comment: String
  
  @NSManaged var startDate: NSDate
  @NSManaged var frequency: [Int]
  @NSManaged var endDaysOrTimes: Int
  @NSManaged var endDate: NSDate
  
  @NSManaged var realizations: NSOrderedSet
}
