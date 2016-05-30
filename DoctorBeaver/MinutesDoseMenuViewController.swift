//
//  MinutesDoseMenuViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

protocol EditShowMinutesDoseTaskVCDelegate: class {
  func editShowMinutesDoseTaskVC(viewController: MinutesDoseMenuViewController, didEditMinutesDoseOfTask task: Task, withTblType tblType: MinutesDoseMenuViewController)
}

// type of menu, which is about to be shown when user select corresponding cell
enum MinutesDoseMenuType {
  case Minutes
  case Dose
}

class MinutesDoseMenuViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var tableView: UITableView!
  
  weak var delegate: EditShowMinutesDoseTaskVCDelegate?
  var petsRepository: PetsRepository!
  
  var task: Task! // task's minutes or dose to show or edit
  var minutesDoseInitialSettings: (minutes: [Int], dose: [String]) = ([], [])
  
  var menu = MinutesDoseMenuConfiguration()
  var menuType = MinutesDoseMenuType.Minutes
  var menuMode = MenuMode.Show
  
  // types of cells in table
  let menuTitleValueCellId = "stgTitleValueCell"
  let menuTitleSwitchCellId = "stgTitleSwitchCell"
  let menuDataPickerCellId = "stgDataPickerCell"
  let menuDatePickerCellId = "stgDatePickerCell"
  
  // heights of cells
  let regularCellHeight: CGFloat = 44.0
  let pickerCellHeight: CGFloat = 216.0
  
  let animationDuration = VisualConfiguration.animationDuration
  
  var settingsWereEdited = false // settings were edited
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    
    if menuType == .Minutes {
      decoratedNavigationBar.titleLabel.text = menu.minutesForTimesTitle().uppercaseString
    } else if menuType == .Dose {
      decoratedNavigationBar.titleLabel.text = menu.doseForTimesTitle().uppercaseString
    }
    
    configureForMenuMode()
    tableView.tableFooterView = UIView(frame: .zero)
    reloadMinutesDoseMenuTable()
    
//    if editState {
//      saveInitialSettings()
//    }
  }
  
  func reloadMinutesDoseMenuTable() {
    menu.configure(withTask: task, andType: menuType)
    tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
  }
  
  func configureForMenuMode(withAnimationDuration animationDuration: NSTimeInterval = 0) {
    
    if menuMode == .Edit {
      // editing task
      
      // button "Cancel"
      decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
      
      // button "Done"
      decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
      
    } else if menuMode == .Show {
       // browsing settings of task
      
      // button "Back"
      decoratedNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
      
      // button "Edit"
      decoratedNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
    }
    
    configureUserInteractionForMenuMode()
    configureCellsSelectionStyle()
  }
  
  // user's possibility to select switch control in a cell
  func configureUserInteractionForMenuMode() {
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        
        let cellTTS = menu.cellsTagTypeState[s][r]
        if cellTTS.type == .TitleSwitchCell && cellTTS.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) as? MenuTitleSwitchCell {
            cell.stateSwitch.userInteractionEnabled = true
            configureSwitchTintColor(cell.stateSwitch)
          }
        }
      }
    }
  }
  
  // selection style for all cells
  func configureCellsSelectionStyle() {
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        let cellTTS = menu.cellsTagTypeState[s][r]
        
        if cellTTS.state != .Hidden {
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) {
            configureCellSelectionStyleForMenuMode(cell)
          }
        }
      }
    }
  }
  
// MARK: Actions for buttons
  // Back-button
  func back(sender: UIButton) {
    if settingsWereEdited {
      //delegate?.editShowMinutesDoseTaskVC(<#T##viewController: MinutesDoseMenuViewController##MinutesDoseMenuViewController#>, didEditMinutesDoseOfTask: <#T##Task#>, withTblType: <#T##MinutesDoseMenuViewController#>)
    }
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Edit-button
  func edit(sender: UIButton) {
    menuMode = .Edit
    saveInitialSettings()
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // save initial setting of task
  func saveInitialSettings() {
    if menuType == .Minutes {
      minutesDoseInitialSettings.minutes = task.minutesForTimes
    } else if menuType == .Dose {
      minutesDoseInitialSettings.dose = task.doseForTimes
    }
  }
 
  // Cancel-button
  func cancel(sender: UIButton) {
    menuMode = .Show // stop editing settings
    
    if minutesDoseDidChange() {
      loadInitailSettings()
      reloadMinutesDoseMenuTable()
    } else {
      closePickerCellsForShowState() // close all open picker cells
    }
    
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // check whether settings of task did change
  func minutesDoseDidChange() -> Bool {
    if menuType == .Minutes && task.minutesForTimes == minutesDoseInitialSettings.minutes {
      return false
    } else if menuType == .Dose && task.doseForTimes == minutesDoseInitialSettings.dose {
      return false
    }
    return true
  }
  
  // restore initial settings
  func loadInitailSettings() {
    if menuType == .Minutes {
      task.minutesForTimes = minutesDoseInitialSettings.minutes
    } else if menuType == .Dose {
      task.doseForTimes = minutesDoseInitialSettings.dose
    }
  }
  
  // Done-button
  func done(sender: UIButton) {
    menuMode = .Show
    closePickerCellsForShowState()
    
    // check, whether the equal dose was chosen
    if menuType == .Dose && menu.equalDoseSwitchOn {
      task.setAllDosesEqual()
      menu.configureTitleValueValues()
    }
    
    if minutesDoseDidChange() && !settingsWereEdited {
      settingsWereEdited = true
    }
    
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
}



extension MinutesDoseMenuViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return menu.cellsTagTypeState.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.cellsTagTypeState[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
    var generalCell = UITableViewCell()
    
    switch cellType {
    case .TitleValueCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTitleValueCellId) as? StgTitleValueCell {
        configureTitleValueCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleSwitchCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTitleSwitchCellId) as? MenuTitleSwitchCell {
        configureTitleSwitchCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .DataPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuDataPickerCellId) as? StgDataPickerCell {
        configureDataPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TimePickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuDatePickerCellId) as? StgDatePickerCell {
        configureDatePickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
    default:
      break
    }
    
    configureCellSelectionStyleForMenuMode(generalCell)
    return generalCell
  }
  
  func configureCellSelectionStyleForMenuMode(cell: UITableViewCell) {
    if !(cell is MenuTitleSwitchCell) {
      if menuMode == .Edit {
        cell.selectionStyle = VisualConfiguration.graySelection
      } else if menuMode == .Show {
        cell.selectionStyle = .None
      }
    }
  }

// MARK: Configuration of cells of different types  
  func configureTitleValueCell(cell: StgTitleValueCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    cell.tag = menu.cellsTagTypeState[section][row].tag
    
    if let title = menu.titleValueTitles[cell.tag] {
      cell.titleLabel.text = title
    }
    
    if let value = menu.titleValueValues[cell.tag] {
      cell.valueLabel.text = value
    }
    
    // text color of valueLabel depends on state of underlying cell, which is used to set text of valueLabel of this cell
    if menu.cellsTagTypeState[section][row + 1].state == MinutesDoseMenuCellState.Hidden {
      cell.valueLabel.textColor = VisualConfiguration.lightGrayColor
    } else {
      cell.valueLabel.textColor = VisualConfiguration.lightOrangeColor
    }
  }
  
  func configureTitleSwitchCell(cell: MenuTitleSwitchCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    cell.tag = menu.cellsTagTypeState[section][row].tag
    cell.delegate = self
    
    cell.titleLabel.text = menu.doseForTimesEqualTitle
    cell.stateSwitch.userInteractionEnabled = menuMode == .Edit
    configureSwitchTintColor(cell.stateSwitch)

    //let allDosesAreEqual = menu.allDosesAreEqual()
    cell.stateSwitch.setOn(menu.equalDoseSwitchOn, animated: false)
  }
  
  func configureSwitchTintColor(stateSwitch: UISwitch) {
    if menuMode == .Edit {
      stateSwitch.tintColor = UIColor.lightGrayColor()
      stateSwitch.onTintColor = UIColor.lightGrayColor()
    } else if menuMode == .Show {
      stateSwitch.tintColor = UIColor.mercuryColor()
      stateSwitch.onTintColor = UIColor.mercuryColor()
    }
  }
  
  func configureDataPickerCell(cell: StgDataPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // this cell always lay below MenuTitleValueCell and is used to set its value
    let section = indexPath.section
    let row = indexPath.row
    
    // need to configure it only if it's visible
    if menu.cellsTagTypeState[section][row].state != .Hidden {
      
      let tag = menu.cellsTagTypeState[section][row].tag
      cell.dataPickerView.tag = tag
      
      if let titles = menu.pickerOptionsForDose(forTag: tag) {
        cell.dataPickerView.font = VisualConfiguration.pickerFont
        cell.dataPickerView.textColor = VisualConfiguration.pickerTextColor
        
        let initialValues = menu.initialDataPickerValues(withTag: tag)
        cell.dataPickerView.configure(withOptions: titles, andInitialValues: initialValues, andDelegate: self)
      }
    }
  }
  
  func configureDatePickerCell(cell: StgDatePickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    if menu.cellsTagTypeState[section][row].state != .Hidden {
      let tag = menu.cellsTagTypeState[section][row].tag
      cell.datePicker.tag = tag
      
      let minutes = menu.initialDateTimePickerTime(withTag: tag)
      cell.datePicker.configure(withDelegate: self, selectedMinutes: minutes.selectedMinutes, minimumMinutes: minutes.minimumMinutes, maximumMinutes: minutes.maximumMinutes)
    }
  }
}

extension MinutesDoseMenuViewController: UITableViewDelegate {
  
  // высота ячейки
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let section = indexPath.section
    let row = indexPath.row
    
    var height: CGFloat = CGFloat.min
    
    if tbCnfg.cellTagTypeState[section][row].state == CellState.Hidden {
      // ячейка спрятана - ее высота равна нулю
      return height
    } else {
      // ячейка будет показана - высота вычисляется на основании ее типа
      let cellType = tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].type
      switch cellType {
      case .TitleValueCell, .TitleSwitchCell:
        height = regularCellHeight
      case .DataPickerCell, .TimePickerCell:
        height = pickerCellHeight
      default:
        break
      }
      return height
    }
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if editState {
      let cellType = tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].type
      if cellType == .TitleValueCell {
        return indexPath
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
//  // закрываем все picker после завершения редактирования
//  func closePickerCellsForShowState() {
//    let rowsToReload = closeAllOpenPickerCells()
//    tableView.beginUpdates()
//    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
//    tableView.endUpdates()
//  }
//  
//  
//  
//  
//  
//  // изменяем видимость ячеек на основании switch
//  func toggleCellsState(forSwitchState newSwitchState: Bool) -> [NSIndexPath] {
//    tbCnfg.equalDoseSwitchOn = newSwitchState
//    
//    var oldCellState: CellState
//    var newCellState: CellState
//    
//    if newSwitchState == true {
//      oldCellState = .Visible
//      newCellState = .Hidden
//    } else {
//      oldCellState = .Hidden
//      newCellState = .Visible
//    }
//    
//    var firstTVCellPath = NSIndexPath(forRow: -1, inSection: -1)
//    
//    var rowsToReload: [NSIndexPath] = []
//    for s in 0..<tbCnfg.cellTagTypeState.count {
//      for r in 0..<tbCnfg.cellTagTypeState[s].count {
//        
//        let cell = tbCnfg.cellTagTypeState[s][r]
//        if cell.type == .TitleValueCell || cell.type == .DataPickerCell {
//          if cell.type == .TitleValueCell && firstTVCellPath == NSIndexPath(forRow: -1, inSection: -1)
//           {
//            // первая встретившаяся TitleValueCell
//            firstTVCellPath = NSIndexPath(forRow: r, inSection: s)
//          } else if !((cell.type == .DataPickerCell && s == firstTVCellPath.section && r == firstTVCellPath.row + 1) || (cell.type == .DataPickerCell && !newSwitchState)) {
//            if cell.state == oldCellState {
//              tbCnfg.cellTagTypeState[s][r].state = newCellState
//              rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
//            }
//          }
//        }
//      }
//    }
//    return rowsToReload
//  }
//  
//  // закрываем все открытые picker
//  func closeAllOpenPickerCells() -> [NSIndexPath] {
//    
//    var rowsToReload: [NSIndexPath] = []
//    
//    for s in 0..<tbCnfg.cellTagTypeState.count {
//      for r in 0..<tbCnfg.cellTagTypeState[s].count {
//        
//        let cell = tbCnfg.cellTagTypeState[s][r]
//        
//        if (cell.type == .DataPickerCell || cell.type == .TimePickerCell) && cell.state != .Hidden {
//          tbCnfg.cellTagTypeState[s][r].state = .Hidden
//          
//          rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
//          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r - 1, inSection: s)) as? StgTitleValueCell {
//            // сменить цвет на серый обратно
//            cell.valueLabel.textColor = UIColor.lightGrayColor()
//          }
//        }
//      }
//    }
//    return rowsToReload
//  }
//  
//  // выбрана ячейка
//  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    
//    let section = indexPath.section
//    let row = indexPath.row
//    let cellType = tbCnfg.cellTagTypeState[section][row].type
//    let cellState = tbCnfg.cellTagTypeState[section][row].state
//    
//    // номер ряда находящегося под ячейкой Picker Cell
//    let pickerCellRow = row + 1
//    let pickerCellState = tbCnfg.cellTagTypeState[section][pickerCellRow].state
//    let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
//    
//    var rowsToReload: [NSIndexPath] = []
//    
//    if cellType == .TitleValueCell {
//      // выбрана ячейка TitleValueCell
//      
//      if pickerCellState == .Hidden {
//        rowsToReload = closeAllOpenPickerCells()
//      }
//      
//      if cellState != .Accessory {
//        // ячейка не имеет типа Accessory, значит, нужно показать находящийся под ней PickerCell
//        
//        // проверяем, какой цвет изменяемого значения нужен выбранной TitleValueCell
//        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTitleValueCell {
//          if pickerCellState == .Hidden {
//            cell.valueLabel.textColor = UIColor.lightOrangeColor()
//          } else {
//            cell.valueLabel.textColor = UIColor.lightGrayColor()
//          }
//        }
//        
//        // переводи pickerView в новое состояние скрытости
//        tbCnfg.toggleCellTagTypeState(atIndexPath: pickerCellIndPth)
//        rowsToReload.append(pickerCellIndPth)
//      }
//    }
//    
//    tableView.beginUpdates()
//    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
//    tableView.endUpdates()
//    
//    tableView.deselectRowAtIndexPath(indexPath, animated: false)
//    // проматываем на только что нажатую ячейку
//    tableView.scrollToRowAtIndexPath(pickerCellIndPth, atScrollPosition: .Middle, animated: true)
//  }
  
}

extension MinutesDoseMenuViewController: DataPickerViewDelegate {
  
  func dataPicker(picker: DataPickerView, didPickValues values: [String]) {
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byStrings: values)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dataStillNeeded(fromPicker picker: DataPickerView) -> Bool {
    if let indexPath = tbCnfg.indexPathForTag(picker.tag) {
      if tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].state != .Hidden {
        return true
      }
    }
    
    return false
  }
  
  func updateCells(withTags tags: [Int]) {
    var indexPaths: [NSIndexPath] = []
    for tag in tags {
      tbCnfg.updateTitleValueValues(ofTag: tag)
      if let indexPath = tbCnfg.indexPathForTag(tag) {
        indexPaths.append(indexPath)
      }
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    tableView.endUpdates()
  }
  
}



extension MinutesDoseMenuViewController: StateSwitchDelegate {
  func stateSwitch(stateSwitch: UISwitch, didSetOn setOn: Bool) {
    
    let rowsToReload = toggleCellsState(forSwitchState: setOn)
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
}


extension MinutesDoseMenuViewController: DatePickerDelegate {
  func datePicker(picker: UIDatePicker, didPickDate date: NSDate) { }
  
  func datePicker(picker: UIDatePicker, didPickMinutes minutes: Int) {
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byMinutes: minutes)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dateStillNeeded(fromPicker picker: UIDatePicker) -> Bool {
    if let indexPath = tbCnfg.indexPathForTag(picker.tag) {
      if tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].state != .Hidden {
        return true
      }
    }
    return false
  }
  
}

  

