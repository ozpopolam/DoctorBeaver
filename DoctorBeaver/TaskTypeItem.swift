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
    case id = "id"
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
  
  
  
//    func sectionTitles() -> [String] {
//      switch task.type {
//      case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure:
//        return ["", "Способ применения", "Длительность приема", "Особые указания"]
//      case .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming:
//        return ["", "", "Длительность приема", "Особые указания"]
//      case .Error:
//        return []
//      }
//    }
  
}
