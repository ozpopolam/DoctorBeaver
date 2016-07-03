//
//  Repository.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

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
  lazy var realm: Realm? = {
    do {
      return try Realm()
    } catch {
      print("Error! Realm cannot be initiated!")
      return nil
    }
  }()
  
// MARK: Saving data
  func performChanges(@noescape changes: () -> Void) -> Bool {
    do {
      if let realm = realm {
        try realm.write(changes)
        notifyObservers()
        return true
      }
    } catch {
      print("Changes cannot be perform on petsRepository")
    }
    return false
  }
  
// MARK: Deleting data
  func deleteAll() -> Bool {
    return performChanges {
      realm?.deleteAll()
    }
  }
  
  func delete(object: Object) -> Bool {
    if let object = object as? CascadeDeletable { // object need to perform cascade deletion for its linked objects
      let linkedObjectsToDelete = object.linkedObjectsToDelete
      
      for object in linkedObjectsToDelete {
        performChanges {
          realm?.delete(object)
        }
      }
    }
    
    return performChanges { // delete object itself
      realm?.delete(object)
    }
  }
  
// MARK: Adding data
  func add(object: Object) -> Bool {
    return performChanges {
      realm?.add(object)
    }
  }
  
  func addPet() -> Pet? {
    let pet = Pet()
    if let basicValues = fetchPetBasicValues() {
      pet.basicValues = basicValues
      if add(pet) {
        return pet
      }
    }
    return nil
  }
  
  func addTask() -> Task? {
    let task = Task()
    if add(task) {
      return task
    }
    return nil
  }
  
// MARK: Fetching data
  func fetchAllPets() -> [Pet] {
    var pets = [Pet]()
    
    if let realm = realm {
      let results = realm.objects(Pet.self)
      for result in results {
        pets.append(result)
      }
    }
    return pets
  }
  
  func fetchSelectedPets() -> [Pet] {
    var pets = [Pet]()
    
    if let realm = realm {
      let results = realm.objects(Pet.self).filter("selected = %@", true)
      for result in results {
        pets.append(result)
      }
    }
    return pets
  }
  
  func fetchPetBasicValues() -> PetBasicValues? {
    if let realm = realm {
      if let result = realm.objects(PetBasicValues).first {
        return result
      }
    }
    return nil
  }
  
  func fetchTaskTypeItem(withId id: Int) -> TaskTypeItem? {
    if let realm = realm {
      if let result = realm.objects(TaskTypeItem).filter("id == %@", id).first {
        return result
      }
    }
    return nil
  }
  
  func fetchAllTaskTypeItems() -> [TaskTypeItem] {
    var typeItems = [TaskTypeItem]()
    
    if let realm = realm {
      let results = realm.objects(TaskTypeItem)
      for result in results {
        typeItems.append(result)
      }
    }
    
    return typeItems
  }
  
  func countAllObjects<T: Object>(ofType type: T.Type) -> Int {
    if let realm = realm {
      return realm.objects(type).count
    } else {
      return 0
    }
  }

  

  
//////
  

  

  
  func rollback() {
  }
  
  func saveOrRollback() -> Bool {
    return true

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