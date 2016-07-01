//
//  TaskTypeItem.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import RealmSwift

class TaskTypeItem: Object {
  dynamic var id = 0
  dynamic var name = ""
  dynamic var iconName = ""
  dynamic var doseUnit = ""
  
  dynamic var sectionTitles = ""
  
  dynamic var timesPerDayTitle = ""
  dynamic var timesPerDayOptions = ""
  dynamic var timesPerDayForInitialization = 0
  
  dynamic var minutesForTimesTitle = ""
  dynamic var minutesForTimesOrderTitles = ""
  dynamic var minutesForTimesForInitialization = 0
  
  dynamic var doseForTimesTitle = ""
  dynamic var doseForTimesEqualTitle = ""
  dynamic var doseForTimesOrderTitles = ""
  dynamic var doseForTimesOptions = ""
  dynamic var doseForTimesForInitialization = ""
  
  dynamic var specialFeatureTitle = ""
  dynamic var specialFeatureOptions = ""
  dynamic var specialFeatureForInitialization = ""
  
  dynamic var frequencyPreposition = ""
  dynamic var frequencySegmentTitles = ""
  dynamic var frequencyTitle = ""
  
  let tasks = LinkingObjects(fromType: Task.self, property: "typeItem")
  
  dynamic var basicValues: TaskTypeItemBasicValues?
}
