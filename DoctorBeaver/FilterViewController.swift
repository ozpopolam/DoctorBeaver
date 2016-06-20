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

class FilterViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var toolBar: UIToolbar!
  
  weak var delegate: FilterDelegate?
  
  var petsRepository: PetsRepository!
  var viewWasLoadedWithPetsRepository = false
  
  var pets = [Pet]()
  var selectedPetsID = Set<Double>()
  
  var checkAllPressed = false
  var unCheckAllPressed = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Фильтр".uppercaseString
    
    fakeNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor())
    fakeNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
    
    fakeNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor())
    fakeNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    
    toolBar.translucent = false
    toolBar.barTintColor = UIColor.lightOrangeColor()
    toolBar.items = []
    
    let flexible = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: Selector())
    toolBar.items?.append(flexible)
    
    let unchBB = barButton("uncheck")
    unchBB.addTarget(self, action: #selector(uncheckAll(_:)), forControlEvents: .TouchUpInside)
    let unchBarButtonItem = UIBarButtonItem(customView: unchBB)
    toolBar.items?.append(unchBarButtonItem)
    
    toolBar.items?.append(flexible)
    
    let chBB = barButton("check")
    chBB.addTarget(self, action: #selector(checkAll(_:)), forControlEvents: .TouchUpInside)
    let chBarButtonItem = UIBarButtonItem(customView: chBB)
    toolBar.items?.append(chBarButtonItem)
    
    toolBar.items?.append(flexible)

    tableView.tableFooterView = UIView(frame: .zero)
    
    if viewIsReadyToBeLoadedWithPetsRepository() {
      reloadFilterTable()
    }
  }
  
  // create bar button with a given image
  func barButton(imageName: String) -> UIButton {
    let bb = UIButton(type: .Custom)
    bb.frame = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: VisualConfiguration.barButtonSize)
    bb.setImage(withName: imageName, ofSize: VisualConfiguration.barIconSize, withTintColor: UIColor.fogColor())
    return bb
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func viewIsReadyToBeLoadedWithPetsRepository() -> Bool {
    if isViewLoaded() && petsRepository != nil && !viewWasLoadedWithPetsRepository {
      viewWasLoadedWithPetsRepository = true
      return true
    } else {
      return false
    }
  }
  
  // check all bar button pressed
  func checkAll(sender: UIBarButtonItem) {
    if !checkAllPressed {
      checkAllPressed = true
      unCheckAllPressed = false
      
      let rowsToUpdate = setAllCellsDoneState(toState: true)
      configureCellDoneState(forRows: rowsToUpdate)
    }
  }
  
  // uncheck all bar button pressed
  func uncheckAll(sender: UIBarButtonItem) {
    if !unCheckAllPressed {
      unCheckAllPressed = true
      checkAllPressed = false
      
      let rowsToUpdate = setAllCellsDoneState(toState: false)
      configureCellDoneState(forRows: rowsToUpdate)
    }
  }
  
  // set all check-status for all pets
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
  
  // configure check-status for given cells
  func configureCellDoneState(forRows rows: [Int]) {
    for ind in 0..<rows.count {
      let indexPath = NSIndexPath(forRow: rows[ind], inSection: 0)
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FilterCell {
        configureCellDoneState(cell, forRowAtIndexPath: indexPath)
      }
    }
  }
  
  func setPetsRepository(petsRepository: PetsRepository) {
    self.petsRepository = petsRepository
    if viewIsReadyToBeLoadedWithPetsRepository() {
      reloadFilterTable()
    }
  }
  
  func reloadFilterTable() {
    pets = petsRepository.fetchAllPets()
    
    // save id of initially selected pets
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
      
      cell.petImageView.image = pet.image
      cell.petNameLabel.text = pet.name
      
      // count all active tasks of a pet
      let activeTasks = pet.countActiveTasks(forDate: NSDate())
      cell.remainTasksLabel.text = activeTasksToString(activeTasks)
      configureCellDoneState(cell, forRowAtIndexPath: indexPath)
      
      return cell
    }
    return UITableViewCell()
  }
  
  // amount of active tasks in readable form
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
  
  // configure appearance of a cell depending on its check status
  func configureCellDoneState(cell: FilterCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let row = indexPath.row
    cell.checkmarkImageView.hidden = !pets[row].selected
    cell.selectView.hidden = pets[row].selected
  }
  
  // done button pressed
  func done(sender: UIButton) {
    // verify if some changes have occurred
    var newSelectedPetsID = Set<Double>()
    var selectedPets: [Pet] = []
    for pet in pets {
      if pet.selected {
        newSelectedPetsID.insert(pet.id)
        selectedPets.append(pet)
      }
    }
    
    // if there were no changes
    if newSelectedPetsID == selectedPetsID {
      cancel()
    } else {
      petsRepository.saveOrRollback()
      delegate?.filter(self, didPickPets: selectedPets)
    }
  }
  
  // cancel button pressed
  func cancel(sender: UIButton? = nil) {
    
    petsRepository.rollback()
    delegate?.filterDidCancel(self)
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
