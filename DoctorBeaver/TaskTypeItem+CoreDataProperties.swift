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
  @NSManaged var id_: Int
  @NSManaged var name_: String
  @NSManaged var iconName_: String
  @NSManaged var doseUnit_: String
  
  @NSManaged var sectionTitles_: String
  
  @NSManaged var timesPerDayTitle_: String
  @NSManaged var timesPerDayOptions_: String
  @NSManaged var timesPerDayForInitialization_: Int
  
  @NSManaged var minutesForTimesTitle_: String
  @NSManaged var minutesForTimesOrderTitles_: String
  @NSManaged var minutesForTimesForInitialization_: Int
  
  @NSManaged var doseForTimesTitle_: String
  @NSManaged var doseForTimesEqualTitle_: String
  @NSManaged var doseForTimesOrderTitles_: String
  @NSManaged var doseForTimesOptions_: String
  @NSManaged var doseForTimesForInitialization_: String
  
  @NSManaged var specialFeatureTitle_: String
  @NSManaged var specialFeatureOptions_: String
  @NSManaged var specialFeatureForInitialization_: String
  
  @NSManaged var frequencyPreposition_: String
  @NSManaged var frequencySegmentTitles_: String
  @NSManaged var frequencyTitle_: String
  
  @NSManaged var tasks: NSSet
  
  @NSManaged var basicValues: TaskTypeItemBasicValues
}
