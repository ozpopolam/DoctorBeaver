//
//  TaskTypeItem+CoreDataProperties.swift
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

extension TaskTypeItem {
  @NSManaged var id_: Int32
  @NSManaged var name: String
  @NSManaged var iconName: String
  @NSManaged var doseUnit: String
  
  @NSManaged var sectionTitles: String
  
  @NSManaged var timesPerDayTitle: String
  @NSManaged var timesPerDayOptions: String
  @NSManaged var timesPerDayForInitialization_: Int32
  
  @NSManaged var minutesForTimesTitle: String
  @NSManaged var minutesForTimesOrderTitles: String
  @NSManaged var minutesForTimesForInitialization_: Int32
  
  @NSManaged var doseForTimesTitle: String
  @NSManaged var doseForTimesEqualTitle: String
  @NSManaged var doseForTimesOrderTitles: String
  @NSManaged var doseForTimesOptions: String
  @NSManaged var doseForTimesForInitialization: String
  
  @NSManaged var specialFeatureTitle: String
  @NSManaged var specialFeatureOptions: String
  @NSManaged var specialFeatureForInitialization: String
  
  @NSManaged var frequencyPreposition: String
  @NSManaged var frequencySegmentTitles: String
  @NSManaged var frequencyTitle: String
  
  @NSManaged var tasks: NSSet
  
  @NSManaged var basicValues: TaskTypeItemBasicValues
}
