//
//  Pet.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

class Pet: NSManagedObject {
  static var entityName: String {
    get {
      return "Pet"
    }
  }
  
  enum Keys: String {
    case selected = "selected"
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(Pet.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      tasks = []
    } else {
      return nil
    }
  }
  
  func configureWithBasicValues() {
    name = basicValues.basicName
    selected = true
    imageName = VisualConfiguration.errorImageName
  }
  
  func addTask(task: Task) {
    let mutableTasks = NSMutableSet(set: self.tasks)
    mutableTasks.addObject(task)
    self.tasks = mutableTasks
  }
  
  var hasNoTasks: Bool {
    get {
      return tasks.count == 0
    }
  }
  
  var separator: Character {
    get {
      return basicValues.separator.characters.first ?? " "
    }
  }
  
  func getOneDimArrayOfStrings(fromUnseparatedString string: String, withSeparator separator: Character) -> [String] {
    let oneDimArray = string.characters.split(separator, maxSplit: string.characters.count, allowEmptySlices: false).map{String($0)}
    
    return oneDimArray
  }
  
  var sectionTitles: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: basicValues.sectionTitles, withSeparator: separator)
    }
  }
  
  var namePlaceholder: String {
    get {
      return basicValues.namePlaceholder
    }
  }
  
  var selectedTitle: String {
    get {
      return basicValues.selectedTitle
    }
  }
  
  // count how many unfinished tasks pet has
  func countActiveTasks(forDate date: NSDate) -> Int {
    var actTsks = 0
    
    for task in tasks {
      if let task = task as? Task {
        if DateHelper.calendar.compareDate(task.startDate, toDate: date, toUnitGranularity: .Minute) != .OrderedDescending &&
          DateHelper.calendar.compareDate(date, toDate: task.endDate, toUnitGranularity: .Minute) != .OrderedDescending
        {
          actTsks += 1
        }
      }
    }
    return actTsks
  }
  
  // copy settings without tasks
  func copySettingsWithoutTasks(fromPet pet: Pet) {
    self.name = pet.name
    self.basicValues = pet.basicValues
    self.selected = pet.selected
    self.imageName = pet.imageName
  }
  
  // check whether settings of two pets are equal
  func settingsAreEqual(toPet pet: Pet) -> Bool {
    guard name == pet.name else { return false }
    guard selected == pet.selected else { return false }
    guard imageName == pet.imageName else { return false }
    return true
  }
  
  func tasksSortedByActiveness(forDate date: NSDate) -> (active: [Task], completed: [Task]) {
    var tasks = [Task]()
    for task in self.tasks {
      if let task = task as? Task {
        tasks.append(task)
      }
    }
    
    let compareDatesToMinutes: (firstDate: NSDate, secondDate: NSDate) -> NSComparisonResult = {
      (fd, sd) in
      return DateHelper.compareDatesToUnit(firstDate: fd, secondDate: sd, unit: NSCalendarUnit.Minute)
    }

    var activeTasks = [Task]()
    var completedTasks = [Task]()

    for task in tasks {
      if compareDatesToMinutes(firstDate: task.endDate, secondDate: date) == .OrderedDescending {
        activeTasks.append(task)
      } else {
        completedTasks.append(task)
      }
    }

    activeTasks.sortInPlace{ compareDatesToMinutes(firstDate: $0.endDate, secondDate: $1.endDate) == .OrderedAscending }
    completedTasks.sortInPlace{ compareDatesToMinutes(firstDate: $0.endDate, secondDate: $1.endDate) == .OrderedDescending }
    
    return (activeTasks, completedTasks)
  }
  
}
