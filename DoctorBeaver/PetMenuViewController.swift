//
//  PetMenuViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol PetMenuViewControllerDelegate: class {
  func petMenuViewController(viewController: PetMenuViewController, didDeletePet pet: Pet)
//  func petMenuViewController(viewController: PetMenuViewController, didSlightlyEditScheduleOfTask task: Task)
//  func petMenuViewController(viewController: PetMenuViewController, didFullyEditScheduleOfTask task: Task)
}

enum PetMenuMode {
  case Add
  case Edit
  case Show
}

class PetMenuViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  
  weak var delegate: PetMenuViewControllerDelegate?
  
  var petsRepository: PetsRepository!
  
  var pet: Pet! // pet to show or edit
  var petWithInitialSettings: Pet? // needed to store initial values
  
  var tasksSorted: [Task]!
  
  var menu = PetMenuConfiguration()
  
  
  var menuMode: PetMenuMode = .Add
  
  // types of cells in table
  let headerCellId = "headerCell"
  let titleCellId = "menuTitleCell"
  let textFieldCellId = "menuTextFieldCell"
  let titleImageCellId = "menuTitleImageCell"
  let titleSwitchCellId = "menuTitleSwitchCell"
  let iconTitleCellId = "menuIconTitleCell"
  
  // heights of cells
  let headerHeight: CGFloat = 22.0
  let regularCellHeight: CGFloat = 44.0
  let titleImageCellHeight: CGFloat = 76.0
  
  // icons for cells with accessory
  var infoIcon: UIImage?
  var addIcon: UIImage?
  
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
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Питомец".uppercaseString
    
    // button "Delete" (will be hiden or shown depending on editState)
    decoratedNavigationBar.setButtonImage("trash", forButton: .CenterRight, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
    decoratedNavigationBar.centerRightButton.addTarget(self, action: "trash:", forControlEvents: .TouchUpInside)
    
    infoIcon = UIImage(named: "info")
    infoIcon = infoIcon?.ofSize(VisualConfiguration.accessoryIconSize)
    
    addIcon = UIImage(named: "addAccessory")
    addIcon = addIcon?.ofSize(VisualConfiguration.accessoryIconSize)

    configureForMenuMode()
    
    tableView.tableFooterView = UIView(frame: .zero) // hide footer
    
    menu.configure(withPet: pet, forMenuMode: menuMode)
    tasksSorted = pet.tasksSorted()
    tableView.reloadData()
    
    //reloadMenuTable()
  }
  
  // configuring user's possibility of interaction, selection style of cells, showing or hiding necessary buttons
  func configureForMenuMode(withAnimationDuration animationDuration: NSTimeInterval = 0) {
    if menuMode == .Add || menuMode == .Edit {
      // adding or editing pet
      
      // button "Cancel"
      decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
      
      decoratedNavigationBar.hideButton(.CenterRight) // hide Delete-button
      
      // button "Done"
      decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
    } else { // menuMode == .Show
      // browsing settings of pet or deleting it
      
      // button "Back"
      decoratedNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.leftButton.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
      
      decoratedNavigationBar.showButton(.CenterRight, withAnimationDuration: animationDuration) // show Delete-button
      
      // button "Edit"
      decoratedNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      decoratedNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      decoratedNavigationBar.rightButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
    }
    
    configureInteractionAccessoriesForMenuMode()
    configureCellsSelectionStyleForMenuMode()
    configureAddCellForMenuMode()
  }
  
  // fully reload table with data of task
//  func reloadMenuTable() {
//    menu.configure(withPet: pet)
//    tasksSorted = pet.tasksSorted()
//    tableView.reloadData()
//  }
  
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
    
//    // if task for storing initial setting was created, need to delete it
//    if let taskWithInitialSettings = taskWithInitialSettings {
//      petsRepository.deleteObject(taskWithInitialSettings)
//    }
//    
//    if edited {
//      // task was edited
//      if menu.scheduleWasChanged {
//        // time frame of task changed
//        task.countEndDate()
//        delegate?.taskMenuViewController(self, didFullyEditScheduleOfTask: task)
//      } else {
//        delegate?.taskMenuViewController(self, didSlightlyEditScheduleOfTask: task)
//      }
//    }
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Delete-button
  func trash(sender: UIButton) {
    let deleteController = UIAlertController(title: "Удалить питомца?", message: nil, preferredStyle: .ActionSheet)
    
    let confirmAction = UIAlertAction(title: "Да, давайте удалим", style: .Destructive) {
      (action) -> Void in
      self.delegate?.petMenuViewController(self, didDeletePet: self.pet)
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
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // save initial setting of pet
  func saveInitialSettings() {
    if petWithInitialSettings == nil {
      petWithInitialSettings = petsRepository.insertPet()
      if let petWithInitialSettings = petWithInitialSettings {
        petWithInitialSettings.copySettings(fromPet: pet)
      }
    }
  }
  
  // Cancel-button
  func cancel(sender: UIButton) {
//    editState = false // stop editing task
//    deactivateAllActiveTextFields() // close all text fields
//    
//    if taskDidChange() {
//      // settings were changed - need to restore them
//      loadInitailSettings()
//      reloadEditShowTaskTable()
//    } else {
//      closePickerCellsForShowState() // close all open picker cells
//    }
//    
//    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // check whether some settings of task did change
  func taskDidChange() -> Bool {
//    // compare new settings to stored ones
//    if let taskWithInitialSettings = taskWithInitialSettings {
//      return !task.settingsAreEqual(toTask: taskWithInitialSettings)
//    } else {
//      return false
//    }
    return true
  }
  
  // restore initial settings of task
  func loadInitailSettings() {
//    if let taskWithInitialSettings = taskWithInitialSettings {
//      task.copySettings(fromTask: taskWithInitialSettings)
//    }
  }
  
  // Done-button
  func done(sender: UIButton) {
//    editState = false // stop editing task
//    closePickerCellsForShowState()
//    deactivateAllActiveTextFields()
//    configureForEditState(withAnimationDuration: animationDuration)
//    
//    edited = taskDidChange()
  }
 
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == editShowMinutesDoseSegueId {
//      if let destinationVC = segue.destinationViewController as? EditShowMinutesDoseTaskViewController {
//        if let cell = sender as? StgTitleValueCell {
//          destinationVC.task = task
//          destinationVC.delegate = self
//          
//          let tblType = menu.getESMinutesDoseTaskTblCnfgType(ofTag: cell.tag)
//          destinationVC.minutesDoseTblType = tblType
//          destinationVC.editState = editState
//        }
//      }
//      
//    }
  }
  
}

// MARK: UITableViewDataSource
extension PetMenuViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return menu.sectionTitles.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menu.cellsTagTypeState[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    var generalCell: UITableViewCell!
    
    let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
    switch cellType {
    case .TextFieldCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellId) as? MenuTextFieldCell {
        configureTextFieldCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleImageCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(titleImageCellId) as? MenuTitleImageCell {
        configureTitleImageCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TitleSwitchCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(titleSwitchCellId) as? MenuTitleSwitchCell {
        configureTitleSwitchCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .IconTitleCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(iconTitleCellId) as? MenuIconTitleCell {
        configureIconTitleCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .AddCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(titleCellId) as? MenuTitleCell {
        configureTitleCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
    }
    
    configureCellSelectionStyleForMenuMode(generalCell, atIndexPath: indexPath)
    return generalCell
  }
  
  // user's possibility to select switch control in a cell or tap on a cell with Disclosure-accessory
  func configureInteractionAccessoriesForMenuMode() {
    
    for section in 0..<menu.cellsTagTypeState.count {
      for row in 0..<menu.cellsTagTypeState[section].count {
        let cellType = menu.cellsTagTypeState[section][row].type
        if cellType == PetMenuCellType.TitleSwitchCell || cellType == PetMenuCellType.TitleImageCell {
          let indexPath = NSIndexPath(forRow: row, inSection: section)
          if let _ = tableView.cellForRowAtIndexPath(indexPath) {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
    if cellType == .IconTitleCell ||
      menuMode != .Show && (cellType == .TextFieldCell || cellType == .TitleImageCell || cellType == .AddCell)
    {
      cell.selectionStyle = VisualConfiguration.graySelection
    } else {
      cell.selectionStyle = .None
    }
    
  }
  
  // selection style for all cells
  func configureAddCellForMenuMode() {
    //menu.configureCellTagTypeStateAddCell(forMenuMode: menuMode)
    
    for section in 0..<menu.cellsTagTypeState.count {
      for row in 0..<menu.cellsTagTypeState[section].count {
        
        if menu.cellsTagTypeState[section][row].type == .AddCell {
          menu.cellsTagTypeState[section][row].state = (menuMode == .Show ? .Hidden : .Disclosure)
          let indexPath = NSIndexPath(forRow: row, inSection: section)
          if let _ = tableView.cellForRowAtIndexPath(indexPath) {
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
          }
        }
      }
    }
  }
  
  
  // MARK: Configuration of cells of different types
  func configureTextFieldCell(cell: MenuTextFieldCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let tag = menu.tagForIndexPath(indexPath)
    cell.textField.tag = tag
    cell.textField.delegate = self
    
    cell.textField.autocapitalizationType = .Words
    cell.textField.keyboardAppearance = .Dark
    cell.textField.keyboardType = .Default
    cell.textField.returnKeyType = .Done
    cell.textField.placeholder = pet.namePlaceholder
    cell.textField.text = pet.name
    
    cell.textField.userInteractionEnabled = false
    cell.textField.resignFirstResponder()
  }
  
  func configureTitleImageCell(cell: MenuTitleImageCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.tag = menu.tagForIndexPath(indexPath)
    cell.titleLabel.text = "Изображение питомца"
    cell.imageImageView.image = UIImage(named: pet.image)
    configureTitleImageCellAccessoryForMenuMode(cell)
  }
  
  func configureTitleImageCellAccessoryForMenuMode(cell: MenuTitleImageCell) {
    if menuMode == .Add || menuMode == .Edit {
      cell.accessoryType = .DisclosureIndicator
    } else { // menuMode == .Show
      cell.accessoryType = .None
    }
  }
  
  func configureTitleSwitchCell(cell: MenuTitleSwitchCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.tag = menu.tagForIndexPath(indexPath)
    cell.titleLabel.text = pet.selectedTitle
    configureTitleSwitchCellForMenuMode(cell)
  }
  
  func configureTitleSwitchCellForMenuMode(cell: MenuTitleSwitchCell) {
    if menuMode == .Add || menuMode == .Edit {
      cell.stateSwitch.onTintColor = VisualConfiguration.lightOrangeColor
      cell.stateSwitch.tintColor = VisualConfiguration.lightOrangeColor
    } else { // menuMode == .Show
      cell.stateSwitch.onTintColor = VisualConfiguration.lightGrayColor
      cell.stateSwitch.tintColor = VisualConfiguration.lightGrayColor
    }
    
    cell.stateSwitch.userInteractionEnabled = menuMode != .Show
  }
  
  func configureIconTitleCell(cell: MenuIconTitleCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    let task = tasksSorted[indexPath.row]
    cell.iconImageView.image = UIImage(named: task.typeItem.iconName)
    cell.taskNameLabel.text = task.name
    cell.taskLastRealization.text = "заканчивается: " + DateHelper.dateToString(task.endDate, withDateFormat: DateFormatterFormat.DateTime.rawValue)
    
    if let infoIcon = infoIcon {
      let detailButton = UIButton(type: .Custom)
      detailButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: VisualConfiguration.accessoryIconSize)
      detailButton.setImage(withImage: infoIcon, ofSize: VisualConfiguration.accessoryIconSize, withTintColor: UIColor.blackColor())
      detailButton.addTarget(self, action: "detailButtonTapped:", forControlEvents: .TouchUpInside)
      
      cell.accessoryView = detailButton
    }
    
  }
  
  func configureTitleCell(cell: MenuTitleCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.titleLabel.text = "Добавить задание"
    
    if let addIcon = addIcon {
      let detailButton = UIButton(type: .Custom)
      detailButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: VisualConfiguration.accessoryIconSize)
      detailButton.setImage(withImage: addIcon, ofSize: VisualConfiguration.accessoryIconSize, withTintColor: UIColor.blackColor())
      detailButton.addTarget(self, action: "detailButtonTapped:", forControlEvents: .TouchUpInside)
      
      cell.accessoryView = detailButton
    }
  }
  
  // determine index path for cell, which accessory-button was tapped and call accessoryButtonTappedForRowWithIndexPath
  func detailButtonTapped(sender: UIButton) {
    let senderPoint = sender.convertPoint(CGPointZero, toView: tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(senderPoint) {
      
      let cellType = menu.cellsTagTypeState[indexPath.section][indexPath.row].type
      
      if cellType == .IconTitleCell {
        print(tasksSorted[indexPath.row].name)
      } else if cellType == .AddCell {
        print("Add new task!")
      }
      
      //tableView(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
    }
  }
  
  
}

// MARK: UITableViewDelegate
extension PetMenuViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if menu.sectionTitles[section].isVoid { // don't need header for section without title
      return nil
    } else {
      if let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellId) as? HeaderCell {
        headerCell.titleLabel.text = menu.sectionTitles[section].lowercaseString
        let view = UIView(frame: headerCell.frame) // wrap cell into view
        view.addSubview(headerCell)
        return view
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
    if menu.cellsTagTypeState[indexPath.section][indexPath.row].state == PetMenuCellState.Hidden {
      // if cell is hidden, it's height = ~ 0
      return CGFloat.min
    } else {
      if menu.cellsTagTypeState[indexPath.section][indexPath.row].type == PetMenuCellType.TitleImageCell {
        return titleImageCellHeight
      }
    }
    return regularCellHeight
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      return cell.selectionStyle == VisualConfiguration.graySelection ? indexPath : nil
    } else {
      return nil
    }
  }
  
  func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//    let timeRealization = timeRealizationForRowAtIndexPath(indexPath)
//    accessoryButtonTask = timeRealization.realization.task
//    performSegueWithIdentifier(editShowTaskSegueId, sender: self)
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // TextFieldCell, TitleValueCell, TitleSegmentCell or Accessory-cell was selected
    // tapping on the first three leads to opening/closing underlying cells with picker view for value selectio
    
    deactivateAllActiveTextFields()
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = menu.cellsTagTypeState[section][row].type
    //let cellState = menu.cellsTagTypeState[section][row].state
    
    switch cellType {
    case .TextFieldCell:
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTextFieldCell {
        activateVisibleTextField(cell.textField)
      }
      
    case .IconTitleCell:
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuIconTitleCell {
        print(cell.taskNameLabel.text)
      }
    
    default:
      break
    }
    
//    if cellState == .Disclosure {
//      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTitleImageCell {
//        // prepare to edit minutes or doses of task
//        performSegueWithIdentifier(editShowMinutesDoseSegueId, sender: cell)
//      }
//    }
    
//    deactivateAllActiveTextFields()
//    var rowsToReload: [NSIndexPath] = [] // after opening new picker cell or starting typing in text field, the old picker cell must be closed
    
    //switch cellType {
      
//    case .TextFieldCell:
//      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTextFieldCell {
//        activateVisibleTextField(cell.textField)
//        indexPathToScroll = indexPath
//      }
      
//      // after tapping on these cell, cell with picker must be revealed or hidden
//    case .TitleSegmentCell, .TitleValueCell:
//      
//      let pickerCellRow = row + 1 // picker lies under tapped cell
//      let pickerCellState = menu.cellsTagTypeState[section][pickerCellRow].state
//      let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
//      
//      if cellType == .TitleSegmentCell {
//        
//        if menu.frequencySegmentFirstOption() { // segmented control with first option selected
//          rowsToReload = closeAllOpenPickerCells()
//        } else { // segmented control with second option selected
//          if pickerCellState == .Hidden { // underlying picker was hidden and about to be revealed
//            rowsToReload = closeAllOpenPickerCells()
//          }
//          menu.toggleCellTagTypeState(atIndexPath: pickerCellIndPth)
//          rowsToReload.append(pickerCellIndPth)
//        }
//        
//      } else if cellType == .TitleValueCell {
//        
//        if pickerCellState == .Hidden {
//          rowsToReload = closeAllOpenPickerCells()
//        }
//        
//        if cellState != .Accessory {
//          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTitleValueCell {
//            if pickerCellState == .Hidden {
//              // if cell with picker is about to be revealed, text color of selected cell will become orange (active)
//              cell.valueLabel.textColor = VisualConfiguration.textOrangeColor
//            } else {
//              // if cell with picker is about to be hidden, text color of selected cell will become grey (inactive)
//              cell.valueLabel.textColor = VisualConfiguration.textGrayColor
//            }
//          }
//          
//          menu.toggleCellTagTypeState(atIndexPath: pickerCellIndPth) // change state of picker cell from hidden to open or vice versa
//          rowsToReload.append(pickerCellIndPth) // reload cells, which state or appearance was modified
//          indexPathToScroll = pickerCellIndPth // cell to be focused on
//        }
//      }
      
//    default:
//      break
//    }
    
//    tableView.beginUpdates()
//    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
//    tableView.endUpdates()
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    // focus on selected cell
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
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
extension PetMenuViewController: UITextFieldDelegate {
  
  // start text inputing
  func activateVisibleTextField(textField: UITextField) {
    if let indexPath = menu.indexPathForTag(textField.tag) {
      menu.cellsTagTypeState[indexPath.section][indexPath.row].state = .Active
    }
    
    textField.textColor = VisualConfiguration.textBlackColor
    textField.userInteractionEnabled = true
    textField.becomeFirstResponder()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let indexPath = menu.indexPathForTag(textField.tag) {
      menu.cellsTagTypeState[indexPath.section][indexPath.row].state = .Visible
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
      menu.updateTask(byTextFieldWithTag: textField.tag, byString: newText as String)
      menu.updateTitleValueValues(ofTag: textField.tag)
    }
    
    return true
  }
  
  override func resignFirstResponder() -> Bool {
    return super.resignFirstResponder()
    
    
    
  }
  
  // deactivate all text fields
  func deactivateAllActiveTextFields() {
    for s in 0..<menu.cellsTagTypeState.count {
      for r in 0..<menu.cellsTagTypeState[s].count {
        
        let cellTTS = menu.cellsTagTypeState[s][r]
        
        if cellTTS.type == .TextFieldCell && cellTTS.state == .Active {
          menu.cellsTagTypeState[s][r].state = .Visible
          
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