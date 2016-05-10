//
//  Repository.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

class PetsRepository {
  
  let modelName: String
  
  private lazy var appDocDirectory: NSURL = {
    let fileManager = NSFileManager.defaultManager()
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count - 1]
  }()
  
  private lazy var context: NSManagedObjectContext = {
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
    return managedObjectContext
  }()
  
  private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.appDocDirectory.URLByAppendingPathComponent(self.modelName)
    do {
      let options = [NSMigratePersistentStoresAutomaticallyOption: true]
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
    } catch {
      print("Error adding persistentStore")
    }
    return coordinator
  }()
  
  private lazy var managedObjectModel: NSManagedObjectModel = {
    let modelUrl = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelUrl)!
  }()
  
  init(withModelName modelName: String) {
    self.modelName = modelName
  }
  
  func saveOrRollback() {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        print("Error! Context cannot be saver!")
        context.rollback()
      }
    }
  }
  
  func insertTaskTypeItemBasicValues() -> TaskTypeItemBasicValues? {
    if let taskTypeItemBasicValues = TaskTypeItemBasicValues(insertIntoManagedObjectContext: context) {
      return taskTypeItemBasicValues
    } else {
      return nil
    }
  }
  
  func countAll(entityName: String) -> Int {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.resultType = .CountResultType
    
    do {
      if let results = try context.executeFetchRequest(fetchRequest) as? [NSNumber] {
        if let count = results.first?.integerValue {
          return count
        }
      }
    } catch {
      print("Fetching error!")
    }
    return 0
  }
  
  func fetchAllObjects(forEntityName entityName: String) -> [NSManagedObject]? {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    do {
      if let fetchResults = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
        return fetchResults
      } else {
        return nil
      }
    } catch {
      return nil
    }
    
  }
  
  func fetchAllTaskTypeItemBasicValues() -> [TaskTypeItemBasicValues] {
    if let managedObjects = fetchAllObjects(forEntityName: TaskTypeItemBasicValues.entityName) {
      var allBasicValues = [TaskTypeItemBasicValues]()
      
      for managedObject in managedObjects {
        if let basicValues = managedObject as? TaskTypeItemBasicValues {
          allBasicValues.append(basicValues)
        }
      }
      return allBasicValues
    } else {
      return []
    }
  }
  
  func deleteAllObjects(forEntityName entityName: String) {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    do {
      if let fetchResults = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
        for object in fetchResults {
          context.deleteObject(object)
        }
        context.saveOrRollback()
      }
    } catch {
      print("Some error during cleaning!")
    }
  }
  
  
  
}