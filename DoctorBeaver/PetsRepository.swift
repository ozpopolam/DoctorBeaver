//
//  Repository.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

protocol PetsRepositorySettable: class {
  // устанавливаем ManagedObjectContext
  var petsRepository: PetsRepository! { get set }
  //func setPetsRepository(petsRepository: PetsRepository)
}

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
  
  func rollback() {
    context.rollback()
  }
  
  func saveOrRollback() -> Bool {
    if context.hasChanges {
      do {
        try context.save()
        return true
      } catch {
        print("Error! Context cannot be saved!")
        context.rollback()
        return false
      }
    } else {
      return true
    }
  }
  
  // insertion
  func insertTaskTypeItemBasicValues() -> TaskTypeItemBasicValues? {
    if let taskTypeItemBasicValues = TaskTypeItemBasicValues(insertIntoManagedObjectContext: context) {
      return taskTypeItemBasicValues
    } else {
      return nil
    }
  }
  
  func insertTaskTypeItem() -> TaskTypeItem? {
    if let taskTypeItem = TaskTypeItem(insertIntoManagedObjectContext: context) {
      return taskTypeItem
    } else {
      return nil
    }
  }
  
  func insertRealization() -> Realization? {
    if let realization = Realization(insertIntoManagedObjectContext: context) {
      return realization
    } else {
      return nil
    }
  }
  
  func insertTask() -> Task? {
    if let task = Task(insertIntoManagedObjectContext: context) {
      return task
    } else {
      return nil
    }
  }
  
  func insertPetBasicValues() -> PetBasicValues? {
    if let petBasicValues = PetBasicValues(insertIntoManagedObjectContext: context) {
      return petBasicValues
    } else {
      return nil
    }
  }
  
  func insertPet() -> Pet? {
    if let pet = Pet(insertIntoManagedObjectContext: context) {
      return pet
    } else {
      return nil
    }
  }
  
  // counting
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
      print("Counting error!")
    }
    return 0
  }
  
  // fetching
  func fetchAllObjects(forEntityName entityName: String) -> [NSManagedObject] {
    let fetchRequest = NSFetchRequest(entityName: entityName)
    
    do {
      if let fetchResults = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
        return fetchResults
      }
    } catch {
      print("Fetching error!")
    }
    return []
  }
  
  func fetchAllPets() -> [Pet] {
    let managedObjects = fetchAllObjects(forEntityName: Pet.entityName)
    
    var pets = [Pet]()
    for managedObject in managedObjects {
      if let pet = managedObject as? Pet {
        pets.append(pet)
      }
    }
    
    return pets
  }
  
  func fetchAllSelectedPets() -> [Pet] {
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    let predicate = NSPredicate(format: "%K == YES", Pet.Keys.selected.rawValue)
    fetchRequest.predicate = predicate
    
    do {
      if let results = try context.executeFetchRequest(fetchRequest) as? [Pet] {
        return results
      }
    } catch {
      print("Fetching error!")
    }
    
    return []
  }
  
  func fetchPetBasicValues() -> PetBasicValues? {
    let fetchRequest = NSFetchRequest(entityName: PetBasicValues.entityName)
    fetchRequest.fetchLimit = 1
    
    do {
      if let results = try context.executeFetchRequest(fetchRequest) as? [PetBasicValues] {
        return results.first
      }
    } catch {
      print("Fetching error!")
    }
    return nil
  }
  
  func fetchTaskTypeItem(withId id: Int) -> TaskTypeItem? {
    let fetchRequest = NSFetchRequest(entityName: TaskTypeItem.entityName)
    fetchRequest.fetchLimit = 1
    let predicate = NSPredicate(format: "%K == %i", TaskTypeItem.Keys.id.rawValue, id)
    fetchRequest.predicate = predicate
    
    do {
      if let results = try context.executeFetchRequest(fetchRequest) as? [TaskTypeItem] {
        return results.first
      }
    } catch {
      print("Fetching error!")
    }
    return nil
  }
  
  // deletion
  
  func deleteObject(object: NSManagedObject) {
    context.deleteObject(object)
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

extension NSManagedObjectContext {
  public func saveOrRollback() {
    if hasChanges {
      do {
        try save()
      } catch {
        print("Context cannot be saved - roll back!")
        rollback()
      }
    }
  }
}