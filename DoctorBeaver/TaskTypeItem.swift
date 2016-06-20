//
//  TaskTypeItem.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
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

class TaskTypeItem: NSManagedObject {
  
  static var entityName: String {
    get {
      return "TaskTypeItem"
    }
  }
  
  enum Keys: String {
    case id = "id_"
  }
  
  var id: Int {
    get { return Int(id_) }
    set { id_ = Int32(newValue) }
  }
  
  var timesPerDayForInitialization: Int {
    get { return Int(timesPerDayForInitialization_) }
    set { timesPerDayForInitialization_ = Int32(newValue) }
  }
  
  var minutesForTimesForInitialization: Int {
    get { return Int(minutesForTimesForInitialization_) }
    set { minutesForTimesForInitialization_ = Int32(newValue) }
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entityForName(TaskTypeItem.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      
      id = -1
      name = ""
      iconName = ""
      doseUnit = ""
      
      sectionTitles = ""
      
      timesPerDayTitle = ""
      timesPerDayOptions = ""
      timesPerDayForInitialization = 0

      minutesForTimesTitle = ""
      minutesForTimesOrderTitles = ""
      minutesForTimesForInitialization = 0

      doseForTimesTitle = ""
      doseForTimesEqualTitle = ""
      doseForTimesOrderTitles = ""
      doseForTimesOptions = ""
      doseForTimesForInitialization = ""

      specialFeatureTitle = ""
      specialFeatureOptions = ""
      specialFeatureForInitialization = ""

      frequencyPreposition = ""
      frequencySegmentTitles = ""
      frequencyTitle = ""
      
      tasks = []
    } else {
      return nil
    }
  }
  
}
