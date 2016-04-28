//
//  SpecificDateTask+CoreDataProperties.swift
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

// to Realization
extension Realization {
  @NSManaged var task: Task
  
  @NSManaged var date: NSDate
  // -1 - задание в это время выполнять не нужно
  // 0 - задание еще не выполнено
  // 1 - задание выполнено
  @NSManaged var done: [Int]
}
