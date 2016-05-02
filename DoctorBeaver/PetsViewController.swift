//
//  PetViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 02.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class PetsViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  @IBOutlet weak var warningLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  var managedContext: NSManagedObjectContext!
  var viewWasLoadedWithManagedContext = false
  
  // питомцы, которые будут отражены
  var pets = [Pet]()
  
  // тип сортировки
  enum SortingType {
    case Id
    case AZ
    case ZA
  }
  var lastSortingType: SortingType = .Id
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Питомцы".uppercaseString
    
    // кнопка сортировки
    fakeNavigationBar.setButtonImage("sorting", forButton: .Left, withTintColor: UIColor.fogColor())
    fakeNavigationBar.leftButton.addTarget(self, action: "sort:", forControlEvents: .TouchUpInside)
    
    // кнопка добавления нового питомца
    fakeNavigationBar.setButtonImage("add", forButton: .Right, withTintColor: UIColor.fogColor())
    fakeNavigationBar.rightButton.addTarget(self, action: "add:", forControlEvents: .TouchUpInside)
    
    
    // проверяем, загружен ли контекст
    if viewIsReadyToBeLoaded(withManagedContext: managedContext) {
      // настраиваем view
      fullyReloadPetTable()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // была нажата кнопка "Сортировать"
  func sort(sender: UIButton) {
    
    switch lastSortingType {
    case .Id:
      pets.sortInPlace{return $0.name.localizedStandardCompare($1.name) == .OrderedAscending}
      lastSortingType = .AZ
    case .AZ:
      pets.sortInPlace{return $0.name.localizedStandardCompare($1.name) == .OrderedDescending}
      lastSortingType = .ZA
    case .ZA:
      pets.sortInPlace(sortedByIdDESC)
      lastSortingType = .Id
    }
    
    tableView.reloadData()
  }
  
  // сортируем питомцев по id
  func sortedByIdDESC(lh: Pet, rh: Pet) -> Bool {
    return lh.id > rh.id
  }
  
  
  // была нажата кнопка "Добавить"
  func add(sender: UIButton) {
    print("add")
  }
  
  // заполняем таблицу с нуля
  // настраиваем внешний вид по инфо питомца и инициируем отображение расписания
  func fullyReloadPetTable() {
    // настраиваем расположение кнопок и по необходимости выводим предупреждающие надписи
    if countAllPets(fromManagedContext: managedContext) == 0 {
      // не зарегестрировано ни одного питомца
      // прячем все кнопки с nav bar
      
      //fakeNavigationBar.hideAllButtons()
      
      
      // показываем предупреждение
      showWarningMessage("попробуйте сначала добавить хотя бы одного питомца")
      
    } else {
      reloadSchedule()
    }
    
  }
  
  // загружаем только выбранных питомцев
  func reloadSchedule(withNoFetchRequest noFetchRequest: Bool = false) {
    // прячем view с ошибкой
    hideWarningMessage()
    
    if !noFetchRequest {
      // загружаем питомцев, которых отметил пользователь
      pets = fetchAllPets(fromManagedContext: managedContext)
    }
    
    tableView.reloadData()
  }
  
  // показываем view с предупреждением
  func showWarningMessage(message: String) {
    warningLabel.text = message
  }
  
  // прячем view с предупреждением
  func hideWarningMessage() {
    if tableView.hidden {
      tableView.hidden = false
    }
    warningLabel.text = ""
  }
  
  
}

extension PetsViewController: UITableViewDataSource {
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("petCellBasic", forIndexPath: indexPath) as? UITableViewCell {
      
      let pet = pets[indexPath.row]
      
      cell.textLabel?.text = pet.name
      cell.detailTextLabel?.text = "\(pet.tasks.count)"
      cell.imageView?.image = UIImage(named: pet.image)
      
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
}

extension PetsViewController: UITableViewDelegate {
  
}

// обращения с CoreData
extension PetsViewController: ManagedObjectContextSettableAndLoadable {
  
  // устанавливаем ManagedObjectContext
  func setManagedObjectContext(managedContext: NSManagedObjectContext) {
    self.managedContext = managedContext
    // если view загружено, подгружаем в него данные
    if viewIsReadyToBeLoaded(withManagedContext: self.managedContext) {
      fullyReloadPetTable()
    }
  }
  
  // проверяем, можно ли обновить view данными из managedContext
  func viewIsReadyToBeLoaded(withManagedContext managedContext: NSManagedObjectContext?) -> Bool {
    if self.isViewLoaded() && managedContext != nil && !self.viewWasLoadedWithManagedContext {
      self.viewWasLoadedWithManagedContext = true
      return true
    } else {
      return false
    }
  }
  
  // считаем общее число питомцев
  func countAllPets(fromManagedContext managedContext: NSManagedObjectContext) -> Int {
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    fetchRequest.resultType = .CountResultType
    
    do {
      if let results = try managedContext.executeFetchRequest(fetchRequest) as? [NSNumber] {
        if let count = results.first?.integerValue {
          return count
        } else {
          return 0
        }
      } else {
        return 0
      }
    } catch {
      print("Fetching error!")
      return 0
    }
  }
  
  // выбираем всех питомцев
  func fetchAllPets(fromManagedContext managedContext: NSManagedObjectContext) -> [Pet] {
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    
    do {
      if let results = try managedContext.executeFetchRequest(fetchRequest) as? [Pet] {
        return results.sort(sortedByIdDESC)
      } else {
        return []
      }
    } catch {
      print("Fetching error!")
      return []
    }
  }
}


