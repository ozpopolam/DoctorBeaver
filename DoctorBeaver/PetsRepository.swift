//
//  Repository.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData

protocol PetsRepositorySettable: class { // can get and set PetsRepository
  var petsRepository: PetsRepository! { get set }
}

// Obverver-subject protocol
protocol PetsRepositoryStateSubject: class {
  var observers: [WeakPetsRepositoryStateObserver] { get set }
  func addObserver(observer: PetsRepositoryStateObserver)
  func removeObserver(observer: PetsRepositoryStateObserver)
  func notifyObservers()
}

// weak-wrapper for PetsRepositoryStateObserver
class WeakPetsRepositoryStateObserver {
  weak var observer: PetsRepositoryStateObserver?
  init (_ observer: PetsRepositoryStateObserver) {
    self.observer = observer
  }
}
// Obverver protocol
protocol PetsRepositoryStateObserver: class {
  func petsRepositoryDidChange(repository: PetsRepositoryStateSubject)
}

class PetsRepository: PetsRepositoryStateSubject {
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
        notifyObservers() // notify all observers that some changes have happened in repository
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
  
// MARK: Insertion
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
    if let pet = Pet(insertIntoManagedObjectContext: context), let basicValues = fetchPetBasicValues() {
      pet.id = NSDate().timeIntervalSince1970
      pet.basicValues = basicValues
      return pet
    } else {
      return nil
    }
  }
  
  func insertProxyPet() -> Pet? {
    if let pet = Pet(insertIntoManagedObjectContext: context) {
      pet.id = -1
      return pet
    }
    return nil
  }
  
// MARK: Counting
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
  
// MARK: Fetching
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
  
  func fetchAllTaskTypeItems() -> [TaskTypeItem] {
    let managedObjects = fetchAllObjects(forEntityName: TaskTypeItem.entityName)
    
    var taskTypeItems = [TaskTypeItem]()
    for managedObject in managedObjects {
      if let taskTypeItem = managedObject as? TaskTypeItem {
        taskTypeItems.append(taskTypeItem)
      }
    }
    
    return taskTypeItems
  }
  
// MARK: Deletion
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
  
// MARK: PetsRepositoryStateSubject
  var observers = [WeakPetsRepositoryStateObserver]() // observers for PetsRepository's state change
  
  func addObserver(observer: PetsRepositoryStateObserver) {
    observers.append(WeakPetsRepositoryStateObserver(observer))
  }
  
  func removeObserver(observerToRemove: PetsRepositoryStateObserver) {
    for ind in 0..<observers.count {
      if let observer = observers[ind].observer {
        if observerToRemove === observer {
          observers.removeAtIndex(ind)
          break
        }
      }
    }
  }
  
  func notifyObservers() {
    for weakObserver in observers {
      weakObserver.observer?.petsRepositoryDidChange(self)
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