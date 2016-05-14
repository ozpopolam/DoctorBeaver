//
//  TaskTypeItemBasicValues.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData


class TaskTypeItemBasicValues: NSManagedObject {
  
  static var entityName: String {
    get {
      return "TaskTypeItemBasicValues"
    }
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entityForName(TaskTypeItemBasicValues.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      
      typeItem = []
      taskNamePlaceholder = ""
      separator = ""
      startDateTitle = ""
      daysOptions = ""
      endDaysOrTimesTitle = ""
      endDaysOrTimesSegmentTitles = ""
      endDaysOrTimesOptionsPreposition = ""
      timesOptions = ""
      
    } else {
      return nil
    }
  }
  
}
