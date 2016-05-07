//
//  FilterViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

protocol FilterDelegate: class {
  func filter(flt: FilterViewController, didPickPets pets: [Pet])
  func filterDidCancel(flt: FilterViewController)
}

protocol FilterDelegateSettable: class {
  weak var delegate: FilterDelegate? { get set }
}

class FilterViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var toolBar: UIToolbar!
  
  weak var delegate: FilterDelegate?
  
  var managedContext: NSManagedObjectContext!
  var viewWasLoadedWithManagedContext = false
  
  let barIconSize = CGSize(width: 25, height: 25)
  
  var pets = [Pet]()
  var selectedPetsID = Set<Double>()
  
  let today = NSDate()
  let calendar = NSCalendar.currentCalendar()
  
  var checkAllPressed = false
  var unCheckAllPressed = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Фильтр".uppercaseString
    
    fakeNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor())
    fakeNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
    
    fakeNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor())
    fakeNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
    
    // настраиваем toolBar
    toolBar.translucent = false
    toolBar.barTintColor = UIColor.lightOrangeColor()
    toolBar.items = []
    
    let flexible = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
    toolBar.items?.append(flexible)
    
    let unchBB = barButton("uncheck")
    unchBB.addTarget(self, action: "uncheckAll:", forControlEvents: .TouchUpInside)
    let unchBarButtonItem = UIBarButtonItem(customView: unchBB)
    toolBar.items?.append(unchBarButtonItem)
    
    toolBar.items?.append(flexible)
    
    let chBB = barButton("check")
    chBB.addTarget(self, action: "checkAll:", forControlEvents: .TouchUpInside)
    let chBarButtonItem = UIBarButtonItem(customView: chBB)
    toolBar.items?.append(chBarButtonItem)
    
    toolBar.items?.append(flexible)

    tableView.tableFooterView = UIView(frame: .zero)
    
    // если view загружено, подгружаем в него данные
    if viewIsReadyToBeLoaded(withManagedContext: self.managedContext) {
      reloadFilterTable()
    }
  }
  
  func barButton(imageName: String) -> UIButton {
    let bb = UIButton(type: .Custom)
    bb.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: VisualConfiguration.iconButtonSize)
    bb.setImage(withName: imageName, ofSize: barIconSize, withTintColor: UIColor.fogColor())
    return bb
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // нажали "Выбрать все" на tool bar
  func checkAll(sender: UIBarButtonItem) {
    if !checkAllPressed {
      checkAllPressed = true
      unCheckAllPressed = false
      
      let rowsToUpdate = setAllCellsDoneState(toState: true)
      configureCellDoneState(forRows: rowsToUpdate)
    }
  }
  
  // нажали "Ничего не выбрать" на tool bar
  func uncheckAll(sender: UIBarButtonItem) {
    if !unCheckAllPressed {
      unCheckAllPressed = true
      checkAllPressed = false
      
      let rowsToUpdate = setAllCellsDoneState(toState: false)
      configureCellDoneState(forRows: rowsToUpdate)
    }
  }
  
  // устанавливаем для всех питомцев одинаковый статус выбранности
  func setAllCellsDoneState(toState state: Bool) -> [Int] {
    var rows: [Int] = []
    
    for ind in 0..<pets.count {
      if pets[ind].selected != state {
        pets[ind].selected = state
        rows.append(ind)
      }
    }
    
    return rows
  }
  
  // конфигурируем внешний вид ячейки для переданных рядов
  func configureCellDoneState(forRows rows: [Int]) {
    for ind in 0..<rows.count {
      let indexPath = NSIndexPath(forRow: rows[ind], inSection: 0)
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterCell {
        configureCellDoneState(cell, forRowAtIndexPath: indexPath)
      }
    }
  }
  
  // перегружаем всю таблицу с питомцами
  func reloadFilterTable() {
    pets = fetchAllPets(fromManagedContext: managedContext)
    
    // запоминаем id питомцев, выбранных изначально
    for pet in pets {
      if pet.selected {
        selectedPetsID.insert(pet.id)
      }
    }
    
    if self.isViewLoaded() {
      tableView.reloadData()
    }
  }
}

extension FilterViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("filterCell", forIndexPath: indexPath) as? FilterCell {
      let pet = pets[indexPath.row]
      
      cell.petImageView.image = UIImage(named: pet.image)
      cell.petNameLabel.text = pet.name
      
      // считаем, сколько неоконченных заданий у питомца
      let activeTasks = countActiveTasks(ofPet: pet)
      cell.remainTasksLabel.text = activeTasksToString(activeTasks)
      configureCellDoneState(cell, forRowAtIndexPath: indexPath)
      
      return cell
    }
    return UITableViewCell()
  }
  
  // число активных заданий в читабельном виде
  func activeTasksToString(actTs: Int) -> String {
    guard actTs != 0 else {
      return "нет активных заданий"
    }
    
    var actTsStr = "\(actTs) "
    
    var divided = actTs
    if actTs > 100 {
      divided = divided % 100
    }
    
    if 11...19 ~= divided {
      actTsStr += "активных заданий"
      return actTsStr
    }
    
    let remainder = actTs % 10
    switch remainder {
    case 0:
      actTsStr += "активных заданий"
    case 1:
      actTsStr += "активное задание"
    case 2, 3, 4, 5, 6, 7, 8, 9:
      actTsStr += "активных задания"
    default:
      break
    }
    
    return actTsStr
  }
  
  
  // число раз в читабельном формате
  func timeStringByIndex(index: Int) -> String {
    var divided = index
    if index > 100 {
      divided = divided % 100
    }
    
    if 11 <= divided && divided <= 19 {
      return "раз"
    }
    
    let remainder = index % 10
    switch remainder {
    case 2, 3, 4:
      return "раза"
    case 0, 1, 5, 6, 7, 8, 9:
      return "раз"
    default:
      return ""
    }
  }
  
  // считаем, сколько неоконченных заданий у питомца
  func countActiveTasks(ofPet pet: Pet) -> Int {
    var actt = 0
    
    for task in pet.tasks {
      if let task = task as? Task {
        if calendar.compareDate(task.startDate, toDate: today, toUnitGranularity: .Minute) != .OrderedDescending &&
          calendar.compareDate(today, toDate: task.endDate, toUnitGranularity: .Minute) != .OrderedDescending
        {
          actt += 1
        }
      }
    }
    return actt
  }
  
  // в зависиомсти о того, выбран ли питомец, конфигурируем вид ячейки
  func configureCellDoneState(cell: FilterCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let row = indexPath.row
    cell.checkmarkImageView.hidden = !pets[row].selected
    cell.selectView.hidden = pets[row].selected
  }
  
}

extension FilterViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    if let cell = cell as? FilterCell {
      let pet = pets[indexPath.row]
      pet.selected = !pet.selected
      
      configureCellDoneState(cell, forRowAtIndexPath: indexPath)
      
      checkAllPressed = false
      unCheckAllPressed = false
    }
  }
  
}

// обращения с CoreData
extension FilterViewController: ManagedObjectContextSettableAndLoadable {
  // устанавливаем ManagedObjectContext
  func setManagedObjectContext(managedContext: NSManagedObjectContext) {
    self.managedContext = managedContext
    
    // если view загружено, подгружаем в него данные
    if viewIsReadyToBeLoaded(withManagedContext: self.managedContext) {
      reloadFilterTable()
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
  
  // выбираем всех питомцев
  func fetchAllPets(fromManagedContext managedContext: NSManagedObjectContext) -> [Pet] {
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    
    do {
      if let results = try managedContext.executeFetchRequest(fetchRequest) as? [Pet] {
        return results.sort{$0.name.localizedStandardCompare($1.name) == .OrderedAscending}
      } else {
        return []
      }
    } catch {
      print("Fetching error!")
      return []
    }
  }
  
  
  
  // пользователь хочет применить фильтр
  func done(sender: UIButton) {
    // проверяем, были ли изменения в выбранности
    var newSelectedPetsID = Set<Double>()
    var selectedPets: [Pet] = []
    for pet in pets {
      if pet.selected {
        newSelectedPetsID.insert(pet.id)
        selectedPets.append(pet)
      }
    }
    
    // если в выбранности ничего не изменилось
    if newSelectedPetsID == selectedPetsID {
      cancel()
    } else {
      managedContext.saveOrRollback()
      delegate?.filter(self, didPickPets: selectedPets)
    }
  }
  
  // пользователь не хочет применять фильтр
  func cancel(sender: UIButton? = nil) {
    // возвращаем изначальное состояние выбранности
    managedContext.rollback()
    delegate?.filterDidCancel(self)
  }
  
}
