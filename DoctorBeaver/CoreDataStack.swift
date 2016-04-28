//
//  CoreDataStack.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 14.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import CoreData

class CoreDataStack {
  let modelName = "DoctorBeaver"
  
  private lazy var appDocDirectory: NSURL = {
    let fileManager = NSFileManager.defaultManager()
    let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count - 1]
  }()
  
  lazy var context: NSManagedObjectContext = {
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
  
}

extension NSManagedObjectContext {
  public func saveOrRollback() {
    if hasChanges {
      do {
        try save()
      } catch {
        
        print("error!")
        
        rollback()
      }
    }
  }
  
  public func countAll(entityName: String) {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    fetchRequest.resultType = .CountResultType
    
    do {
      if let results = try executeFetchRequest(fetchRequest) as? [NSNumber] {
        if let count = results.first?.integerValue {
          print(count)
        }
      }
    } catch {
      print("Fetching error!")

    }
  }
  
  public func fetchAllObjects(forEntityName entityName: String) -> [NSManagedObject]? {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    do {
      if let fetchResults = try executeFetchRequest(fetchRequest) as? [NSManagedObject] {
        return fetchResults
      } else {
        return nil
      }
    } catch {
      return nil
    }
    
  }
  
  public func deleteAllObjects(forEntityName entityName: String) {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    do {
      if let fetchResults = try executeFetchRequest(fetchRequest) as? [NSManagedObject] {
        for object in fetchResults {
          deleteObject(object)
        }
        saveOrRollback()
      }
    } catch {
      print("Some error during cleaning!")
    }
  }
  
}


