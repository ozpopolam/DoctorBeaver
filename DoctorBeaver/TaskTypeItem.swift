//
//  TaskTypeItem.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData


class TaskTypeItem: NSManagedObject {
  
  static var entityName: String {
    get {
      return "TaskTypeItem"
    }
  }
  
  enum Keys: String {
    case id = "id_"
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entityForName(TaskTypeItem.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      
      id_ = -1
      name_ = ""
      iconName_ = ""
      doseUnit_ = ""
      
      sectionTitles_ = ""
      
      timesPerDayTitle_ = ""
      timesPerDayOptions_ = ""
      timesPerDayForInitialization_ = 0

      minutesForTimesTitle_ = ""
      minutesForTimesOrderTitles_ = ""
      minutesForTimesForInitialization_ = 0

      doseForTimesTitle_ = ""
      doseForTimesEqualTitle_ = ""
      doseForTimesOrderTitles_ = ""
      doseForTimesOptions_ = ""
      doseForTimesForInitialization_ = ""

      specialFeatureTitle_ = ""
      specialFeatureOptions_ = ""
      specialFeatureForInitialization_ = ""

      frequencyPreposition_ = ""
      frequencySegmentTitles_ = ""
      frequencyTitle_ = ""
      
      tasks = []
      
//      @NSManaged var basicValues: TaskTypeItemBasicValues
    } else {
      return nil
    }
  }
  
}
