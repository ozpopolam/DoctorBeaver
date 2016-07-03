//
//  TaskMenuViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 18.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

protocol TaskMenuViewControllerDelegate: class {
  func taskMenuViewController(viewController: TaskMenuViewController, didAddTask task: Task)
  func taskMenuViewController(viewController: TaskMenuViewController, didDeleteTask task: Task)
  func taskMenuViewController(viewController: TaskMenuViewController, didSlightlyEditScheduleOfTask task: Task)
  func taskMenuViewController(viewController: TaskMenuViewController, didFullyEditScheduleOfTask task: Task)
}

enum TaskMenuMode {
  case Add
  case Edit
  case Show
}

class TaskMenuViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  
  weak var delegate: TaskMenuViewControllerDelegate?
  
  var petsRepository: PetsRepository!
  
  var task: Task! // task to show or edit
  var taskWithInitialSettings: Task? // needed to store initial (first) values
  var taskWithPreviousSettings: Task? // needed to store second, third... version of values
  
  var menu = TaskMenuConfiguration()
  var menuMode: TaskMenuMode!
  var initialMenuMode: TaskMenuMode!
  
  // types of cells in table
  let headerId = "headerView"
  let menuTextFieldCellId = "menuTextFieldCell"
  let menuTitleValueCellId = "menuTitleValueCell"
  let menuTitleSegmentCellId = "menuTitleSegmentCell"
  let menuDataPickerCellId = "menuDataPickerCell"
  let menuDatePickerCellId = "menuDatePickerCell"
  let menuComplexPickerCellId = "menuComplexPickerCell"
  
  // heights of cells
  let headerHeight: CGFloat = 22.0
  let regularCellHeight: CGFloat = 44.0
  let pickerCellHeight: CGFloat = 216.0
  let complexCellHeight: CGFloat = 260.0
  
  var keyboardHeight: CGFloat!
  
  let minutesDoseMenuSegueId = "minutesDoseMenuSegue" // segue to sub-menu
  var unwindSegueId: String? // id of a possible unwind segue
  
  let animationDuration: NSTimeInterval = 0.5 // to animate change of button's icon

  var taskWasEdited = false // task was edited
  var scheduleWasChanged = false // time-related parts of settings were changed
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = task.typeItem!.name.uppercaseString
    
    // button "Delete" (will be hiden or shown depending on menuMode)
    decoratedNavigationBar.setButtonImage("trash", forButton: .CenterRight, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
    decoratedNavigationBar.centerRightButton.addTarget(self, action: #selector(trash(_:)), forControlEvents: .TouchUpInside)
    
    let tableSectionHeaderNib = UINib(nibName: "TableSectionHeaderView", bundle: nil)
    tableView.registerNib(tableSectionHeaderNib, forHeaderFooterViewReuseIdentifier: headerId)
    
    if menuMode == .Add { // controller has been loaded in add-mode -> need to save initial values
      saveInitialSettings()
      savePreviousSettings()
    }
    
    initialMenuMode = menuMode
    configureForMenuMode()
    
    tableView.tableFooterView = UIView(frame: .zero) // hide footer
    reloadTaskMenuTable()
  }
  
  // configuring user's possibility of interaction, selection style of cells, showing or hiding necessary buttons
  func configureForMenuMode(withAnimationDuration animationDuration: NSTimeInterval = 0) {
    if menuMode == .Add || menuMode == .Edit {
      // adding or editing task
      
      // button "Cancel"
      decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
      
      decoratedNavigationBar.hideButton(.CenterRight) // hide Delete-button
      
      // button "Done"
      decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    } else {
      // browsing settings of task or deleting it
      
      // button "Back"
      decoratedNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: #selector(back(_:)), forControlEvents: .TouchUpInside)
      
      decoratedNavigationBar.showButton(.CenterRight, withAnimationDuration: animationDuration) // show Delete-button
      
      // button "Edit"
      decoratedNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: #selector(edit(_:)), forControlEvents: .TouchUpInside)
    }
    
    configureUserInteractionForMenuMode()
    configureCellsSelectionStyleForMenuMode()
  }
  
  // fully reload table with data of task
  func reloadTaskMenuTable() {
    menu.configure(withTask: task)
    tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true
    
    // start observing notifications from keyboard to update height of table
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    
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
    deleteTemporarySettingsStorage()
    
    if initialMenuMode == .Add {
      delegate?.taskMenuViewController(self, didAddTask: task)
    } else if taskWasEdited {
      // task was edited
      if scheduleWasChanged {
        // time frame of task changed
        task.countEndDate()
        delegate?.taskMenuViewController(self, didFullyEditScheduleOfTask: task)
      } else {
        delegate?.taskMenuViewController(self, didSlightlyEditScheduleOfTask: task)
      }
    }
    
    popTaskMenuViewController()
  }
  
  func deleteTemporarySettingsStorage() {
    // if task for storing initial setting was created, need to delete it
    if let taskWithInitialSettings = taskWithInitialSettings {
      
      taskWasEdited = taskIsDifferent(fromTask: taskWithInitialSettings) // task was edited
      scheduleWasChanged = taskScheduleIsDifferent(fromTask: taskWithInitialSettings) // schedule was edited in that or some previous iteration
      petsRepository.delete(taskWithInitialSettings)
    }
    // if task for storing version of setting was created, need to delete it
    if let taskWithPreviousSettings = taskWithPreviousSettings {
      petsRepository.delete(taskWithPreviousSettings)
    }
  }
  
  func popTaskMenuViewController() {
    if let unwindSegueId = unwindSegueId { // we have id for unwind segue -> use it
      performSegueWithIdentifier(unwindSegueId, sender: self)
    } else {
      navigationController?.popViewControllerAnimated(true) // just close VC
    }
  }
  
  // Delete-button
  func trash(sender: UIButton) {
    let deleteController = UIAlertController(title: "Удалить задание?", message: nil, preferredStyle: .ActionSheet)
    
    let confirmAction = UIAlertAction(title: "Да, давайте удалим", style: .Destructive) {
      (action) -> Void in
      self.delegate?.taskMenuViewController(self, didDeleteTask: self.task)
      self.navigationController?.popViewControllerAnimated(true)
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
    menuMode = .Edit
    saveInitialSettings()
    savePreviousSettings()
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // save initial settings of task
  func saveInitialSettings() {
    if taskWithInitialSettings == nil {
      if let copyTask = petsRepository.addTask() {
        taskWithInitialSettings = copyTask
        petsRepository.performChanges {
          taskWithInitialSettings?.copySettings(fromTask: task, withPet: true)
        }
      }
    }
  }
  
  // save another version of settings
  func savePreviousSettings() {
    if taskWithPreviousSettings == nil {
      if let copyTask = petsRepository.addTask() {
        taskWithPreviousSettings = copyTask
      }
    }
    
    petsRepository.performChanges {
      taskWithPreviousSettings?.copySettings(fromTask: task, withPet: true)
    }
  }
  
  // Cancel-button
  func cancel(sender: UIButton) {
    
    if menuMode == .Add { // user press cancel-button immediately -> user doesn't want to add new task
      deleteTemporarySettingsStorage()
      
      // delete newly created task
      petsRepository.delete(task)
      
      popTaskMenuViewController()
      return
    } else {
      
      menuMode = .Show // stop editing task
      deactivateAllActiveTextFields() // close all text fields
      
      if taskIsDifferent(fromTask: taskWithPreviousSettings) {
        // settings were changed in that iteration - need to restore them
        loadPreviousSettings()
        reloadTaskMenuTable()
      } else {
        closePickerCellsForShowState() // close all open picker cells
      }
      
      configureForMenuMode(withAnimationDuration: animationDuration)
    }
  }
  
  // check whether some settings of task did change
  func taskIsDifferent(fromTask taskWithOldSettings: Task?) -> Bool {
    // compare new settings to the other version
    if let taskWithOldSettings = taskWithOldSettings {
      return !task.allSettingsAreEqual(toTask: taskWithOldSettings)
    } else {
      return false
    }
  }
  
  // check whether some schedule settings of task did change
  func taskScheduleIsDifferent(fromTask taskWithOldSettings: Task?) -> Bool {
    // compare new settings to the other version
    if let taskWithOldSettings = taskWithOldSettings {
      return !task.scheduleSettingsAreEqual(toTask: taskWithOldSettings)
    } else {
      return false
    }
  }
  
  // restore previous settings of task
  func loadPreviousSettings() {
    if let taskWithPreviousSettings = taskWithPreviousSettings {
      petsRepository.performChanges {
        task.copySettings(fromTask: taskWithPreviousSettings)
      }
    }
  }
  
  // Done-button
  func done(sender: UIButton) {
    menuMode = .Show
    closePickerCellsForShowState()
    deactivateAllActiveTextFields()
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == minutesDoseMenuSegueId {
      if let destinationViewController = segue.destinationViewController as? MinutesDoseMenuViewController {
        if let cell = sender as? MenuTitleValueCell {
          destinationViewController.task = task
          //destinationViewController.delegate = self
          destinationViewController.menuType = menu.getMinutesDoseMenuType(ofTag: cell.tag)
          destinationViewController.menuMode = menuMode == .Show ? .Show : .Edit
          
          if menuMode == .Show { // need to make snapshot of task' settings explicitly as TaskMenuViewController does it only in Edit-mode
            saveInitialSettings()
            savePreviousSettings()
          }
          
        }
      }
    }
  }
  
}

 // MARK: UITableViewDataSource
extension TaskMenuViewController: UITableViewDataSource {
  
  // user's possibility to select segmented control in a cell
  func configureUserInteractionForMenuMode() {
    
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        
        let cellTagTypeState = menu.cellsTagTypeState[s][r]
        if cellTagTypeState.type == .TitleSegmentCell && cellTagTypeState.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) as? MenuTitleSegmentCell {
            cell.hideShowSgCtrl.userInteractionEnabled = menuMode == .Add || menuMode == .Edit
          }
        }
      }
    }
  }
  
  // selection style for all cells
  func configureCellsSelectionStyleForMenuMode() {
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        let indexPath = NSIndexPath(forRow: r, inSection: s)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
          configureCellSelectionStyleForMenuMode(cell, atIndexPath: indexPath)
        }
      }
    }
  }
  
  // selection style of a cell depending on menuMode
  func configureCellSelectionStyleForMenuMode(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
    let cellState = menu.cellsTagTypeState[indexPath.section][indexPath.row].state
    
    if (menuMode != .Show && cellType != .ComplexPickerCell) || cellState == .Accessory
    {
      cell.selectionStyle = VisualConfiguration.graySelection
    } else {
      cell.selectionStyle = .None
    }
  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return menu.sectionTitles.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.cellsTagTypeState[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
    var generalCell: UITableViewCell!
    
    switch cellType {
    case .TextFieldCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTextFieldCellId) as? MenuTextFieldCell {
        configureTextFieldCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleValueCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTitleValueCellId) as? MenuTitleValueCell {
        configureTitleValueCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleSegmentCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuTitleSegmentCellId) as? MenuTitleSegmentCell {
        configureTitleSegmentCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .DataPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuDataPickerCellId) as? MenuDataPickerCell {
        configureDataPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TimePickerCell, .DateTimePickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuDatePickerCellId) as? MenuDatePickerCell {
        configureDatePickerCell(cell, ofType: cellType, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .ComplexPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(menuComplexPickerCellId) as? MenuComplexPickerCell {
        configureComplexPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
    default:
      return UITableViewCell()
    }
    
    configureCellSelectionStyleForMenuMode(generalCell, atIndexPath: indexPath)
    
    return generalCell
  }
  
 // MARK: Configuration of cells of different types
  func configureTextFieldCell(cell: MenuTextFieldCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let tag = menu.tagForIndexPath(indexPath)
    let textField = cell.textField
    
    textField.tag = tag
    textField.delegate = self
    
    textField.autocapitalizationType = .Words
    textField.keyboardAppearance = .Dark
    textField.keyboardType = .Default
    textField.returnKeyType = .Done
    textField.placeholder = menu.textFieldPlaceholders[tag]
    textField.text = menu.titleValueValues[cell.textField.tag]
    
    textField.textColorResponder = VisualConfiguration.blackColor
    textField.textColorNonResponder = VisualConfiguration.lightGrayColor
    
    let cellState = menu.cellsTagTypeState[indexPath.section][indexPath.row].state
    cellState == TaskMenuCellState.Visible ? textField.resignFirstResponder() : textField.becomeFirstResponder()
  }
  
  func configureTitleValueCell(cell: MenuTitleValueCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    cell.tag = menu.tagForIndexPath(indexPath)
    
    cell.titleLabel.text = menu.titleValueTitles[cell.tag]
    
    let state = menu.cellsTagTypeState[section][row].state
    if state == .Accessory {
      cell.accessoryType = .DisclosureIndicator
      cell.valueLabel.text = ""
    } else {
      cell.accessoryType = .None
      cell.valueLabel.text = menu.titleValueValues[cell.tag]
    }
    
    // text color of valueLabel depends on state of underlying cell, which is used to set text of valueLabel of this cell
    if menu.cellsTagTypeState[section][row + 1].state == TaskMenuCellState.Hidden {
      cell.valueLabel.textColor = VisualConfiguration.textGrayColor
    } else {
      cell.valueLabel.textColor = VisualConfiguration.textOrangeColor
    }
    
  }
  
  func configureTitleSegmentCell(cell: MenuTitleSegmentCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // cell with segmented control with two options: 1 - no value, 2 - some values
    let tag = menu.tagForIndexPath(indexPath)
    
    cell.hideShowSgCtrl.tag = tag
    cell.delegate = self
    cell.hideShowSgCtrl.userInteractionEnabled = menuMode == .Add || menuMode == .Edit

    cell.titleLabel.text = menu.titleValueTitles[tag]
    
    var frequencySegmentTitles = menu.frequencySegmentTitles()
    let segmentTitle = menu.frequencySegmentTitle()
    if segmentTitle.isVoid {
      // no value option
      cell.configure(withValues: frequencySegmentTitles, andSelectedSegment: 0)
    } else {
      // option with some values
      frequencySegmentTitles[1] = segmentTitle
      cell.configure(withValues: frequencySegmentTitles, andSelectedSegment: 1)
    }
  }
  
  func configureDataPickerCell(cell: MenuDataPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // this cell always lay below MenuTitleValueCell and is used to set its value
    let section = indexPath.section
    let row = indexPath.row
    
    // need to configure it only if it's visible
    if menu.cellsTagTypeState[section][row].state != .Hidden {
      
      let tag = menu.tagForIndexPath(indexPath)
      cell.dataPickerView.tag = tag
      
      if let options = menu.pickerOptions[tag] { // all possible values for picker
        cell.dataPickerView.font = VisualConfiguration.pickerFont
        cell.dataPickerView.textColor = VisualConfiguration.textBlackColor
        
        let initialValues = menu.initialDataPickerValues(withTag: tag) // initial values to select on picker
        cell.dataPickerView.configure(withOptions: options, andInitialValues: initialValues, andDelegate: self)
      }
    }
  }
  
  func configureDatePickerCell(cell: MenuDatePickerCell, ofType cellType: TaskMenuCellType, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    if menu.cellsTagTypeState[section][row].state != .Hidden {
      let tag = menu.tagForIndexPath(indexPath)
      cell.datePicker.tag = tag
      
      switch cellType {
      case .TimePickerCell:
        let minutes = menu.initialDateTimePickerTime(withTag: tag)
        cell.datePicker.configure(withDelegate: self, selectedMinutes: minutes)
        
      case .DateTimePickerCell:
        let dates = menu.initialDateTimePickerDate(withTag: tag) // initial and minimum possible dates
        cell.datePicker.configure(withDelegate: self, selectedDate: dates.initialDate, andMinimumDate: dates.minimumDate)
      default:
        break
      }
    }
  }
  
  func configureComplexPickerCell(cell: MenuComplexPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    // cell with segmentd control, which switch between 3 pickers: 2 data-picker and 1 date-picker
    // choice of picker depends on endType: picker for end-times, end-days and end-date
    let section = indexPath.section
    let row = indexPath.row
    
    if menu.cellsTagTypeState[section][row].state != .Hidden {
      
      var tags = [Int]() // tags for cell and three pickers
      tags.append(menu.tagForIndexPath(indexPath)) // cell's tag
      // tags for pickers
      tags.append(menu.tagForEndType(Task.EndType.EndDays))
      tags.append(menu.tagForEndType(Task.EndType.EndTimes))
      tags.append(menu.tagForEndType(Task.EndType.EndDate))
      
      cell.configure(withTags: tags, andDelegate: self)
      
      let endSegmentTitles = menu.endSegmentTitles()
      cell.configure(withSegmentValues: endSegmentTitles, andSelectedSegment: task.endType.rawValue)
      
      let pickerTag = menu.tagForEndType(task.endType)
      
      if task.endType == .EndDate { // configure date-picker
        let dates = menu.initialDateTimePickerDate(withTag: pickerTag)
        cell.configure(withDelegate: self, selectedDate: dates.initialDate, andMinimumDate: dates.minimumDate)
      } else { // configure data-picker
        let endOptions = menu.endOptions()
        let initialValues = menu.initialDataPickerValues(withTag: pickerTag)
        cell.configure(withTitles: [endOptions], andWithInitialValues: initialValues, andDelegate: self)
      }

    }
  }
  
}

 // MARK: UITableViewDelegate
extension TaskMenuViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if menu.sectionTitles[section].isVoid { // don't need header for section without title
      return nil
    } else {
      if let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerId) as? TableSectionHeaderView {
        header.titleLabel.text = menu.sectionTitles[section].lowercaseString
        header.view.backgroundColor = VisualConfiguration.lightOrangeColor
        return header
      } else {
        return nil
      }
    }
  }

  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if menu.sectionTitles[section].isVoid { // height of header for section without title is ~ 0
      return CGFloat.min
    } else {
      return headerHeight
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height: CGFloat = CGFloat.min
    
    if menu.cellsTagTypeState[indexPath.section][indexPath.row].state == TaskMenuCellState.Hidden {
      // if cell is hidden, it's height = ~ 0
      return height
    } else {
      // in other cases cell's height depends on its type
      let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
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
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      return cell.selectionStyle == VisualConfiguration.graySelection ? indexPath : nil
    } else {
      return nil
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // TextFieldCell, TitleValueCell, TitleSegmentCell or Accessory-cell was selected
    // tapping on the first three leads to opening/closing underlying cells with picker view for value selectio
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = menu.cellsTagTypeState[section][row].type
    let cellState = menu.cellsTagTypeState[section][row].state
    
    if cellState == .Accessory {
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTitleValueCell {
        // prepare to edit minutes or doses of task
        performSegueWithIdentifier(minutesDoseMenuSegueId, sender: cell)
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
      let pickerCellState = menu.cellsTagTypeState[section][pickerCellRow].state
      let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
      
      if cellType == .TitleSegmentCell {
        
        if menu.frequencySegmentFirstOption() { // segmented control with first option selected
          rowsToReload = closeAllOpenPickerCells()
        } else { // segmented control with second option selected
          if pickerCellState == .Hidden { // underlying picker was hidden and about to be revealed
            rowsToReload = closeAllOpenPickerCells()
          }
          menu.toggleCellTagTypeState(atIndexPath: pickerCellIndPth)
          rowsToReload.append(pickerCellIndPth)
        }
        
      } else if cellType == .TitleValueCell {
        
        if pickerCellState == .Hidden {
          rowsToReload = closeAllOpenPickerCells()
        }
        
        if cellState != .Accessory {
          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTitleValueCell {
            if pickerCellState == .Hidden {
              // if cell with picker is about to be revealed, text color of selected cell will become orange (active)
              cell.valueLabel.textColor = VisualConfiguration.textOrangeColor
            } else {
              // if cell with picker is about to be hidden, text color of selected cell will become grey (inactive)
              cell.valueLabel.textColor = VisualConfiguration.textGrayColor
            }
          }
          
          menu.toggleCellTagTypeState(atIndexPath: pickerCellIndPth) // change state of picker cell from hidden to open or vice versa
          rowsToReload.append(pickerCellIndPth)
          indexPathToScroll = pickerCellIndPth // cell to be focused on
        }
      }
      
    default:
      break
    }
    
    // reload cells, which state or appearance were modified
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
    
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        
        let cell = menu.cellsTagTypeState[s][r]
        
        if (cell.type == .DataPickerCell || cell.type == .TimePickerCell || cell.type == .DateTimePickerCell || cell.type == .ComplexPickerCell) && cell.state != .Hidden {
          // if cell contains picker and is not hidden
          
          menu.cellsTagTypeState[s][r].state = .Hidden // change state to hidden
          rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r - 1, inSection: s)) as? MenuTitleValueCell {
            // deactive text color of overlying MenuTitleValueCell
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

 // MARK: UITextFieldDelegate
extension TaskMenuViewController: UITextFieldDelegate {
  
  // start text inputing
  func activateVisibleTextField(textField: UITextField) {
    if let indexPath = menu.indexPathForTag(textField.tag) {
      menu.cellsTagTypeState[indexPath.section][indexPath.row].state = .Active
    }
    
    textField.becomeFirstResponder()
  }
  
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let indexPath = menu.indexPathForTag(textField.tag) {
      menu.cellsTagTypeState[indexPath.section][indexPath.row].state = .Visible
    }
    textField.resignFirstResponder()
    return true
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    if let oldText = textField.text {
      let newText = (oldText as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
      // some text was typed - need to save new text in task
      menu.updateTask(byTextFieldWithTag: textField.tag, byString: newText as String)
      menu.updateTitleValueValues(ofTag: textField.tag)
    }
    
    return true
  }
  
  // deactivate all text fields
  func deactivateAllActiveTextFields() {
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        
        let cellTTS = menu.cellsTagTypeState[s][r]
        
        if cellTTS.type == .TextFieldCell && cellTTS.state == .Active {
          let indexPath = NSIndexPath(forRow: r, inSection: s)
          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTextFieldCell {
            textFieldShouldReturn(cell.textField)
          } else {
            menu.cellsTagTypeState[s][r].state = .Visible
            UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, forEvent: nil)
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
    let tagsToUpdate = menu.updateTask(byPickerViewWithTag: picker.tag, byStrings: values)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dataStillNeeded(fromPicker picker: DataPickerView) -> Bool {
    // when picker chooses some values, after having been hidden - no data is needed from it
    if let cellIndexPath = menu.indexPathForTag(picker.tag) {
      
      if menu.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].type == .ComplexPickerCell {
        if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? MenuComplexPickerCell {
          
          let pickerIsHidden = cell.hidden(forTag: picker.tag)
          if pickerIsHidden {
            
          }
          
          
          return !cell.hidden(forTag: picker.tag)
        }
      } else if menu.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }
    return false
  }
  
}

 // MARK: DatePickerDelegate
extension TaskMenuViewController: DatePickerDelegate {
  func datePicker(picker: UIDatePicker, didPickDate date: NSDate) {
    let tagsToUpdate = menu.updateTask(byPickerViewWithTag: picker.tag, byDateTimeValue: date)
    updateCells(withTags: tagsToUpdate)
  }
  
  func datePicker(picker: UIDatePicker, didPickMinutes minutes: Int) {
    let tagsToUpdate = menu.updateTask(byPickerViewWithTag: picker.tag, byMinutes: minutes)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dateStillNeeded(fromPicker picker: UIDatePicker) -> Bool {
    
    if let cellIndexPath = menu.indexPathForTag(picker.tag) {
      
      if menu.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].type == .ComplexPickerCell {
        if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? MenuComplexPickerCell {
          return !cell.hidden(forTag: picker.tag)
        }
      } else if menu.cellsTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
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
    let tagsToUpdate = menu.updateTask(bySegmentedControlWithTag: sgCtrl.tag, andSegment: segment)
    
    updateCells(withTags: tagsToUpdate)
    if let indexPath = menu.indexPathForTag(sgCtrl.tag) {
      tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
  }
}

 // MARK: MenuComplexPickerCellDelegate
extension TaskMenuViewController: MenuComplexPickerCellDelegate {
  
  func getPickerOptionsAndInitialValues(bySelectedSegment index: Int, andByTag tag: Int) -> (options: [[String]], initialValues: [String], delegate: DataPickerViewDelegate) {
    // get options and initial values for a picker, corresponding for specific end type (end-days or end-times)
    let et = Task.EndType(rawValue: index)
    let endOptions = menu.endOptions(byNewEndType: et)
    let initialValues = menu.initialDataPickerValues(withTag: tag, andNewEndType: et)
   
    return ([endOptions], initialValues, self)
  }
  
  func getPickerInitialValues(bySelectedSegment index: Int, andByTag tag: Int) -> [String] {
    // get initial values for a picker, corresponding for specific end type (end-days or end-times)
    let et = Task.EndType(rawValue: index)
    let initialValues = menu.initialDataPickerValues(withTag: tag, andNewEndType: et)
    return initialValues
  }
  
  func getPickerInitialDate(bySelectedSegment index: Int, andByTag tag: Int) -> (iDate: NSDate, mDate: NSDate, delegate: DatePickerDelegate) {
    // get initial and minimum dates for picker for end-date
    let dates = menu.initialDateTimePickerDate(withTag: tag)
    return (dates.initialDate, dates.minimumDate, self)
  }
  
  func getPickerInitialDate(bySelectedSegment index: Int, andByTag tag: Int) -> NSDate {
    // get initial date for picker for end-date
    let dates = menu.initialDateTimePickerDate(withTag: tag)
    return dates.initialDate
  }
}

