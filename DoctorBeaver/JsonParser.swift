//
//  JsonPetParser.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 21.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

class JsonParser {
  let petsRepository: PetsRepository
  let fileName: String
  let fileType: String
  
  init(forPetsRepository petsRepository: PetsRepository, withFileName fileName: String, andType fileType: String) {
    self.petsRepository = petsRepository
    self.fileName = fileName
    self.fileType = fileType
  }
}

class JsonTaskPrimaryValuesParser {
  
  let petsRepository: PetsRepository
  init(forPetsRepository petsRepository: PetsRepository) {
    self.petsRepository = petsRepository
  }
  
  func populateRepositoryWithBasicValues(withFileName fileName: String, andType fileType: String) -> Bool {
    if let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType) {
      if let data = NSData(contentsOfFile: filePath) {
        do {
          if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
            // first populate base with all TaskTypeItems
            if let jsonTaskTypeItemBasicValues = jsonDict["taskTypeItemBasicValues"] as? [String: AnyObject] {
              
              if let taskTypeItemBasicValues = populateRepositoryWithTaskTypeItemBasicValues(fromJSONDictionary: jsonTaskTypeItemBasicValues) {
                
                
                if let jsonTaskTypeItems = jsonDict["taskTypeItems"] as? [[String: AnyObject]] {
                  
                  var taskTypeItems = [TaskTypeItem]()
                  
                  for jsonTaskTypeItem in jsonTaskTypeItems {
                    if let taskTypeItem =  populateRepositoryWithTaskTypeItem(fromJSONDictionary: jsonTaskTypeItem, withTaskTypeItemBasicValues: taskTypeItemBasicValues) {
                      taskTypeItems.append(taskTypeItem)
                    } else {
                      return false
                    }
                  }
                }
              }
            }
            // then populate with PetBasicValues
            if let jsonPetBasicValues = jsonDict["petBasicValues"] as? [String: AnyObject] {
              if let _ = populateRepositoryWithPetBasicValues(fromJSONDictionary: jsonPetBasicValues) {
                return true
              }
            }
            
          }
        } catch {
          print("Some error with JSON-file!")
        }
      }
    }
    return false
  }
  
  func populateRepositoryWithTaskTypeItemBasicValues(fromJSONDictionary dict: [String: AnyObject]) -> TaskTypeItemBasicValues? {
    guard let taskNamePlaceholder = dict["taskNamePlaceholder"] as? String,
      let separator = dict["separator"] as? String,
      let startDateTitle = dict["startDateTitle"] as? String,
      let daysOptions = dict["daysOptions"] as? String,
      let endDaysOrTimesTitle = dict["endDaysOrTimesTitle"] as? String,
      let endDaysOrTimesSegmentTitles = dict["endDaysOrTimesSegmentTitles"] as? String,
      let endDaysOrTimesOptionsPreposition = dict["endDaysOrTimesOptionsPreposition"] as? String,
      let timesOptions = dict["timesOptions"] as? String,
      let commentPlaceholder = dict["commentPlaceholder"] as? String
      else { return nil}
    
    if let taskTypeItemBasicValues = petsRepository.insertTaskTypeItemBasicValues() {
      taskTypeItemBasicValues.taskNamePlaceholder = taskNamePlaceholder
      taskTypeItemBasicValues.separator = separator
      taskTypeItemBasicValues.startDateTitle = startDateTitle
      taskTypeItemBasicValues.daysOptions = daysOptions
      taskTypeItemBasicValues.endDaysOrTimesTitle = endDaysOrTimesTitle
      taskTypeItemBasicValues.endDaysOrTimesSegmentTitles = endDaysOrTimesSegmentTitles
      taskTypeItemBasicValues.endDaysOrTimesOptionsPreposition = endDaysOrTimesOptionsPreposition
      taskTypeItemBasicValues.timesOptions = timesOptions
      taskTypeItemBasicValues.commentPlaceholder = commentPlaceholder
      
      if petsRepository.saveOrRollback() {
        return taskTypeItemBasicValues
      }
    }
    return nil
  }
  
  func populateRepositoryWithTaskTypeItem(fromJSONDictionary dict: [String: AnyObject], withTaskTypeItemBasicValues basicValues: TaskTypeItemBasicValues) -> TaskTypeItem? {
    guard let id = dict["id"] as? Int,
      let name = dict["name"] as? String,
      let iconName = dict["iconName"] as? String,
      let doseUnit = dict["doseUnit"] as? String,
      
      let sectionTitles = dict["sectionTitles"] as? String,
      
      let timesPerDayTitle = dict["timesPerDayTitle"] as? String,
      let timesPerDayOptions = dict["timesPerDayOptions"] as? String,
      let timesPerDayForInitialization = dict["timesPerDayForInitialization"] as? Int,
      
      let minutesForTimesTitle = dict["minutesForTimesTitle"] as? String,
      let minutesForTimesOrderTitles = dict["minutesForTimesOrderTitles"] as? String,
      let minutesForTimesForInitialization = dict["minutesForTimesForInitialization"] as? Int,
      
      let doseForTimesTitle = dict["doseForTimesTitle"] as? String,
      let doseForTimesEqualTitle = dict["doseForTimesEqualTitle"] as? String,
      let doseForTimesOrderTitles = dict["doseForTimesOrderTitles"] as? String,
      let doseForTimesOptions = dict["doseForTimesOptions"] as? String,
      let doseForTimesForInitialization = dict["doseForTimesForInitialization"] as? String,
      
      let specialFeatureTitle = dict["specialFeatureTitle"] as? String,
      let specialFeatureOptions = dict["specialFeatureOptions"] as? String,
      let specialFeatureForInitialization = dict["specialFeatureForInitialization"] as? String,
      
      let frequencyOptionsPreposition = dict["frequencyOptionsPreposition"] as? String,
      let frequencySegmentTitles = dict["frequencySegmentTitles"] as? String,
      let frequencyTitle = dict["frequencyTitle"] as? String
      else { return nil }
    
    
    if let taskTypeItem = petsRepository.insertTaskTypeItem() {
      taskTypeItem.id = id
      taskTypeItem.name = name
      taskTypeItem.iconName = iconName
      taskTypeItem.doseUnit = doseUnit
      
      taskTypeItem.sectionTitles = sectionTitles
      
      taskTypeItem.timesPerDayTitle = timesPerDayTitle
      taskTypeItem.timesPerDayOptions = timesPerDayOptions
      taskTypeItem.timesPerDayForInitialization = timesPerDayForInitialization
      
      taskTypeItem.minutesForTimesTitle = minutesForTimesTitle
      taskTypeItem.minutesForTimesOrderTitles = minutesForTimesOrderTitles
      taskTypeItem.minutesForTimesForInitialization = minutesForTimesForInitialization
      
      taskTypeItem.doseForTimesTitle = doseForTimesTitle
      taskTypeItem.doseForTimesEqualTitle = doseForTimesEqualTitle
      taskTypeItem.doseForTimesOrderTitles = doseForTimesOrderTitles
      taskTypeItem.doseForTimesOptions = doseForTimesOptions
      taskTypeItem.doseForTimesForInitialization = doseForTimesForInitialization
      
      taskTypeItem.specialFeatureTitle = specialFeatureTitle
      taskTypeItem.specialFeatureOptions = specialFeatureOptions
      taskTypeItem.specialFeatureForInitialization = specialFeatureForInitialization
      
      taskTypeItem.frequencyPreposition = frequencyOptionsPreposition
      taskTypeItem.frequencySegmentTitles = frequencySegmentTitles
      taskTypeItem.frequencyTitle = frequencyTitle
      
      taskTypeItem.basicValues = basicValues
      
      if petsRepository.saveOrRollback() {
        return taskTypeItem
      }
    }
    return nil
  }
  
  func populateRepositoryWithPetBasicValues(fromJSONDictionary dict: [String: AnyObject]) -> PetBasicValues? {
    guard let basicName = dict["basicName"] as? String,
      let namePlaceholder = dict["namePlaceholder"] as? String,
      let separator = dict["separator"] as? String,
      let sectionTitles = dict["sectionTitles"] as? String,
      let selectedTitle = dict["selectedTitle"] as? String,
      let selectedForInitialization = dict["selectedForInitialization"] as? Bool
      else { return nil}
    
    if let petBasicValues = petsRepository.insertPetBasicValues() {
      petBasicValues.basicName = basicName
      petBasicValues.namePlaceholder = namePlaceholder
      petBasicValues.separator = separator
      petBasicValues.sectionTitles = sectionTitles
      petBasicValues.selectedTitle = selectedTitle
      petBasicValues.selectedForInitialization = selectedForInitialization
      
      if petsRepository.saveOrRollback() {
        return petBasicValues
      }
    }
    return nil
  }
  
}

class JsonPetsParser: JsonParser {
  
  func populateManagedObjectContextWithJsonPetData() {
    
    if let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType) {
      if let data = NSData(contentsOfFile: filePath) {
        do {
          if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
            
            if let jsonPets = jsonDict["pets"] as? [[String: AnyObject]] {
              for jsonPet in jsonPets {
                populatePetInManagedObjectContext(fromJSONDictionary: jsonPet)
              }
            }
            
          }
        } catch {
          print("Some error with JSON-file!")
        }
      }
    }
  }

  
  func populatePetInManagedObjectContext(fromJSONDictionary dict: [String: AnyObject]) {
    guard let name = dict["name"] as? String,
      let imageName = dict["imageName"] as? String,
      let selected = dict["selected"] as? Bool,
      let jsonTasks = dict["tasks"] as? [[String: AnyObject]]
      else { return }
    
    let tasks: NSMutableSet = []
    
    for jsonTask in jsonTasks {
      if let task = populateTaskInManagedObjectContext(fromJSONDictionary: jsonTask) {
        tasks.addObject(task)
      }
    }
    
    if let pet = petsRepository.insertPet() {
      
      if let petBasicValues = petsRepository.fetchPetBasicValues() {
        pet.basicValues = petBasicValues
      }
      
      pet.name = name
      pet.imageName = imageName
      pet.selected = selected
      pet.tasks = tasks
      
      petsRepository.saveOrRollback()
    } else {
      return
    }
  }
  
  func populateTaskInManagedObjectContext(fromJSONDictionary dict: [String: AnyObject]) -> Task? {
    
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
    if let startDateFromString = DateHelper.dateFromString(startDateString, withFormat: .DateTime) {
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
          if let endDateFromString = DateHelper.dateFromString(endDateString, withFormat: .DateTime) {
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
      if let realization = populateRealizationInManagedObjectContext(fromJSONDictionary: jr) {
        realizations.addObject(realization)
      }
    }
    
    if let task = petsRepository.insertTask() {
      task.typeId = typeId
      
      if let taskTypeItem = petsRepository.fetchTaskTypeItem(withId: task.typeId) {
        task.typeItem = taskTypeItem
      } else {
        return nil
      }
      
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
  
  func populateRealizationInManagedObjectContext(fromJSONDictionary dict: [String: AnyObject]) -> Realization? {
    guard let dateString = dict["date"] as? String,
      let done = dict["done"] as? [Int]
      else { return nil }
    
    var date: NSDate
    if let dateFromString = DateHelper.dateFromString(dateString, withFormat: .Date) {
      date = dateFromString
    } else {
      return nil
    }
    
    if let realization = petsRepository.insertRealization() {
      realization.date = date
      realization.done = done
      
      return realization
    } else {
      return nil
    }
  }
  
}
