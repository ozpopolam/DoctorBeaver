//
//  JsonPetParser.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 21.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

class JsonPetParser {
  
  let fileName: String
  let fileType: String
  
  init(withFileName fileName: String, andType fileType: String) {
    self.fileName = fileName
    self.fileType = fileType
  }
  
  func populateManagedObjectContextWithJsonPetData(managedContext: NSManagedObjectContext) {
    
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    do {
      let fetchResults = try managedContext.executeFetchRequest(fetchRequest)
      if !fetchResults.isEmpty {
        managedContext.deleteAllObjects(forEntityName: Pet.entityName)
      }
      populateManagedObjectContext(managedContext)
    } catch {
      print("populateManagedObjectContextWithTestData() has failed")
      
    }
  }
  
  func populateManagedObjectContext(managedContext: NSManagedObjectContext) {
    
    if let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType) {
      if let data = NSData(contentsOfFile: filePath) {
        do {
          if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
            
            if let jsonPets = jsonDict["pets"] as? [[String: AnyObject]] {
              for jsonPet in jsonPets {
                populatePetInManagedObjectContext(managedContext, fromJSONDictionary: jsonPet)
              }
            }
            
          }
        } catch {
          print("Some error with JSON-file!")
        }
      }
    }
    
    managedContext.saveOrRollback()
    
  }
  
  func populatePetInManagedObjectContext(managedContext: NSManagedObjectContext, fromJSONDictionary dict: [String: AnyObject]) {
    guard let name = dict["name"] as? String,
      let image = dict["image"] as? String,
      let selected = dict["selected"] as? Bool,
      let jsonTasks = dict["tasks"] as? [[String: AnyObject]]
      else { return }
    
    let tasks: NSMutableSet = []
    
    for jsonTask in jsonTasks {
      if let task = populateTaskInManagedObjectContext(managedContext, fromJSONDictionary: jsonTask) {
        tasks.addObject(task)
      }
    }
    
    if let pet = Pet(insertIntoManagedObjectContext: managedContext) {
      pet.name = name
      pet.image = image
      pet.selected = selected
      pet.tasks = tasks
    } else {
      return
    }
  }
  
  func populateTaskInManagedObjectContext(managedContext: NSManagedObjectContext, fromJSONDictionary dict: [String: AnyObject]) -> Task? {
    
    guard let typeId = dict["typeId"] as? Int,
      let name = dict["name"] as? String,
      let timesPerDay = dict["timesPerDay"] as? Int,
      let minutesForTimes = dict["minutesForTimes"] as? [Int],
      let doseForTimes = dict["doseForTimes"] as? [String],
      let specialFeature = dict["specialFeature"] as? String,
      let startDateString = dict["startDate"] as? String,
      let frequency = dict["frequency"] as? [Int],
      let comment = dict["comment"] as? String,
      let jsonRealizations = dict["realizations"] as? [[String: AnyObject]]
      else { return nil }
    
    var startDate: NSDate
    if let startDateFromString = VisualConfiguration.dateFromString(startDateString, withFormat: .DateTime) {
      startDate = startDateFromString
    } else {
      return nil
    }
    
    var endDaysOrTimes: Int = 0
    var endDate: NSDate = NSDate()
    
    if let ed = dict["endDays"] as? Int {
      endDaysOrTimes = -ed
    } else {
      if let et = dict["endTimes"] as? Int {
        endDaysOrTimes = et
      } else {
        if let endDateString = dict["endDate"] as? String {
          if let endDateFromString = VisualConfiguration.dateFromString(endDateString, withFormat: .DateTime) {
            endDate = endDateFromString
          } else {
            return nil
          }
        } else {
          return nil
        }
      }
    }
    
    let realizations: NSMutableOrderedSet = []
    for jr in jsonRealizations {
      if let realization = populateRealizationInManagedObjectContext(managedContext, fromJSONDictionary: jr) {
        realizations.addObject(realization)
      }
    }
    
    if let task = Task(insertIntoManagedObjectContext: managedContext) {
      task.typeId = typeId
      task.name = name
      
      task.timesPerDay = timesPerDay
      task.minutesForTimes = minutesForTimes
      task.doseForTimes = doseForTimes
      task.specialFeature = specialFeature
      
      task.startDate = startDate
      task.frequency = frequency
      
      task.endDaysOrTimes = endDaysOrTimes
      
      if task.endDaysOrTimes != 0 {
        task.countEndDate()
      } else {
        task.endDate = endDate
      }
      
      task.comment = comment
      task.realizations = realizations
      
      return task
      
    } else {
      return nil
    }
  }
  
  func populateRealizationInManagedObjectContext(managedContext: NSManagedObjectContext, fromJSONDictionary dict: [String: AnyObject]) -> Realization? {
    guard let dateString = dict["date"] as? String,
      let done = dict["done"] as? [Int]
      else { return nil }
    
    var date: NSDate
    if let dateFromString = VisualConfiguration.dateFromString(dateString, withFormat: .Date) {
      date = dateFromString
    } else {
      return nil
    }
    
    if let realization = Realization(insertIntoManagedObjectContext: managedContext) {
      realization.date = date
      realization.done = done
      
      return realization
    } else {
      return nil
    }
  }
  
//  func pishTask(task: Task, tpd: Int, sd: String) {
//    
//    task.endDaysOrTimes = tpd
//    task.startDate = VisualConfiguration.dateFromString(sd, withFormat: .DateTime)!
//    
//    task.countEndDate()
//    
//    //    print("   times: \(tpd)")
//    //    print(VisualConfiguration.stringFromDate(task.startDate))
//    //    print(VisualConfiguration.stringFromDate(task.endDate))
//    //    print("")
//    
//    
//  }
  
  
  
}
