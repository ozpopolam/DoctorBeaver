//
//  Pet.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import UIKit

class IdDistribution {
  static var id: Int = -1
  class func nextID() -> Int {
    id += 1
    return id
    
  }
  
}

class Pet {
  var name: String
  var image: String
  var selected: Bool
  var schedule: [Task]
  
  init(withName name: String, andWithImage image: String) {
    self.name = name.lowercaseString
    self.image = image
    selected = true
    schedule = []
  }
  
  convenience init() {
    self.init(withName: "", andWithImage: "")
  }
  
  func addNewTask(task: Task) {
    schedule.append(task)
    task.petOwner = self
  }
  
  func allTaskForDate() -> [Task] {
    return []
  }
  
}

enum DayPart: String {
  case Morning = "Утро"
  case Day = "День"
  case Evening = "Вечер"
  case Night = "Ночь"
}

enum TaskType: String {
  case Pill
}

class Task {
  var name: String
  var icon: String
  var description: String
  var time: Int
  var dayPart: DayPart
  var done: Bool
  
  let type: TaskType
  
  weak var petOwner: Pet?
  
  
  
  init(withName name: String, withIcon icon: String, withDescription description: String, withTime time: Int) {
    self.name = name
    self.icon = icon
    self.description = description
    
    type = .Pill

    
    
    self.time = time % 24

    switch self.time {
      case 6..<12: dayPart = .Morning
      case 12..<18: dayPart = .Day
      case 18..<24: dayPart = .Evening
      default: dayPart = .Night
    }
    
    self.done = false
    
  }
  
}











