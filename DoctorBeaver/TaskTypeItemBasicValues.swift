//
//  TaskTypeItemBasicValues.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import RealmSwift

class TaskTypeItemBasicValues: Object {
  let typeItem = LinkingObjects(fromType: TaskTypeItem.self, property: "basicValues")
  
  dynamic var taskNamePlaceholder = ""
  dynamic var separator = ""
  
  dynamic var startDateTitle = ""
  dynamic var daysOptions = ""
  dynamic var endDaysOrTimesTitle = ""
  dynamic var endDaysOrTimesSegmentTitles = ""
  dynamic var endDaysOrTimesOptionsPreposition = ""
  dynamic var timesOptions = ""
  
  dynamic var commentPlaceholder = ""
}
