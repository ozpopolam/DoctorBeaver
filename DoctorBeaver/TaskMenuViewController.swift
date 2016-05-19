//
//  AddNewTaskViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 18.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

protocol TaskMenuViewControllerDelegate: class {
  func taskMenuViewController(viewController: TaskMenuViewController, didDeleteTask task: Task)
  func taskMenuViewController(viewController: TaskMenuViewController, didSlightlyEditScheduleOfTask task: Task)
  func taskMenuViewController(viewController: TaskMenuViewController, didFullyEditScheduleOfTask task: Task)
}

class TaskMenuViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var fakeNavigationBar: DecoratedNavigationBarView!
  
  weak var delegate: TaskMenuViewControllerDelegate?
  
  var petsRepository: PetsRepository!
  
  var task: Task! // task to show or edit
  var taskWithInitialSettings: Task? // needed to store initial values
  var minutesDoseInitialSettings: (minutes: [Int], dose: [String]) = ([], [])
  
  var tbCnfg = EditShowTaskTableConfiguration()
  
  // types of cells in table
  let headerCellId = "headerCell"
  let menuTextFieldCellId = "menuTextFieldCell"
  let stgTitleValueCellId = "stgTitleValueCell"
  let stgTitleSegmentCellId = "stgTitleSegmentCell"
  let stgDataPickerCellId = "stgDataPickerCell"
  let stgDatePickerCellId = "stgDatePickerCell"
  let stgComplexPickerCellId = "stgComplexPickerCell"
  
  // heights of cells
  let headerHeight: CGFloat = 22.0
  let regularCellHeight: CGFloat = 44.0
  let pickerCellHeight: CGFloat = 216.0
  let complexCellHeight: CGFloat = 260.0
  
  var keyboardHeight: CGFloat!
  
  let editShowMinutesDoseSegueId = "editShowMinutesDoseSegue"
  
  let animationDuration: NSTimeInterval = 0.5 // to animate change of button's icon
  
  var editState = false // adding or editing a task
  var edited = false // task was edited
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = task.typeItem.name.uppercaseString
    
    // button "Delete" (will be hiden or shown depending on editState)
    fakeNavigationBar.setButtonImage("trash", forButton: .CenterRight, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
    fakeNavigationBar.centerRightButton.addTarget(self, action: "trash:", forControlEvents: .TouchUpInside)
    
    configureForEditState()
    
    tableView.tableFooterView = UIView(frame: .zero) // hide footer

    reloadEditShowTaskTable()
  }
  
  // configuring user's possibility of interaction, selection style of cells, showing or hiding necessary buttons
  func configureForEditState(withAnimationDuration animationDuration: NSTimeInterval = 0) {
    if editState {
      // adding or editing task
      
      // button "Cancel"
      fakeNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
      
      fakeNavigationBar.hideButton(.CenterRight) // hide Delete-button
      
      // button "Done"
      fakeNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
    } else {
      // browsing settings of task or deleting it
      
      // button "Back"
      fakeNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.leftButton.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
      
      fakeNavigationBar.showButton(.CenterRight, withAnimationDuration: animationDuration) // show Delete-button
      
      // button "Edit"
      fakeNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.rightButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
    }
    
    configureUserInteractionForEditState()
    configureCellsSelectionStyle()
  }
  
  // fully reload table with data of task
  func reloadEditShowTaskTable() {
    tbCnfg.configure(withTask: task)
    tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    
    // start observing notifications from keyboard to update height of table
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if keyboardHeight == nil {
      // update height of keyboard
      if let userInfo = notification.userInfo {
        if let keyboardSizeNSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
          keyboardHeight = keyboardSizeNSValue.CGRectValue().height
        }
      }
    }
    
    // move lower edge of table to show keyboard
    let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
    tableView.contentInset = contentInsets
    tableView.scrollIndicatorInsets = contentInsets
  }
  
  func keyboardWillHide(notification: NSNotification) {
    // move lower edge of table back
    tableView.contentInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    // stop observing notifications from keyboard
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
  
 // MARK: Actions for buttons
  
  // Back-button
  func back(sender: UIButton) {
    
    // if task for storing initial setting was created, need to delete it
    if let taskWithInitialSettings = taskWithInitialSettings {
      petsRepository.deleteObject(taskWithInitialSettings)
    }
    
    if edited {
      // task was edited
      if tbCnfg.scheduleWasChanged {
        // time frame of task changed
        task.countEndDate()
        delegate?.taskMenuViewController(self, didFullyEditScheduleOfTask: task)
      } else {
        delegate?.taskMenuViewController(self, didSlightlyEditScheduleOfTask: task)
      }
    }
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Delete-button
  func trash(sender: UIButton) {
    let deleteController = UIAlertController(title: "Удалить задание?", message: nil, preferredStyle: .ActionSheet)
    
    let confirmAction = UIAlertAction(title: "Да, давайте удалим", style: .Destructive) {
      (action) -> Void in
      self.delegate?.taskMenuViewController(self, didDeleteTask: self.task)
    }
    
    let cancelAction = UIAlertAction(title: "Нет, я передумал", style: .Cancel) {
      (action) -> Void in
    }
    
    deleteController.addAction(confirmAction)
    deleteController.addAction(cancelAction)
    
    presentViewController(deleteController, animated: true, completion: nil)
  }
  
  // Edit-button
  func edit(sender: UIButton) {
    editState = true
    saveInitialSettings()
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // save initial setting of task
  func saveInitialSettings() {
    if taskWithInitialSettings == nil {
      taskWithInitialSettings = petsRepository.insertTask()
      if let taskWithInitialSettings = taskWithInitialSettings {
        taskWithInitialSettings.copySettings(fromTask: task, withPet: true)
      }
    }
  }
  
  // Cancel-button
  func cancel(sender: UIButton) {
    editState = false // stop editing task
    deactivateAllActiveTextFields() // close all text fields
    
    if taskDidChange() {
      // settings were changed - need to restore them
      loadInitailSettings()
      reloadEditShowTaskTable()
    } else {
      closePickerCellsForShowState() // close all open picker cells
    }
    
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // check whether some settings of task did change
  func taskDidChange() -> Bool {
    // compare new settings to stored ones
    if let taskWithInitialSettings = taskWithInitialSettings {
      return !task.settingsAreEqual(toTask: taskWithInitialSettings)
    } else {
      return false
    }
  }
  
  // restore initial settings of task
  func loadInitailSettings() {
    if let taskWithInitialSettings = taskWithInitialSettings {
      task.copySettings(fromTask: taskWithInitialSettings)
    }
  }
  
  // Done-button
  func done(sender: UIButton) {
    editState = false // stop editing task
    closePickerCellsForShowState()
    deactivateAllActiveTextFields()
    configureForEditState(withAnimationDuration: animationDuration)
    
    edited = taskDidChange()
  }
  //////////////////////// //////////////////////// //////////////////////// ///////////////////////
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == editShowMinutesDoseSegueId {
      if let destinationVC = segue.destinationViewController as? EditShowMinutesDoseTaskViewController {
        if let cell = sender as? StgTitleValueCell {
          destinationVC.task = task
          destinationVC.delegate = self
          
          let tblType = tbCnfg.getESMinutesDoseTaskTblCnfgType(ofTag: cell.tag)
          destinationVC.minutesDoseTblType = tblType
          destinationVC.editState = editState
        }
      }
      
    }
  }
  
}

 // MARK: UITableViewDataSource
extension TaskMenuViewController: UITableViewDataSource {
  
  // user's possibility to select segmented control in a cell
  func configureUserInteractionForEditState() {
    
    for s in 0..<tbCnfg.cellsTagTypeState.count {
      for r in 0..<tbCnfg.cellsTagTypeState[s].count {
        
        let cellTagTypeState = tbCnfg.cellsTagTypeState[s][r]
        if cellTagTypeState.type == .TitleSegmentCell && cellTagTypeState.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) as? StgTitleSegmentCell {
            cell.hideShowSgCtrl.userInteractionEnabled = editState
          }
        }
      }
    }
  }
  
  // selection style for all cells
  func configureCellsSelectionStyle() {
    for s in 0..<tbCnfg.cellsTagTypeState.count {
      for r in 0..<tbCnfg.cellsTagTypeState[s].count {
        
        let cell = tbCnfg.cellsTagTypeState[s][r]
        
        if cell.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) {
            configureCellSelectionStyle(cell)
          }
        }
      }
    }
  }
  
  // selection style of a cell depending on editState
  func configureCellSelectionStyle(cell: UITableViewCell) {
    if editState {
      if let cell = cell as? StgComplexPickerCell {
        cell.selectionStyle = .None
      } else {
        cell.selectionStyle = VisualConfiguration.graySelection
      }
    } else {
      cell.selectionStyle = .None
    }
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tbCnfg.sectionTitles.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tbCnfg.cellsTagTypeState[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cellType = tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].type
    var generalCell: UITableViewCell!
    
    switch cellType {
    case .TextFieldCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTextFieldCellId) as? MenuTextFieldCell {
        configureTextFieldCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleValueCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgTitleValueCellId) as? StgTitleValueCell {
        configureTitleValueCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleSegmentCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgTitleSegmentCellId) as? StgTitleSegmentCell {
        configureTitleSegmentCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .DataPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgDataPickerCellId) as? StgDataPickerCell {
        configureDataPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TimePickerCell, .DateTimePickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgDatePickerCellId) as? StgDatePickerCell {
        configureDatePickerCell(cell, ofType: cellType, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .ComplexPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgComplexPickerCellId) as? StgComplexPickerCell {
        configureComplexPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
    default:
      return UITableViewCell()
    }
    
    configureCellSelectionStyle(generalCell)
    
    return generalCell
  }
  
 // MARK: Configuration of cells of different types
  func configureTextFieldCell(cell: MenuTextFieldCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let tag = tbCnfg.tagForIndexPath(indexPath)
    cell.textField.tag = tag
    cell.textField.delegate = self
    
    cell.textField.autocapitalizationType = .Words
    cell.textField.keyboardAppearance = .Dark
    cell.textField.keyboardType = .Default
    cell.textField.returnKeyType = .Done
    cell.textField.placeholder = tbCnfg.textFieldPlaceholders[tag]
    cell.textField.text = tbCnfg.titleValueValues[cell.textField.tag]
    
    cell.textField.userInteractionEnabled = false
    cell.textField.resignFirstResponder()
  }
  
  func configureTitleValueCell(cell: StgTitleValueCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    cell.tag = tbCnfg.tagForIndexPath(indexPath)
    
    cell.titleLabel.text = tbCnfg.titleValueTitles[cell.tag]
    
    let state = tbCnfg.cellsTagTypeState[section][row].state
    if state == .Accessory {
      cell.accessoryType = .DisclosureIndicator
      cell.valueLabel.text = ""
    } else {
      cell.accessoryType = .None
      cell.valueLabel.text = tbCnfg.titleValueValues[cell.tag]
    }
    
    // text color of valueLabel depends on state of underlying cell, which is used to set text of valueLabel of this cell
    if tbCnfg.cellsTagTypeState[section][row + 1].state == CellState.Hidden {
      cell.valueLabel.textColor = VisualConfiguration.textGrayColor
    } else {
      cell.valueLabel.textColor = VisualConfiguration.textOrangeColor
    }
    
  }
  
  func configureTitleSegmentCell(cell: StgTitleSegmentCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // cell with segmented control with two options: 1 - no value, 2 - some values
    let tag = tbCnfg.tagForIndexPath(indexPath)
    
    cell.hideShowSgCtrl.tag = tag
    cell.delegate = self
    cell.hideShowSgCtrl.userInteractionEnabled = editState

    cell.titleLabel.text = tbCnfg.titleValueTitles[tag]
    
    var frequencySegmentTitles = tbCnfg.frequencySegmentTitles()
    let segmentTitle = tbCnfg.frequencySegmentTitle()
    if segmentTitle.isVoid {
      // no value option
      cell.configure(withValues: frequencySegmentTitles, andSelectedSegment: 0)
    } else {
      // option with some values
      frequencySegmentTitles[1] = segmentTitle
      cell.configure(withValues: frequencySegmentTitles, andSelectedSegment: 1)
    }
  }
  
  func configureDataPickerCell(cell: StgDataPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // this cell always lay below StgTitleValueCell and is used to set its value
    let section = indexPath.section
    let row = indexPath.row
    
    // need to configure it only if it's visible
    if tbCnfg.cellsTagTypeState[section][row].state != .Hidden {
      
      let tag = tbCnfg.tagForIndexPath(indexPath)
      cell.dataPickerView.tag = tag
      
      if let options = tbCnfg.pickerOptions[tag] { // all possible values for picker
        cell.dataPickerView.font = VisualConfiguration.pickerFont
        cell.dataPickerView.textColor = VisualConfiguration.textBlackColor
        
        let initialValues = tbCnfg.initialDataPickerValues(withTag: tag) // initial values to select on picker
        cell.dataPickerView.configure(withOptions: options, andInitialValues: initialValues, andDelegate: self)
      }
    }
  }
  
  func configureDatePickerCell(cell: StgDatePickerCell, ofType cellType: SettingCellType, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    if tbCnfg.cellsTagTypeState[section][row].state != .Hidden {
      let tag = tbCnfg.tagForIndexPath(indexPath)
      cell.datePicker.tag = tag
      
      switch cellType {
      case .TimePickerCell:
        let minutes = tbCnfg.initialDateTimePickerTime(withTag: tag)
        cell.datePicker.configure(withDelegate: self, selectedMinutes: minutes)
        
      case .DateTimePickerCell:
        let dates = tbCnfg.initialDateTimePickerDate(withTag: tag) // initial and minimum possible dates
        cell.datePicker.configure(withDelegate: self, selectedDate: dates.initialDate, andMinimumDate: dates.minimumDate)
      default:
        break
      }
    }
  }
  
  func configureComplexPickerCell(cell: StgComplexPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // cell with segmentd control, which switch between 3 pickers: 2 data-picker and 1 date-picker
    // choice of picker depends on endType: picker for end-times, end-days and end-date
    let section = indexPath.section
    let row = indexPath.row
    
    if tbCnfg.cellsTagTypeState[section][row].state != .Hidden {
      
      var tags = [Int]() // tags for cell and three pickers
      tags.append(tbCnfg.tagForIndexPath(indexPath)) // cell's tag
      // tags for pickers
      tags.append(tbCnfg.tagForEndType(Task.EndType.EndDays))
      tags.append(tbCnfg.tagForEndType(Task.EndType.EndTimes))
      tags.append(tbCnfg.tagForEndType(Task.EndType.EndDate))
      
      cell.configure(withTags: tags, andDelegate: self)
      
      let endSegmentTitles = tbCnfg.endSegmentTitles()
      cell.configure(withSegmentValues: endSegmentTitles, andSelectedSegment: task.endType.rawValue)
      
      let pickerTag = tbCnfg.tagForEndType(task.endType)
      
      if task.endType == .EndDate { // configure date-picker
        let dates = tbCnfg.initialDateTimePickerDate(withTag: pickerTag)
        cell.configure(withDelegate: self, selectedDate: dates.initialDate, andMinimumDate: dates.minimumDate)
      } else { // configure data-picker
        let endOptions = tbCnfg.endOptions()
        let initialValues = tbCnfg.initialDataPickerValues(withTag: pickerTag)
        cell.configure(withTitles: [endOptions], andWithInitialValues: initialValues, andDelegate: self)
      }

    }
  }
  
}

 // MARK: UITableViewDelegate
extension TaskMenuViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if tbCnfg.sectionTitles[section].isVoid { // don't need header for section without title
      return nil
    } else {
      if let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellId) as? HeaderCell {
        headerCell.titleLabel.text = tbCnfg.sectionTitles[section].lowercaseString
        let view = UIView(frame: headerCell.frame) // wrap cell into view
        view.addSubview(headerCell)
        return view
      } else {
        return nil
      }
    }
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if tbCnfg.sectionTitles[section].isVoid { // height of header for section without title is ~ 0
      return CGFloat.min
    } else {
      return headerHeight
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height: CGFloat = CGFloat.min
    
    if tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].state == CellState.Hidden {
      // if cell is hidden, it's height = ~ 0
      return height
    } else {
      // in other cases cell's height depends on its type
      let cellType = tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].type
      switch cellType {
      case .TextFieldCell, .TitleValueCell, .TitleSegmentCell:
        height = regularCellHeight
      case .DataPickerCell, .TimePickerCell, .DateTimePickerCell:
        height = pickerCellHeight
      case .ComplexPickerCell:
        height = complexCellHeight
      default:
        break
      }
      return height
    }
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if editState { // in edit state user can select some types of cells
      let cellType = tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].type
      if cellType == .TextFieldCell || cellType == .TitleValueCell || cellType == .TitleSegmentCell {
        return indexPath
      } else {
        return nil
      }
      
    } else { // in show state user can select only accessory cells
      let cellState = tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].state
      if cellState == .Accessory {
        return indexPath
      } else {
        return nil
      }
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // TextFieldCell, TitleValueCell, TitleSegmentCell or Accessory-cell was selected
    // tapping on the first three leads to opening/closing underlying cells with picker view for value selectio
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = tbCnfg.cellsTagTypeState[section][row].type
    let cellState = tbCnfg.cellsTagTypeState[section][row].state
    
    if cellState == .Accessory {
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTitleValueCell {
        // prepare to edit minutes or doses of task
        performSegueWithIdentifier(editShowMinutesDoseSegueId, sender: cell)
      }
    }
    
    deactivateAllActiveTextFields()
    var rowsToReload: [NSIndexPath] = [] // after opening new picker cell or starting typing in text field, the old picker cell must be closed
    var indexPathToScroll = indexPath
    
    switch cellType {

    case .TextFieldCell:
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTextFieldCell {
        activateVisibleTextField(cell.textField)
        rowsToReload = closeAllOpenPickerCells()
        indexPathToScroll = indexPath
      }
      
    // after tapping on these cell, cell with picker must be revealed or hidden
    case .TitleSegmentCell, .TitleValueCell:
      
      let pickerCellRow = row + 1 // picker lies under tapped cell
      let pickerCellState = tbCnfg.cellsTagTypeState[section][pickerCellRow].state
      let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
      
      if cellType == .TitleSegmentCell {
        
        if tbCnfg.frequencySegmentFirstOption() { // segmented control with first option selected
          rowsToReload = closeAllOpenPickerCells()
        } else { // segmented control with second option selected
          if pickerCellState == .Hidden { // underlying picker was hidden and about to be revealed
            rowsToReload = closeAllOpenPickerCells()
          }
          tbCnfg.toggleCellTagTypeState(atIndexPath: pickerCellIndPth)
          rowsToReload.append(pickerCellIndPth)
        }
        
      } else if cellType == .TitleValueCell {
        
        if pickerCellState == .Hidden {
          rowsToReload = closeAllOpenPickerCells()
        }
        
        if cellState != .Accessory {
          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTitleValueCell {
            if pickerCellState == .Hidden {
              // if cell with picker is about to be revealed, text color of selected cell will become orange (active)
              cell.valueLabel.textColor = VisualConfiguration.textOrangeColor
            } else {
              // if cell with picker is about to be hidden, text color of selected cell will become grey (inactive)
              cell.valueLabel.textColor = VisualConfiguration.textGrayColor
            }
          }
          
          tbCnfg.toggleCellTagTypeState(atIndexPath: pickerCellIndPth) // change state of picker cell from hidden to open or vice versa
          rowsToReload.append(pickerCellIndPth) // reload cells, which state or appearance was modified
          indexPathToScroll = pickerCellIndPth // cell to be focused on
        }
      }
      
    default:
      break
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    // focus on selected cell
    tableView.scrollToRowAtIndexPath(indexPathToScroll, atScrollPosition: .Middle, animated: true)
  }
  
  // change state of open picker cells and return its index paths
  func closeAllOpenPickerCells() -> [NSIndexPath] {
    var rowsToReload: [NSIndexPath] = []
    
    for s in 0..<tbCnfg.cellsTagTypeState.count {
      for r in 0..<tbCnfg.cellsTagTypeState[s].count {
        
        let cell = tbCnfg.cellsTagTypeState[s][r]
        
        if (cell.type == .DataPickerCell || cell.type == .TimePickerCell || cell.type == .DateTimePickerCell || cell.type == .ComplexPickerCell) && cell.state != .Hidden {
          // if cell contains picker and is not hidden
          
          tbCnfg.cellsTagTypeState[s][r].state = .Hidden // change state to hidden
          rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r - 1, inSection: s)) as? StgTitleValueCell {
            // deactive text color of overlying StgTitleValueCell
            cell.valueLabel.textColor = VisualConfiguration.textGrayColor
          }
        }
      }
    }
    return rowsToReload
  }
  
  // close all open picker cells after finishing with editing
  func closePickerCellsForShowState() {
    let rowsToReload = closeAllOpenPickerCells()
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
  
  // cells with given tags need to be reloaded
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

 // MARK: UITextFieldDelegate
extension TaskMenuViewController: UITextFieldDelegate {
  
  // start text inputing
  func activateVisibleTextField(textField: UITextField) {
    if let indexPath = tbCnfg.indexPathForTag(textField.tag) {
      tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].state = .Active
    }
    
    textField.textColor = VisualConfiguration.textBlackColor
    textField.userInteractionEnabled = true
    textField.becomeFirstResponder()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let indexPath = tbCnfg.indexPathForTag(textField.tag) {
      tbCnfg.cellsTagTypeState[indexPath.section][indexPath.row].state = .Visible
    }
    
    textField.textColor = VisualConfiguration.textGrayColor
    textField.resignFirstResponder()
    textField.userInteractionEnabled = false
    return true
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    if let oldText = textField.text {
      let newText = (oldText as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
      // some text was typed - need to save new text in task
      tbCnfg.updateTask(byTextFieldWithTag: textField.tag, byString: newText as String)
      tbCnfg.updateTitleValueValues(ofTag: textField.tag)
    }
    
    return true
  }
  
  // deactivate all text fields
  func deactivateAllActiveTextFields() {
    for s in 0..<tbCnfg.cellsTagTypeState.count {
      for r in 0..<tbCnfg.cellsTagTypeState[s].count {
        
        let cellTTS = tbCnfg.cellsTagTypeState[s][r]
        
        if cellTTS.type == .TextFieldCell && cellTTS.state == .Active {
          tbCnfg.cellsTagTypeState[s][r].state = .Visible
          
          let indexPath = NSIndexPath(forRow: r, inSection: s)
          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTextFieldCell {
            textFieldShouldReturn(cell.textField)
          } else {
            UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
          }
        }
      }
    }
  }
  
}

 // MARK: DataPickerViewDelegate
extension TaskMenuViewController: DataPickerViewDelegate {
  
  func dataPicker(picker: DataPickerView, didPickValues values: [String]) {
    // picker picked some values - need to update cell, which is assigned to show it
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byStrings: values)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dataStillNeeded(fromPicker picker: DataPickerView) -> Bool {
    // when picker chooses some values, after having been hidden - no data is needed from it
    if let cellIndexPath = tbCnfg.indexPathForTag(picker.tag) {
      
      if tbCnfg.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].type == .ComplexPickerCell {
        if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? StgComplexPickerCell {
          
          let pickerIsHidden = cell.hidden(forTag: picker.tag)
          if pickerIsHidden {
            
          }
          
          
          return !cell.hidden(forTag: picker.tag)
        }
      } else if tbCnfg.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }
    return false
  }
  
}

 // MARK: DatePickerDelegate
extension TaskMenuViewController: DatePickerDelegate {
  func datePicker(picker: UIDatePicker, didPickDate date: NSDate) {
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byDateTimeValue: date)
    updateCells(withTags: tagsToUpdate)
  }
  
  func datePicker(picker: UIDatePicker, didPickMinutes minutes: Int) {
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byMinutes: minutes)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dateStillNeeded(fromPicker picker: UIDatePicker) -> Bool {
    
    if let cellIndexPath = tbCnfg.indexPathForTag(picker.tag) {
      
      if tbCnfg.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].type == .ComplexPickerCell {
        if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? StgComplexPickerCell {
          return !cell.hidden(forTag: picker.tag)
        }
      } else if tbCnfg.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }
    
    return false
  }
  
}

 // MARK: DoubleOptionSegmControlDelegate
extension TaskMenuViewController: DoubleOptionSegmControlDelegate {
  func segmControl(sgCtrl: UISegmentedControl, didSelectSegment segment: Int) {
    // first or second option was chosen
    let tagsToUpdate = tbCnfg.updateTask(bySegmentedControlWithTag: sgCtrl.tag, andSegment: segment)
    
    updateCells(withTags: tagsToUpdate)
    if let indexPath = tbCnfg.indexPathForTag(sgCtrl.tag) {
      tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
  }
}

 // MARK: StgComplexPickerCellDelegate
extension TaskMenuViewController: StgComplexPickerCellDelegate {
  
  func getPickerOptionsAndInitialValues(bySelectedSegment index: Int, andByTag tag: Int) -> (options: [[String]], initialValues: [String], delegate: DataPickerViewDelegate) {
    // get options and initial values for a picker, corresponding for specific end type (end-days or end-times)
    let et = Task.EndType(rawValue: index)
    let endOptions = tbCnfg.endOptions(byNewEndType: et)
    let initialValues = tbCnfg.initialDataPickerValues(withTag: tag, andNewEndType: et)
   
    return ([endOptions], initialValues, self)
  }
  
  func getPickerInitialValues(bySelectedSegment index: Int, andByTag tag: Int) -> [String] {
    // get initial values for a picker, corresponding for specific end type (end-days or end-times)
    let et = Task.EndType(rawValue: index)
    let initialValues = tbCnfg.initialDataPickerValues(withTag: tag, andNewEndType: et)
    return initialValues
  }
  
  func getPickerInitialDate(bySelectedSegment index: Int, andByTag tag: Int) -> (iDate: NSDate, mDate: NSDate, delegate: DatePickerDelegate) {
    // get initial and minimum dates for picker for end-date
    let dates = tbCnfg.initialDateTimePickerDate(withTag: tag)
    return (dates.initialDate, dates.minimumDate, self)
  }
  
  func getPickerInitialDate(bySelectedSegment index: Int, andByTag tag: Int) -> NSDate {
    // get initial date for picker for end-date
    let dates = tbCnfg.initialDateTimePickerDate(withTag: tag)
    return dates.initialDate
  }
}


extension TaskMenuViewController: EditShowMinutesDoseTaskVCDelegate {
  func editShowMinutesDoseTaskVC(viewController: EditShowMinutesDoseTaskViewController, didEditMinutesDoseOfTask task: Task, withTblType tblType: ESMinutesDoseTaskTblCnfgType) {
    
    if tblType == .Minutes {
      tbCnfg.savePreviousMinutes()
      tbCnfg.scheduleWasChanged = true
    } else if tblType == .Dose {
      tbCnfg.savePreviousDose()
    }
    
    if editState {
      saveInitialSettings()
    }
    
    if !edited {
      edited = true
    }
    
  }
}

