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
  func petMenuViewController(viewController: PetMenuViewController, didEditPet pet: Pet)
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
  var petWasEdited = false // some settings of pet were edited
  var tasksSortedByActiveness: (active: [Task], completed: [Task]) = ([], [])
  
  var menu = PetMenuConfiguration()
  var menuMode: PetMenuMode!
  
  // types of cells in table
  let headerId = "headerView"
  let titleCellId = "menuTitleCell"
  let textFieldCellId = "menuTextFieldCell"
  let titleImageCellId = "menuTitleImageCell"
  let titleSwitchCellId = "menuTitleSwitchCell"
  let iconTitleCellId = "menuIconTitleCell"
  
  let editPetImageSegueId = "editPetImageSegue"
  let editShowTaskSegueId = "editShowTaskSegue"
  
  // heights of cells
  let headerHeight: CGFloat = 22.0
  let regularCellHeight: CGFloat = 44.0
  let titleImageCellHeight: CGFloat = 76.0
  
  // icons for cells with accessory
  var infoIcon: UIImage?
  var addIcon: UIImage?
  
  var keyboardHeight: CGFloat!
  
  let animationDuration: NSTimeInterval = 0.5 // to animate change of button's icon
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Питомец".uppercaseString
    
    // button "Delete" (will be hiden or shown depending on menuMode)
    decoratedNavigationBar.setButtonImage("trash", forButton: .CenterRight, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
    decoratedNavigationBar.centerRightButton.addTarget(self, action: "trash:", forControlEvents: .TouchUpInside)
    
    infoIcon = UIImage(named: "info")
    infoIcon = infoIcon?.ofSize(VisualConfiguration.accessoryIconSize)
    
    addIcon = UIImage(named: "addAccessory")
    addIcon = addIcon?.ofSize(VisualConfiguration.accessoryIconSize)
    
    let tableSectionHeaderNib = UINib(nibName: "TableSectionHeaderView", bundle: nil)
    tableView.registerNib(tableSectionHeaderNib, forHeaderFooterViewReuseIdentifier: headerId)

    //menuMode = .Edit
    configureForMenuMode()
    
    tableView.tableFooterView = UIView(frame: .zero) // hide footer
    
    menu.configure(withPet: pet, forMenuMode: menuMode)
    
    tasksSortedByActiveness = pet.tasksSortedByActiveness(forDate: NSDate())
    tableView.reloadData()
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
    // if pet for storing initial setting was created, need to delete it
    if let petWithInitialSettings = petWithInitialSettings {
      petsRepository.deleteObject(petWithInitialSettings)
    }
    
    if petWasEdited {
      delegate?.petMenuViewController(self, didEditPet: pet)
    }
    
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
    menuMode = .Show
    deactivateAllActiveTextFields()
    
    if petDidChange() {
      // settings were changed - need to restore them
      loadInitailSettings()
      tableView.reloadData()
    }
    configureForMenuMode(withAnimationDuration: animationDuration)
  }
  
  // check whether some settings of pet did change
  func petDidChange() -> Bool {
    if let petWithInitialSettings = petWithInitialSettings {
      return !pet.settingsAreEqual(toPet: petWithInitialSettings)
    } else {
      return false
    }
  }
  
  // restore initial settings of pet
  func loadInitailSettings() {
    if let petWithInitialSettings = petWithInitialSettings {
      pet.copySettings(fromPet: petWithInitialSettings)
    }
  }
  
  // Done-button
  func done(sender: UIButton) {
    menuMode = .Show
    deactivateAllActiveTextFields()
    configureForMenuMode(withAnimationDuration: animationDuration)
    petWasEdited = petDidChange()
  }
 
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == editPetImageSegueId {
      
      if let destinationViewController = segue.destinationViewController as? PetImageViewController {
        destinationViewController.delegate = self
        destinationViewController.petCurrentImageName = pet.imageName
      }
      
    } else if segue.identifier == editShowTaskSegueId {
      
      if let destinationViewController = segue.destinationViewController as? TaskMenuViewController, let task = sender as? Task {
        destinationViewController.delegate = self
        destinationViewController.petsRepository = petsRepository
        destinationViewController.task = task
        destinationViewController.menuMode = .Show
      }
      
    }
    
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
    let textField = cell.textField
    
    textField.tag = tag
    textField.delegate = self
    
    textField.autocapitalizationType = .Words
    textField.keyboardAppearance = .Dark
    textField.keyboardType = .Default
    textField.returnKeyType = .Done
    textField.placeholder = pet.namePlaceholder
    textField.text = pet.name
    
    textField.textColorResponder = VisualConfiguration.blackColor
    textField.textColorNonResponder = VisualConfiguration.lightGrayColor
    
    let cellState = menu.cellsTagTypeState[indexPath.section][indexPath.row].state
    cellState == PetMenuCellState.Visible ? textField.resignFirstResponder() : textField.becomeFirstResponder()
  }
  
  func configureTitleImageCell(cell: MenuTitleImageCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.tag = menu.tagForIndexPath(indexPath)
    cell.titleLabel.text = "Изображение питомца"
    cell.imageImageView.image = UIImage(named: pet.imageName)
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
    cell.titleLabel.text = pet.selectedTitle
    cell.stateSwitch.tag = menu.tagForIndexPath(indexPath)
    cell.stateSwitch.setOn(pet.selected, animated: false)
    cell.delegate = self
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
    
    let (task, taskIsActive) = getTaskAndActiveness(forIndexPathRow: indexPath.row)
    
    if let task = task {
      cell.iconImageView.image = UIImage(named: task.typeItem.iconName)
      cell.taskNameLabel.text = task.name
      cell.accessoryView = getAccessoryImageView(withIcon: infoIcon)
      
      if taskIsActive {
        cell.taskLastRealization.text = "заканчивается: " + DateHelper.dateToString(task.endDate, withDateFormat: DateFormatterFormat.DateTime.rawValue)
      } else {
        cell.taskLastRealization.text = "закончилось"
      }
    }
    
  }
  
  func getTaskAndActiveness(forIndexPathRow row: Int) -> (task: Task?, isActive: Bool) {
    
    var taskInActiveTasks: Bool?
    if row < tasksSortedByActiveness.active.count {
      taskInActiveTasks = true
    } else if row < tasksSortedByActiveness.active.count + tasksSortedByActiveness.completed.count {
      taskInActiveTasks = false
    }
    
    if let taskInActiveTasks = taskInActiveTasks {
      var task: Task
      if taskInActiveTasks {
        task = tasksSortedByActiveness.active[row]
        return (task, true)
      } else {
        task = tasksSortedByActiveness.completed[row - tasksSortedByActiveness.active.count]
        return (task, false)
      }
    }
    
    return (nil, false)
  }
  
  func configureTitleCell(cell: MenuTitleCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if menu.cellsTagTypeState[indexPath.section][indexPath.row].state != .Hidden {
      cell.titleLabel.text = "Добавить задание"
      cell.accessoryView = getAccessoryImageView(withIcon: addIcon)
    }
  }
  
  // create image view to use it as accessory view in a cell
  func getAccessoryImageView(withIcon icon: UIImage?) -> UIView? {
    if let icon = icon {
      let iconImageView = UIImageView()
      
      iconImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: VisualConfiguration.accessoryIconSize)
      iconImageView.contentMode = .ScaleAspectFit
      iconImageView.image = icon
      
      return iconImageView
    } else {
      return nil
    }
  }
  
}

// MARK: UITableViewDelegate
extension PetMenuViewController: UITableViewDelegate {
  
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
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // TextFieldCell, TitleValueCell, TitleSegmentCell or Accessory-cell was selected
    // tapping on the first three leads to opening/closing underlying cells with picker view for value selectio
    
    deactivateAllActiveTextFields()
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = menu.cellsTagTypeState[section][row].type
    
    switch cellType {
    case .TextFieldCell: // cell for pet's name
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTextFieldCell {
        activateVisibleTextField(cell.textField)
      }
      
    case .TitleImageCell: // cell for pet's image
      performSegueWithIdentifier(editPetImageSegueId, sender: self)
      
    case .IconTitleCell: // cell for pet's task
      let (task, _) = getTaskAndActiveness(forIndexPathRow: indexPath.row)
      if let task = task {
        performSegueWithIdentifier(editShowTaskSegueId, sender: task)
      }
      
    case .AddCell: // cell for adding pet's task
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuTitleCell {
        print(cell.titleLabel.text)
      }
    
    default:
      break
    }
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    // focus on selected cell
    tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
  }
  
}

// MARK: UITextFieldDelegate
extension PetMenuViewController: UITextFieldDelegate {
  
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
      menu.updatePet(byTextFieldWithTag: textField.tag, byString: newText as String)
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
            UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
          }
        }
      }
    }
  }
  
}

extension PetMenuViewController: StateSwitchDelegate {
  func stateSwitch(stateSwitch: UISwitch, didSetOn setOn: Bool) {
    deactivateAllActiveTextFields()
    menu.updatePet(byStateSwitchWithTag: stateSwitch.tag, byState: setOn)
    print(pet.selected)
  }
}

extension PetMenuViewController: PetImageViewControllerDelegate {
  func petImageViewControllerDidCancel(viewController: PetImageViewController) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  func petImageViewController(viewController: PetImageViewController, didSelectNewImageName imageName: String) {
    navigationController?.popViewControllerAnimated(true)
    pet.imageName = imageName
    
    for section in 0..<menu.cellsTagTypeState.count {
      for row in 0..<menu.cellsTagTypeState[section].count {
        if menu.cellsTagTypeState[section][row].type == .TitleImageCell {
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) as? MenuTitleImageCell{
            cell.imageImageView.image = UIImage(named: pet.imageName)
          }
        }
      }
    }
    
  }
  
}

extension PetMenuViewController: TaskMenuViewControllerDelegate {
  func taskMenuViewController(viewController: TaskMenuViewController, didDeleteTask task: Task) {
    
    navigationController?.popViewControllerAnimated(true)
    
    let (row, taskIsActive) = getRowAndActiveness(forTask: task)
    if let row = row, let taskIsActive = taskIsActive {
      if taskIsActive {
        tasksSortedByActiveness.active.removeAtIndex(row)
      } else {
        tasksSortedByActiveness.completed.removeAtIndex(row)
      }
      
      menu.deleteOneCellForTask()
      
      // delete task and save it
      petsRepository.deleteObject(task)
      petsRepository.saveOrRollback()
      
      tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: menu.taskSection)], withRowAnimation: .Automatic)
      
      if pet.tasks.isEmpty {
        if let header = tableView.headerViewForSection(menu.taskSection) as? TableSectionHeaderView {
          header.titleLabel.text = "нет ни одного задания"
        }
      }
      
    }
  }
  
  func getRowAndActiveness(forTask task: Task) -> (row: Int?, isActive: Bool?) {
    if let index = tasksSortedByActiveness.active.indexOf(task) {
      return (index, true)
    } else if let index = tasksSortedByActiveness.completed.indexOf(task) {
      return (index, false)
    }
    return (nil, nil)
  }
  
  func taskMenuViewController(viewController: TaskMenuViewController, didSlightlyEditScheduleOfTask task: Task) {
    if let indexPathRow = getIndexPathRow(forTask: task) {
      let indexPath = NSIndexPath(forRow: indexPathRow, inSection: menu.taskSection)
      tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
  }
  
  func getIndexPathRow(forTask task: Task) -> Int? {
    if let index = tasksSortedByActiveness.active.indexOf(task) {
      return index
    } else if let index = tasksSortedByActiveness.completed.indexOf(task) {
      return tasksSortedByActiveness.active.count + index
    }
    return nil
  }
  
  func taskMenuViewController(viewController: TaskMenuViewController, didFullyEditScheduleOfTask task: Task) {
    navigationController?.popViewControllerAnimated(true)
    tasksSortedByActiveness = pet.tasksSortedByActiveness(forDate: NSDate())
    tableView.reloadSections(NSIndexSet(index: menu.taskSection), withRowAnimation: .Automatic)
  }
}

extension NSSet {
  var isEmpty: Bool {
    get {
      return self.count == 0
    }
  }
}