//
//  AddNewTaskViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 18.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

protocol EditShowTaskVCDelegate: class {
  func editShowTaskVC(viewController: EditShowTaskViewController, didDeleteTask task: Task)
  func editShowTaskVC(viewController: EditShowTaskViewController, didSlightlyEditTask task: Task)
  func editShowTaskVC(viewController: EditShowTaskViewController, didFullyEditTask task: Task)
}

class EditShowTaskViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  
  weak var delegate: EditShowTaskVCDelegate?
  
  var managedContext: NSManagedObjectContext!
  
  // задание
  var task: Task!
  var taskWithInitialSettings: Task?
  var minutesDoseInitialSettings: (minutes: [Int], dose: [String]) = ([], [])
  
  var tbCnfg = EditShowTaskTableConfiguration()
  
  let headerCellId = "headerCell"
  let stgTextFieldCellId = "stgTextFieldCell"
  let stgTitleValueCellId = "stgTitleValueCell"
  let stgTitleSegmentCellId = "stgTitleSegmentCell"
  let stgDataPickerCellId = "stgDataPickerCell"
  let stgDatePickerCellId = "stgDatePickerCell"
  let stgComplexPickerCellId = "stgComplexPickerCell"
  
  let editShowMinutesDoseSegueId = "editShowMinutesDoseSegue"
  
  let headerHeight: CGFloat = 22.0
  let regularCellHeight: CGFloat = 44.0
  let pickerCellHeight: CGFloat = 216.0
  let complexCellHeight: CGFloat = 260.0
  
  var keyboardHeight: CGFloat!
  
  let animationDuration: NSTimeInterval = 0.5
  
  // добавляем или редактируем задание
  var editState = false
  // было ли отредактировано
  var edited = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = task.type.toString().uppercaseString
    
    // кнопка "Удалить"
    fakeNavigationBar.setButtonImage("trash", forButton: .CenterRight, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
    fakeNavigationBar.centerRightButton.addTarget(self, action: "trash:", forControlEvents: .TouchUpInside)
    
    configureForEditState()
    
    tableView.tableFooterView = UIView(frame: .zero)

    reloadEditShowTaskTable()
  }
  
  func configureForEditState(withAnimationDuration animationDuration: NSTimeInterval = 0) {
    
    if editState {
      // редактирование задания
      
      // кнопка "Отменить"
      fakeNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
      
      // эта кнопка не нужна, мы ее прячем
      fakeNavigationBar.hideButton(.CenterRight)
      
      // кнопка "Готово"
      fakeNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
      
    } else {
      // просмотр задания и возможность его удалить
      
      // кнопка "Назад"
      fakeNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.leftButton.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
      
      // показываем спрятанную кнопку "Удалить"
      fakeNavigationBar.showButton(.CenterRight, withAnimationDuration: animationDuration)
      
      // кнопка "Редактировать"
      fakeNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.rightButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
    }
    
    configureUserInteractionForEditState()
    configureCellsSelectionStyle()
    
  }
  
  func configureCellsSelectionStyle() {
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cell = tbCnfg.cellTagTypeState[s][r]
        
        if cell.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) {
            configureCellSelectionStyle(cell)
          }
        }
      }
    }
  }
  
  
  // была нажата кнопка "Назад"
  func back(sender: UIButton) {
    
    if let taskWithInitialSettings = taskWithInitialSettings {
      managedContext.deleteObject(taskWithInitialSettings)
    }
    
    if edited {
      if tbCnfg.timeFrameWasChanged {
        task.countEndDate()
        delegate?.editShowTaskVC(self, didFullyEditTask: task)
      } else {
        delegate?.editShowTaskVC(self, didSlightlyEditTask: task)
      }
    }
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  // была нажата кнопка "Удалить"
  func trash(sender: UIButton) {
    let deleteController = UIAlertController(title: "Удалить задание?", message: nil, preferredStyle: .ActionSheet)
    
    let confirmAction = UIAlertAction(title: "Да, давайте удалим", style: .Destructive) {
      (action) -> Void in
      self.delegate?.editShowTaskVC(self, didDeleteTask: self.task)
    }
    
    let cancelAction = UIAlertAction(title: "Нет, я передумал", style: .Cancel) {
      (action) -> Void in
    }
    
    deleteController.addAction(confirmAction)
    deleteController.addAction(cancelAction)
    
    presentViewController(deleteController, animated: true, completion: nil)
  }
  
  // была нажата кнопка "Редактировать"
  func edit(sender: UIButton) {
    editState = true
    saveInitialSettings()
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // была нажата кнопка "Отменить"
  func cancel(sender: UIButton) {
    editState = false
    
    deactivateAllActiveTextFields()
    
    if taskDidChange() {
      loadInitailSettings()
      reloadEditShowTaskTable()
    } else {
      closePickerCellsForShowState()
    }
    
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // настройки задания изменились
  func taskDidChange() -> Bool {
    if let taskWithInitialSettings = taskWithInitialSettings {
      return !task.settingsAreEqual(toTask: taskWithInitialSettings)
    } else {
      return false
    }
  }
  
  // загружаем сохраненные настройки, если произошли изменения
  func loadInitailSettings() {
    if let taskWithInitialSettings = taskWithInitialSettings {
      task.copySettings(fromTask: taskWithInitialSettings)
    }
  }
  
  // была нажата кнопка "Готово"
  func done(sender: UIButton) {
    editState = false
    closePickerCellsForShowState()
    deactivateAllActiveTextFields()
    
    if taskDidChange() {
      if !edited {
        edited = true
      }
    }
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // закрываем все picker после завершения редактирования
  func closePickerCellsForShowState() {
    let rowsToReload = closeAllOpenPickerCells()
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
  
  // активируем или деактивируем нажатие элементов на ячейках
  func configureUserInteractionForEditState() {
    
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cellTTS = tbCnfg.cellTagTypeState[s][r]
        if cellTTS.type == .TitleSegmentCell && cellTTS.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) as? StgTitleSegmentCell {
            cell.hideShowSgCtrl.userInteractionEnabled = editState
          }
        }
      }
    }
  }
  
  func reloadEditShowTaskTable() {
    tbCnfg.configure(withTask: task)
    tableView.reloadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
    
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if keyboardHeight == nil {
      if let userInfo = notification.userInfo {
        if let keyboardSizeNSValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
          keyboardHeight = keyboardSizeNSValue.CGRectValue().height
        }
      }
    }
    
    let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
    tableView.contentInset = contentInsets
    tableView.scrollIndicatorInsets = contentInsets
  }
  
  func keyboardWillHide(notification: NSNotification) {
    tableView.contentInset = UIEdgeInsetsZero
    tableView.scrollIndicatorInsets = UIEdgeInsetsZero
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
  }
}

extension EditShowTaskViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tbCnfg.sectionTitles.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tbCnfg.cellTagTypeState[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cellType = tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].type
    var generalCell = UITableViewCell()
    
    switch cellType {
    case .TextFieldCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgTextFieldCellId) as? StgTextFieldCell {
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
      break
    }
    
    configureCellSelectionStyle(generalCell)
    
    return generalCell
  }
  
  func configureCellSelectionStyle(cell: UITableViewCell) {
    if editState {
      if let cell = cell as? StgComplexPickerCell {
        cell.selectionStyle = .None
      } else {
        cell.selectionStyle = .Gray
      }
    } else {
      cell.selectionStyle = .None
    }
  }
  
  func configureTextFieldCell(cell: StgTextFieldCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    let tag = tbCnfg.cellTagTypeState[section][row].tag
    cell.textField.tag = tag
    cell.textField.delegate = self
    
    cell.textField.autocapitalizationType = .Words
    //cell.textField.enablesReturnKeyAutomatically = true
    cell.textField.keyboardAppearance = .Dark
    cell.textField.keyboardType = .Default
    cell.textField.returnKeyType = .Done
    cell.textField.placeholder = tbCnfg.textFieldPlaceholders[tag]
    
    if let title = tbCnfg.titleValueValues[cell.textField.tag] {
      cell.textField.text = title
    }
    
    cell.textField.userInteractionEnabled = false
    cell.textField.resignFirstResponder()
    cell.textField.textColor = UIColor.lightGrayColor()
  }
  
  func configureTitleValueCell(cell: StgTitleValueCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    cell.tag = tbCnfg.cellTagTypeState[section][row].tag
    
    if let title = tbCnfg.titleValueTitles[cell.tag] {
      cell.titleLabel.text = title
    }
    
    let state = tbCnfg.cellTagTypeState[section][row].state
    if state == .Accessory {
      cell.accessoryType = .DisclosureIndicator
      cell.valueLabel.text = ""
    } else {
      cell.accessoryType = .None
      if let value = tbCnfg.titleValueValues[cell.tag] {
        cell.valueLabel.text = value
      }
    }
    
    // конфигурируем цвет на основании скрытости или открытости нижележащего pickerView
    if tbCnfg.cellTagTypeState[section][row + 1].state == CellState.Hidden {
      cell.valueLabel.textColor = UIColor.lightGrayColor()
    } else {
      cell.valueLabel.textColor = UIColor.lightOrangeColor()
    }
    
  }
  
  func configureTitleSegmentCell(cell: StgTitleSegmentCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    let tag = tbCnfg.cellTagTypeState[section][row].tag
    
    cell.hideShowSgCtrl.tag = tag
    cell.delegate = self
    
    cell.hideShowSgCtrl.userInteractionEnabled = editState
    
    if let title = tbCnfg.titleValueTitles[tag] {
      cell.titleLabel.text = title
    }
    
    var frequencySegmentTitles = tbCnfg.frequencySegmentTitles()
    
    let segmentTitle = tbCnfg.frequencySegmentTitle()
    if segmentTitle == "" {
      cell.configure(withValues: frequencySegmentTitles, andSelectedSegment: 0)
    } else {
      frequencySegmentTitles[1] = segmentTitle
      cell.configure(withValues: frequencySegmentTitles, andSelectedSegment: 1)
    }
    
  }
  
  func configureDataPickerCell(cell: StgDataPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    // если ячейка спрятана, то нет смысла подгружать в нее данные
    if tbCnfg.cellTagTypeState[section][row].state != .Hidden {
      
      let tag = tbCnfg.cellTagTypeState[section][row].tag
      cell.dataPickerView.tag = tag
      
      if let titles = tbCnfg.pickerOptions[tag] {
        cell.dataPickerView.font = VisualConfiguration.pickerFont
        cell.dataPickerView.textColor = VisualConfiguration.pickerTextColor
        
        let initialValues = tbCnfg.initialDPickerStrings(withTag: tag)
        cell.dataPickerView.configure(withTitles: titles, andInitialValues: initialValues, andDelegate: self)
      }
    }
  }
  
  func configureDatePickerCell(cell: StgDatePickerCell, ofType cellType: SettingCellType, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    // если ячейка спрятана, то нет смысла подгружать в нее данные
    if tbCnfg.cellTagTypeState[section][row].state != .Hidden {
      let tag = tbCnfg.cellTagTypeState[section][row].tag
      cell.datePicker.tag = tag
      
      switch cellType {
      case .TimePickerCell:
        let minutes = tbCnfg.initialDTPickerTime(withTag: tag)
        cell.datePicker.configure(withDelegate: self, selectedMinutes: minutes)
        
      case .DateTimePickerCell:
        let dates = tbCnfg.initialDTPickerDate(withTag: tag)
        cell.datePicker.configure(withDelegate: self, selectedDate: dates.initialDate, andMinimumDate: dates.minimumDate)
        
      default:
        break
      }
    }
  }
  
  func configureComplexPickerCell(cell: StgComplexPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    // если ячейка спрятана, то нет смысла подгружать в нее данные
    if tbCnfg.cellTagTypeState[section][row].state != .Hidden {
      
      let tag = tbCnfg.cellTagTypeState[section][row].tag
      cell.configure(withTag: tag, andDelegate: self)
      
      let endSegmentTitles = tbCnfg.endSegmentTitles()
      cell.configure(withSegmentValues: endSegmentTitles, andSelectedSegment: task.endType.rawValue)
      
      
      let pickerTag = tag + task.endType.rawValue
      
      if task.endType == .EndDate {
        let dates = tbCnfg.initialDTPickerDate(withTag:pickerTag)
        cell.configure(withMinimumDateAndTime: dates.minimumDate, andInitialDateAndTime: dates.initialDate, andDelegate: self)
      } else {
        let endOptions = tbCnfg.endOptions()
        let initialStrings = tbCnfg.initialDPickerStrings(withTag: pickerTag)
        cell.configure(withTitles: [endOptions], andWithInitialValues: initialStrings, andDelegate: self)
      }

    }
  }
}

extension EditShowTaskViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    // если секции не нужен заголовок
    if tbCnfg.sectionTitles[section] == "" {
      return nil
    } else {
      // остальным секциям нужно свое view с заголовком
      if let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellId) as? HeaderCell {
        headerCell.titleLabel.text = tbCnfg.sectionTitles[section].lowercaseString
        let view = UIView(frame: headerCell.frame)
        view.addSubview(headerCell)
        return view
      } else {
        return nil
      }
    }
  }
  
  // высота заголовка
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    // если секции не нужен заголовок
    if tbCnfg.sectionTitles[section] == "" {
      return CGFloat.min
    } else {
      return headerHeight
    }
  }
  
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
    
    if editState {
      let cellType = tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].type
      if cellType == .TextFieldCell || cellType == .TitleValueCell || cellType == .TitleSegmentCell {
        return indexPath
      } else {
        return nil
      }
      
    } else {
      let cellState = tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].state
      if cellState == .Accessory {
        return indexPath
      } else {
        return nil
      }
    }
  }
  
  
  
  // закрываем все открытые picker cell
  func closeAllOpenPickerCells() -> [NSIndexPath] {
    
    var rowsToReload: [NSIndexPath] = []
    
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cell = tbCnfg.cellTagTypeState[s][r]
        
        if (cell.type == .DataPickerCell || cell.type == .TimePickerCell || cell.type == .DateTimePickerCell || cell.type == .ComplexPickerCell) && cell.state != .Hidden {
          tbCnfg.cellTagTypeState[s][r].state = .Hidden
          
          rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r - 1, inSection: s)) as? StgTitleValueCell {
            // сменить цвет на серый обратно
            cell.valueLabel.textColor = UIColor.lightGrayColor()
          }
        }
      }
    }
    return rowsToReload
  }
  
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
  
  // выбрана ячейка
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = tbCnfg.cellTagTypeState[section][row].type
    let cellState = tbCnfg.cellTagTypeState[section][row].state
    
    if cellState == .Accessory {
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTitleValueCell {
        performSegueWithIdentifier(editShowMinutesDoseSegueId, sender: cell)
      }
    }
    
    deactivateAllActiveTextFields()
    var rowsToReload: [NSIndexPath] = []
    var indexPathToScroll = indexPath
    
    switch cellType {
      
    // ячейка с вводом текста
    case .TextFieldCell:
      if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTextFieldCell {
        activateVisibleTextField(cell.textField)
        rowsToReload = closeAllOpenPickerCells()
        indexPathToScroll = indexPath
      }
      
    // ячейки, по которыми находятся picker cell
    case .TitleSegmentCell, .TitleValueCell:
      
      // номер ряда находящегося под ячейкой picker cell
      let pickerCellRow = row + 1
      let pickerCellState = tbCnfg.cellTagTypeState[section][pickerCellRow].state
      let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
      
      if cellType == .TitleSegmentCell {
        
        // выбрана ячейка TitleSegmentCell
        if tbCnfg.frequencySegmentFirstOption() {
          rowsToReload = closeAllOpenPickerCells()
        } else {
          if pickerCellState == .Hidden {
            rowsToReload = closeAllOpenPickerCells()
          }
          tbCnfg.toggleCellTagTypeState(atIndexPath: pickerCellIndPth)
          rowsToReload.append(pickerCellIndPth)
        }
        
      } else if cellType == .TitleValueCell {
        // выбрана ячейка TitleValueCell
        
        if pickerCellState == .Hidden {
          rowsToReload = closeAllOpenPickerCells()
        }
        
        if cellState != .Accessory {
          // ячейка не имеет типа Accessory, значит, нужно показать находящийся под ней PickerCell
          
          // проверяем, какой цвет изменяемого значения нужен выбранной TitleValueCell
          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTitleValueCell {
            if pickerCellState == .Hidden {
              cell.valueLabel.textColor = UIColor.lightOrangeColor()
            } else {
              cell.valueLabel.textColor = UIColor.lightGrayColor()
            }
          }
          
          // переводи pickerView в новое состояние скрытости
          tbCnfg.toggleCellTagTypeState(atIndexPath: pickerCellIndPth)
          rowsToReload.append(pickerCellIndPth)
          indexPathToScroll = pickerCellIndPth
        }
      }
      
    default:
      break
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    // проматываем на только что активную ячейку
    tableView.scrollToRowAtIndexPath(indexPathToScroll, atScrollPosition: .Middle, animated: true)
  }
  
}

extension EditShowTaskViewController: UITextFieldDelegate {
  
  // активировать ввод текста
  func activateVisibleTextField(textField: UITextField) {
    
    if let indexPath = tbCnfg.indexPathForTag(textField.tag) {
      tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].state = .Active
    }
    
    textField.textColor = UIColor.blackColor()
    textField.userInteractionEnabled = true
    textField.becomeFirstResponder()
  }
  
  // ввод текста завершился
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    if let indexPath = tbCnfg.indexPathForTag(textField.tag) {
      tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].state = .Visible
    }
    
    textField.textColor = UIColor.lightGrayColor()
    textField.resignFirstResponder()
    textField.userInteractionEnabled = false
    
    return true
  }
  
  // были введены символы
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
    if let oldText = textField.text {
      let newText = (oldText as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
      
      tbCnfg.updateTask(byTextFieldWithTag: textField.tag, byString: newText as String)
      tbCnfg.updateTitleValueValues(ofTag: textField.tag, byTask: task)
    }
    
    return true
  }
  
  // деактивировать все активные text field
  func deactivateAllActiveTextFields() {
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cellTTS = tbCnfg.cellTagTypeState[s][r]
        
        if cellTTS.type == .TextFieldCell && cellTTS.state == .Active {
          tbCnfg.cellTagTypeState[s][r].state = .Visible
          
          let indexPath = NSIndexPath(forRow: r, inSection: s)
          if let cell = tableView.cellForRowAtIndexPath(indexPath) as? StgTextFieldCell {
            textFieldShouldReturn(cell.textField)
          } else {
            UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
          }
        }
      }
    }
  }
  
}

extension EditShowTaskViewController: DataPickerViewDelegate {
  
  func dataPicker(picker: DataPickerView, didPickValues values: [String]) {
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byStrings: values)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dataStillNeeded(fromPicker picker: DataPickerView) -> Bool {
    if let cellIndexPath = tbCnfg.indexPathForTag(picker.tag) {
      
      if tbCnfg.cellTagTypeState[cellIndexPath.section][cellIndexPath.row].type == .ComplexPickerCell {
        if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? StgComplexPickerCell {
          return !cell.hidden(forTag: picker.tag)
        }
      } else if tbCnfg.cellTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }

    return false
  }
  
  func updateCells(withTags tags: [Int]) {
    var indexPaths: [NSIndexPath] = []
    for tag in tags {
      tbCnfg.updateTitleValueValues(ofTag: tag, byTask: task)
      if let indexPath = tbCnfg.indexPathForTag(tag) {
        indexPaths.append(indexPath)
      }
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    tableView.endUpdates()
  }
  
}

extension EditShowTaskViewController: DatePickerDelegate {
  func datePicker(picker: UIDatePicker, didPickDate date: NSDate) {
    let tagsToUpdate = tbCnfg.updateTask(task, ByPickerViewWithTag: picker.tag, byDateTimeValue: date)
    updateCells(withTags: tagsToUpdate)
  }
  
  func datePicker(picker: UIDatePicker, didPickMinutes minutes: Int) {
    let tagsToUpdate = tbCnfg.updateTask(byPickerViewWithTag: picker.tag, byMinutes: minutes)
    updateCells(withTags: tagsToUpdate)
  }
  
  func dateStillNeeded(fromPicker picker: UIDatePicker) -> Bool {
    if let cellIndexPath = tbCnfg.indexPathForTag(picker.tag) {
      
      if tbCnfg.cellTagTypeState[cellIndexPath.section][cellIndexPath.row].type == .ComplexPickerCell {
        if let cell = tableView.cellForRowAtIndexPath(cellIndexPath) as? StgComplexPickerCell {
          return !cell.hidden(forTag: picker.tag)
        }
      } else if tbCnfg.cellTagTypeState[cellIndexPath.section][cellIndexPath.row].state != .Hidden {
        return true
      }
    }
    
    return false
  }
  
}

extension EditShowTaskViewController: DoubleOptionSegmControlDelegate {
  func segmControl(sgCtrl: UISegmentedControl, didSelectSegment segment: Int) {
    // обновить значение настроек
    let tagsToUpdate = tbCnfg.updateTask(bySegmentedControlWithTag: sgCtrl.tag, andSegment: segment)
    
    updateCells(withTags: tagsToUpdate)
    if let indexPath = tbCnfg.indexPathForTag(sgCtrl.tag) {
      tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
  }
}

extension EditShowTaskViewController: StgComplexPickerCellDelegate {
  
  func getPickerTitlesAndInitialValues(bySelectedSegment index: Int, andByTag tag: Int) -> (titles: [[String]], initialValues: [String], delegate: DataPickerViewDelegate) {
    
    let et = Task.EndType(rawValue: index)
    let endOptions = tbCnfg.endOptions(byNewEndType: et)
    let initialStrings = tbCnfg.initialDPickerStrings(withTag: tag, andNewEndType: et)
   
    return ([endOptions], initialStrings, self)

  }
  
  func getPickerInitialDate(bySelectedSegment index: Int, andByTag tag: Int) -> (iDate: NSDate, mDate: NSDate, delegate: DatePickerDelegate) {
    let dates = tbCnfg.initialDTPickerDate(withTag: tag)
    return (dates.initialDate, dates.minimumDate, self)
  }
}

// обращения с CoreData
extension EditShowTaskViewController: ManagedObjectContextSettable {
  // устанавливаем ManagedObjectContext
  func setManagedObjectContext(managedContext: NSManagedObjectContext) {
    self.managedContext = managedContext
  }
  
  // сохраняем изначальные настройки
  func saveInitialSettings() {
    if let taskWithInitialSettings = taskWithInitialSettings {
      taskWithInitialSettings.copySettings(fromTask: task, withPet: true)
    } else {
      taskWithInitialSettings = Task(insertIntoManagedObjectContext: managedContext)
      if let taskWithInitialSettings = taskWithInitialSettings {
        taskWithInitialSettings.copySettings(fromTask: task, withPet: true)
      }
    }
  }
  
}
extension EditShowTaskViewController: EditShowMinutesDoseTaskVCDelegate {
  func editShowMinutesDoseTaskVC(viewController: EditShowMinutesDoseTaskViewController, didEditMinutesDoseOfTask task: Task, withTblType tblType: ESMinutesDoseTaskTblCnfgType) {
    
    if tblType == .Minutes {
      tbCnfg.updatePreviousMinutes()
      tbCnfg.timeFrameWasChanged = true
    } else if tblType == .Dose {
      tbCnfg.updatePreviousDose()
    }
    
    if editState {
      saveInitialSettings()
    }
    
    if !edited {
      edited = true
    }
    
  }
}

