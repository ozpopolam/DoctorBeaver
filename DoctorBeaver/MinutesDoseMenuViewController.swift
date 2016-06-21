//
//  MinutesDoseMenuViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

// type of menu, which is about to be shown when user select corresponding cell
enum MinutesDoseMenuType {
  case Minutes
  case Dose
}

// mode of menu
enum MinutesDoseMenuMode {
  case Edit
  case Show
}

class MinutesDoseMenuViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var tableView: UITableView!
  
  var petsRepository: PetsRepository!
  
  var task: Task! // task's minutes or dose to show or edit
  typealias MinutesDose = (minutes: [Int], dose: [String])
  var minutesDosePreviousSettings: MinutesDose? // needed to store first, second, third... version of values
  var switchWithPreviousSetting: Bool? // needed to store previous position of an equal switch
  
  var menu = MinutesDoseMenuConfiguration()
  var menuType: MinutesDoseMenuType!
  var menuMode: MinutesDoseMenuMode!
  
  // types of cells in table
  let menuTitleValueCellId = "menuTitleValueCell"
  let menuTitleSwitchCellId = "menuTitleSwitchCell"
  let menuDataPickerCellId = "menuDataPickerCell"
  let menuDatePickerCellId = "menuDatePickerCell"
  
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
      decoratedNavigationBar.titleLabel.text = task.minutesForTimesTitle.uppercaseString
    } else if menuType == .Dose {
      decoratedNavigationBar.titleLabel.text = task.doseForTimesTitle.uppercaseString
    }
    
    if menuMode == .Edit { //after editing task, user chose to edit minutes or dose
      savePreviousSettings()
    }
    
    configureForMenuMode()
    tableView.tableFooterView = UIView(frame: .zero)
    reloadMinutesDoseMenuTable()
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
      decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
      
      // button "Done"
      decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
      
    } else if menuMode == .Show {
       // browsing settings of task
      
      // button "Back"
      decoratedNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: #selector(back(_:)), forControlEvents: .TouchUpInside)
      
      // button "Edit"
      decoratedNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: #selector(edit(_:)), forControlEvents: .TouchUpInside)
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
            cell.stateSwitch.userInteractionEnabled = menuMode == .Edit
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
          let indexPath = NSIndexPath(forRow: r, inSection: s)
          if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            configureCellSelectionStyleForMenuMode(cell, atIndexPath: indexPath)
          }
        }
      }
    }
  }
  
// MARK: Actions for buttons
  // Back-button
  func back(sender: UIButton) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Edit-button
  func edit(sender: UIButton) {
    menuMode = .Edit
    savePreviousSettings()
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // save another version of settings
  func savePreviousSettings() {
    if minutesDosePreviousSettings == nil {
      minutesDosePreviousSettings = ([], [])
    }
    
    if menuType == .Minutes {
      minutesDosePreviousSettings?.minutes = task.minutesForTimes
    } else if menuType == .Dose {
      minutesDosePreviousSettings?.dose = task.doseForTimes
      switchWithPreviousSetting = menu.equalDoseSwitchOn // for Dose-type we need to store previous position of all-equal-switch
    }
  }
 
  // Cancel-button
  func cancel(sender: UIButton) {
    menuMode = .Show // stop editing settings
    
    if minutesDoseIsDifferent(fromMinutesDose: minutesDosePreviousSettings) || switchPositionIsDifferent(fromOldPosition: switchWithPreviousSetting) {
      loadPreviousSettings()
      reloadMinutesDoseMenuTable()
    } else {
      closePickerCellsForShowMenuMode()
    }
    
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // check whether minutes or dose of task did change
  func minutesDoseIsDifferent(fromMinutesDose minutesDoseOldSettings: MinutesDose?) -> Bool {
    // compare new settings to the other version
    if let minutesDoseOldSettings = minutesDoseOldSettings {
      if menuType == .Minutes {
        return task.minutesForTimes != minutesDoseOldSettings.minutes
      } else if menuType == .Dose {
        return task.doseForTimes != minutesDoseOldSettings.dose
      }
    }
    
    return false
  }
  
  // check whether switch did change its position
  func switchPositionIsDifferent(fromOldPosition oldPosition: Bool?) -> Bool {
    if let switchWithPreviousSetting = switchWithPreviousSetting {
      return switchWithPreviousSetting != menu.equalDoseSwitchOn
    }
    return false
  }
  
  // restore initial settings of task
  func loadPreviousSettings() {
    
    if let minutesDosePreviousSettings = minutesDosePreviousSettings {
      if menuType == .Minutes {
        task.minutesForTimes = minutesDosePreviousSettings.minutes
      } else if menuType == .Dose {
        task.doseForTimes = minutesDosePreviousSettings.dose
      }
    }
    
  }
  
  // Done-button
  func done(sender: UIButton) {
    menuMode = .Show
    closePickerCellsForShowMenuMode()
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
}

// MARK: UITableViewDataSource
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
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTitleValueCellId) as? MenuTitleValueCell {
        configureTitleValueCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleSwitchCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTitleSwitchCellId) as? MenuTitleSwitchCell {
        configureTitleSwitchCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .DataPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuDataPickerCellId) as? MenuDataPickerCell {
        configureDataPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TimePickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuDatePickerCellId) as? MenuDatePickerCell {
        configureDatePickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
    }
    
    configureCellSelectionStyleForMenuMode(generalCell, atIndexPath: indexPath)
    return generalCell
  }
  
  // selection style of a cell depending on menuMode
  func configureCellSelectionStyleForMenuMode(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
    
    if menuMode == .Edit && cellType == .TitleValueCell {
      cell.selectionStyle = VisualConfiguration.graySelection
    } else {
      cell.selectionStyle = .None
    }
  }

// MARK: Configuration of cells of different types  
  func configureTitleValueCell(cell: MenuTitleValueCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
  
  func configureDataPickerCell(cell: MenuDataPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
  
  func configureDatePickerCell(cell: MenuDatePickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
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

// MARK: UITableViewDelegate
extension MinutesDoseMenuViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let section = indexPath.section
    let row = indexPath.row
    
    var height: CGFloat = CGFloat.min
    
    if menu.cellsTagTypeState[section][row].state == .Hidden {
      // if cell is hidden, it's height = ~ 0
      return height
    } else {
      // in other cases cell's height depends on its type
      let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
      switch cellType {
      case .TitleValueCell, .TitleSwitchCell:
        height = regularCellHeight
      case .DataPickerCell, .TimePickerCell:
        height = pickerCellHeight
      }
      return height
    }
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      return cell.selectionStyle == VisualConfiguration.graySelection ? indexPath : nil
    } else {
      return nil
    }
  }
  
  // выбрана ячейка
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // TextFieldCell, TitleValueCell, TitleSegmentCell or Accessory-cell was selected
    // tapping on the first three leads to opening/closing underlying cells with picker view for value selectio
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = menu.cellsTagTypeState[section][row].type
    
    var rowsToReload: [NSIndexPath] = [] // after opening new picker cell, the old ones must be closed
    var indexPathToScroll = indexPath
    
    // after tapping on these cell, cell with picker must be revealed or hidden
    if cellType == .TitleValueCell {
      
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTitleValueCell {
        let pickerCellRow = row + 1 // picker lies under tapped cell
        let pickerCellState = menu.cellsTagTypeState[section][pickerCellRow].state
        let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
        
        if pickerCellState == .Hidden { // if picker is hiiden - it is about to be opened and all open ones must be closed
          rowsToReload = closeAllOpenPickerCells()
          // if cell with picker is about to be revealed, text color of selected cell will become orange (active)
          cell.valueLabel.textColor = VisualConfiguration.lightOrangeColor
        } else {
          // if cell with picker is about to be hidden, text color of selected cell will become grey (inactive)
          cell.valueLabel.textColor = VisualConfiguration.lightGrayColor
        }
        
        menu.toggleCellTagTypeState(atIndexPath: pickerCellIndPth) // change state of picker cell from hidden to open or vice versa
        rowsToReload.append(pickerCellIndPth)
        indexPathToScroll = pickerCellIndPth // cell to be focused on
      }
      
    }
    
    // reload cells, which state or appearance were modified
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    tableView.scrollToRowAtIndexPath(indexPathToScroll, atScrollPosition: .Middle, animated: true)
  }
  
  
// MARK: additional methods to control cells' state
  // change state of open picker cells and return its index paths
  func closeAllOpenPickerCells() -> [NSIndexPath] {
    var rowsToReload: [NSIndexPath] = []
    
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        let cellTTS = menu.cellsTagTypeState[s][r]
        
        if (cellTTS.type == .DataPickerCell || cellTTS.type == .TimePickerCell) && cellTTS.state != .Hidden {
          // if cell is a visible picker
          menu.cellsTagTypeState[s][r].state = .Hidden
          
          rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r - 1, inSection: s)) as? MenuTitleValueCell {
            // if cell, lying above the picker is TitleValueCell, which displays its content
            cell.valueLabel.textColor = VisualConfiguration.lightGrayColor
          }
        }
      }
    }
    
    return rowsToReload
  }
  
  // close all open picker cells after finishing with editing
  func closePickerCellsForShowMenuMode() {
    let rowsToReload = closeAllOpenPickerCells()
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
  
  // toggle cell's visibility
  func toggleCellsState(forSwitchState newSwitchState: Bool) -> [NSIndexPath] {
    menu.equalDoseSwitchOn = newSwitchState
    
    var oldCellState: MinutesDoseMenuCellState
    var newCellState: MinutesDoseMenuCellState
    
    let equalDoses = newSwitchState
    
    if equalDoses == true { // new position on a switch
      // if it is on - all doses are equal -> need to hide all pairs of (TitleValue, DataPicker) cells except for the first
      oldCellState = .Visible
      newCellState = .Hidden
    } else {
      // need to show hidden pairs
      oldCellState = .Hidden
      newCellState = .Visible
    }
    
    // path for first TitleValue cell with placeholder value (-1, -1)
    var firstTitleValueCellPath = NSIndexPath(forRow: -1, inSection: -1)
    
    var rowsToReload: [NSIndexPath] = []
    rowsToReload = closeAllOpenPickerCells()
    
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        
        if menu.cellsTagTypeState[s][r].type == .TitleValueCell {
          if firstTitleValueCellPath == NSIndexPath(forRow: -1, inSection: -1) {
            // cell - is the first TitleValue cell -> update indexPath
            firstTitleValueCellPath = NSIndexPath(forRow: r, inSection: s)
          } else if menu.cellsTagTypeState[s][r].state == oldCellState {
            // change state of cell and prepare to reload it
            menu.cellsTagTypeState[s][r].state = newCellState
            rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
          }
        }
      
      }
    }
    return rowsToReload
  }
  
  func updateCells(withTags tags: [Int]) {
    var indexPaths: [NSIndexPath] = []
    for tag in tags {
      // need to update TitleValue cells, which hold value of changed cells
      menu.updateTitleValueValues(ofTag: tag)
      if let indexPath = menu.indexPathForTag(tag) {
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
    // need to update visibility of cells to reflect state of "equal dose"-switch
    let rowsToReload = toggleCellsState(forSwitchState: setOn)
    
    // check, whether the equal dose was chosen
    if menuType == .Dose && menu.equalDoseSwitchOn {
      task.setAllDosesEqual()
      menu.configureTitleValueValues()
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
}

extension MinutesDoseMenuViewController: DataPickerViewDelegate {
  
  func dataPicker(picker: DataPickerView, didPickValues values: [String]) {
    // picker picked some values - need to update cell, which is assigned to show it
    let tagsToUpdate = menu.updateTask(byPickerViewWithTag: picker.tag, byStrings: values)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dataStillNeeded(fromPicker picker: DataPickerView) -> Bool {
    // when picker chooses some values, after having been hidden - no data is needed from it
    if let cellIndexPath = menu.indexPathForTag(picker.tag) {
      if menu.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }
    return false
  }
}

extension MinutesDoseMenuViewController: DatePickerDelegate {
  func datePicker(picker: UIDatePicker, didPickDate date: NSDate) { }
  
  func datePicker(picker: UIDatePicker, didPickMinutes minutes: Int) {
    let tagsToUpdate = menu.updateTask(byPickerViewWithTag: picker.tag, byMinutes: minutes)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dateStillNeeded(fromPicker picker: UIDatePicker) -> Bool {
    if let cellIndexPath = menu.indexPathForTag(picker.tag) {
      if menu.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }
    return false
  }
}
  

