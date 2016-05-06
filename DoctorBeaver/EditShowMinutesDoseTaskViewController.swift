//
//  EditShowMinutesDoseTaskViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

protocol EditShowMinutesDoseTaskVCDelegate: class {
  func editShowMinutesDoseTaskVC(viewController: EditShowMinutesDoseTaskViewController, didEditMinutesDoseOfTask task: Task, withTblType tblType: ESMinutesDoseTaskTblCnfgType)
}

class EditShowMinutesDoseTaskViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  @IBOutlet weak var tableView: UITableView!
  
  weak var delegate: EditShowMinutesDoseTaskVCDelegate?
  
  var managedContext: NSManagedObjectContext!
  
  // задание
  var task: Task!
  var minutesDoseInitialSettings: (minutes: [Int], dose: [String]) = ([], [])
  
  var tbCnfg = EditShowMinutesDoseTaskTableConfiguration()
  var minutesDoseTblType: ESMinutesDoseTaskTblCnfgType!
  
  let stgTitleValueCellId = "stgTitleValueCell"
  let stgTitleSwitchCellId = "stgTitleSwitchCell"
  let stgDataPickerCellId = "stgDataPickerCell"
  let stgDatePickerCellId = "stgDatePickerCell"
  
  let regularCellHeight: CGFloat = 44.0
  let pickerCellHeight: CGFloat = 216.0
  
  let animationDuration = VisualConfiguration.animationDuration
  
  // добавляем или редактируем задание
  var editState = false
  // было ли отредактировано
  var edited = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    reloadEditShowMinutesDoseTable()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    
    if minutesDoseTblType == ESMinutesDoseTaskTblCnfgType.Minutes {
      fakeNavigationBar.titleLabel.text = tbCnfg.minutesForTimesTitle().uppercaseString
    } else if minutesDoseTblType == ESMinutesDoseTaskTblCnfgType.Dose {
      fakeNavigationBar.titleLabel.text = tbCnfg.doseForTimesTitle().uppercaseString
    }
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    if editState {
      saveInitialSettings()
    }
    
    configureForEditState()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

/////
  
  // была нажата кнопка "Назад"
  func back(sender: UIButton) {
    if edited {
      delegate?.editShowMinutesDoseTaskVC(self, didEditMinutesDoseOfTask: task, withTblType: minutesDoseTblType)
    }
    navigationController?.popViewControllerAnimated(true)
  }
  
  // была нажата кнопка "Редактировать"
  func edit(sender: UIButton) {
    editState = true
    saveInitialSettings()
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // сохраняем изначальные настройки
  func saveInitialSettings() {
    if minutesDoseTblType == .Minutes {
      minutesDoseInitialSettings.minutes = task.minutesForTimes
    } else if minutesDoseTblType == .Dose {
      minutesDoseInitialSettings.dose = task.doseForTimes
    }
  }
  
  // была нажата кнопка "Отменить"
  func cancel(sender: UIButton) {
    editState = false
    if minutesDoseDidChange() {
      loadInitailSettings()
    }
    
    reloadEditShowMinutesDoseTable()
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
  // расписание и дозировка задания изменились
  func minutesDoseDidChange() -> Bool {
    if minutesDoseTblType == .Minutes && task.minutesForTimes == minutesDoseInitialSettings.minutes {
      return false
    } else if minutesDoseTblType == .Dose && task.doseForTimes == minutesDoseInitialSettings.dose {
      return false
    }
    return true
  }
  
  // загружаем сохраненные настройки, если произошли изменения
  func loadInitailSettings() {
    if minutesDoseTblType == .Minutes {
      task.minutesForTimes = minutesDoseInitialSettings.minutes
    } else if minutesDoseTblType == .Dose {
      task.doseForTimes = minutesDoseInitialSettings.dose
    }
  }
  
  // была нажата кнопка "Готово"
  func done(sender: UIButton) {
    editState = false
    closePickerCellsForShowState()
    
    // проверяем, была ли выбрана единая дозировка
    if minutesDoseTblType == .Dose && tbCnfg.equalDoseSwitchOn {
      task.setAllDosesEqual()
      tbCnfg.configureTitleValueValues()
    }
    
    if minutesDoseDidChange() {
      if !edited {
        edited = true
      }
    }
    configureForEditState(withAnimationDuration: animationDuration)
  }
  
////
  
  func configureForEditState(withAnimationDuration animationDuration: NSTimeInterval = 0) {
    
    if editState {
      // редактирование задания
      
      // кнопка - отменить
      fakeNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
      
      // кнопка - готово
      fakeNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
      
    } else {
      // просмотр и редактирование
      
      // кнопка - назад
      fakeNavigationBar.setButtonImage("back", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.leftButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.leftButton.addTarget(self, action: "back:", forControlEvents: .TouchUpInside)
      
      // кнопка "Редактировать"
      fakeNavigationBar.setButtonImage("edit", forButton: .Right, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
      fakeNavigationBar.rightButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
      fakeNavigationBar.rightButton.addTarget(self, action: "edit:", forControlEvents: .TouchUpInside)
    }
    
    configureUserInteractionForEditState()
    configureCellsSelectionStyle()
    
  }
  
  func configureSwitchTintColor(swt: UISwitch) {
    if editState {
      swt.tintColor = UIColor.lightGrayColor()
      swt.onTintColor = UIColor.lightGrayColor()
    } else {
      swt.tintColor = UIColor.mercuryColor()
      swt.onTintColor = UIColor.mercuryColor()
    }
  }
  
  // активируем или деактивируем нажатие элементов на ячейках
  func configureUserInteractionForEditState() {
    
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cellTTS = tbCnfg.cellTagTypeState[s][r]
        if cellTTS.type == .TitleSwitchCell && cellTTS.state != .Hidden {
          
          if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s)) as? StgTitleSwitchCell {
            cell.equalSwitch.userInteractionEnabled = editState
            configureSwitchTintColor(cell.equalSwitch)
          }
        }
      }
    }
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

  func reloadEditShowMinutesDoseTable() {
    tbCnfg.configure(withTask: task, andtTblType: minutesDoseTblType)
    tableView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
  }

  
}



extension EditShowMinutesDoseTaskViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return tbCnfg.cellTagTypeState.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tbCnfg.cellTagTypeState[section].count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cellType = tbCnfg.cellTagTypeState[indexPath.section][indexPath.row].type
    var generalCell = UITableViewCell()
    
    switch cellType {
      
    case .TitleValueCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgTitleValueCellId) as? StgTitleValueCell {
        configureTitleValueCell(cell, forRowAtIndexPath: indexPath)
        
        generalCell = cell
      }
      
    case .TitleSwitchCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgTitleSwitchCellId) as? StgTitleSwitchCell {
        configureTitleSwitchCell(cell, forRowAtIndexPath: indexPath)
        
        generalCell = cell
      }
      
    case .DataPickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgDataPickerCellId) as? StgDataPickerCell {
        configureDataPickerCell(cell, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
      
    case .TimePickerCell:
      if let cell = tableView.dequeueReusableCellWithIdentifier(stgDatePickerCellId) as? StgDatePickerCell {
        configureDatePickerCell(cell, ofType: cellType, forRowAtIndexPath: indexPath)
        generalCell = cell
      }
    default:
      break
    }
    
    configureCellSelectionStyle(generalCell)
    
    return generalCell
  }
  
  func configureCellSelectionStyle(cell: UITableViewCell) {
    if !(cell is StgTitleSwitchCell) {
      if editState {
        cell.selectionStyle = .Gray
      } else {
        cell.selectionStyle = .None
      }
    }
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
  
  func configureTitleSwitchCell(cell: StgTitleSwitchCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    cell.tag = tbCnfg.cellTagTypeState[section][row].tag
    cell.delegate = self
    
    cell.selectionStyle = .None
    cell.equalSwitch.userInteractionEnabled = editState
    
    configureSwitchTintColor(cell.equalSwitch)
    
    //    if let title = tbCnfg.titleValueTitles[cell.tag] {
    //      cell.titleLabel.text = title
    //    }
///
    cell.titleLabel.text = "Одинаковая дозировка"
///
//    let allDosesAreEqual = tbCnfg.allDosesAreEqual()
    cell.equalSwitch.setOn(tbCnfg.equalDoseSwitchOn, animated: false)
    
  }
  
  func configureDataPickerCell(cell: StgDataPickerCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    // если ячейка спрятана, то нет смысла подгружать в нее данные
    if tbCnfg.cellTagTypeState[section][row].state != .Hidden {
      
      let tag = tbCnfg.cellTagTypeState[section][row].tag
      cell.dataPickerView.tag = tag
      
      if let titles = tbCnfg.pickerOptionsForDose(forTag: tag) {
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
      
      if cellType == .TimePickerCell {
        let minutes = tbCnfg.initialDTPickerTime(withTag: tag)
        cell.datePicker.configure(withDelegate: self, selectedMinutes: minutes.selectedMinutes, minimumMinutes: minutes.minimumMinutes, maximumMinutes: minutes.maximumMinutes)
      }
    }
  }
  
  
}

extension EditShowMinutesDoseTaskViewController: UITableViewDelegate {
  
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
  
  // закрываем все picker после завершения редактирования
  func closePickerCellsForShowState() {
    let rowsToReload = closeAllOpenPickerCells()
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
  
  
  
  
  
  // изменяем видимость ячеек на основании switch
  func toggleCellsState(forSwitchState newSwitchState: Bool) -> [NSIndexPath] {
    tbCnfg.equalDoseSwitchOn = newSwitchState
    
    var oldCellState: CellState
    var newCellState: CellState
    
    if newSwitchState == true {
      oldCellState = .Visible
      newCellState = .Hidden
    } else {
      oldCellState = .Hidden
      newCellState = .Visible
    }
    
    var firstTVCellPath = NSIndexPath(forRow: -1, inSection: -1)
    
    var rowsToReload: [NSIndexPath] = []
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cell = tbCnfg.cellTagTypeState[s][r]
        if cell.type == .TitleValueCell || cell.type == .DataPickerCell {
          if cell.type == .TitleValueCell && firstTVCellPath == NSIndexPath(forRow: -1, inSection: -1)
           {
            // первая встретившаяся TitleValueCell
            firstTVCellPath = NSIndexPath(forRow: r, inSection: s)
          } else if !((cell.type == .DataPickerCell && s == firstTVCellPath.section && r == firstTVCellPath.row + 1) || (cell.type == .DataPickerCell && !newSwitchState)) {
            if cell.state == oldCellState {
              tbCnfg.cellTagTypeState[s][r].state = newCellState
              rowsToReload.append(NSIndexPath(forRow: r, inSection: s))
            }
          }
        }
      }
    }
    return rowsToReload
  }
  
  // закрываем все открытые picker
  func closeAllOpenPickerCells() -> [NSIndexPath] {
    
    var rowsToReload: [NSIndexPath] = []
    
    for s in 0..<tbCnfg.cellTagTypeState.count {
      for r in 0..<tbCnfg.cellTagTypeState[s].count {
        
        let cell = tbCnfg.cellTagTypeState[s][r]
        
        if (cell.type == .DataPickerCell || cell.type == .TimePickerCell) && cell.state != .Hidden {
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
  
  // выбрана ячейка
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    let section = indexPath.section
    let row = indexPath.row
    let cellType = tbCnfg.cellTagTypeState[section][row].type
    let cellState = tbCnfg.cellTagTypeState[section][row].state
    
    // номер ряда находящегося под ячейкой Picker Cell
    let pickerCellRow = row + 1
    let pickerCellState = tbCnfg.cellTagTypeState[section][pickerCellRow].state
    let pickerCellIndPth = NSIndexPath(forRow: pickerCellRow, inSection: section)
    
    var rowsToReload: [NSIndexPath] = []
    
    if cellType == .TitleValueCell {
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
      }
    }
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
    
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
    // проматываем на только что нажатую ячейку
    tableView.scrollToRowAtIndexPath(pickerCellIndPth, atScrollPosition: .Middle, animated: true)
  }
  
}

extension EditShowMinutesDoseTaskViewController: DataPickerViewDelegate {
  
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



extension EditShowMinutesDoseTaskViewController: EqualSwitchDelegate {
  func equalSwitch(eqSwt: UISwitch, didSetOn setOn: Bool) {

    let rowsToReload = toggleCellsState(forSwitchState: setOn)
    
    tableView.beginUpdates()
    tableView.reloadRowsAtIndexPaths(rowsToReload, withRowAnimation: .Automatic)
    tableView.endUpdates()
  }
}

// обращения с CoreData
extension EditShowMinutesDoseTaskViewController: ManagedObjectContextSettable {
  func setManagedObjectContext(managedContext: NSManagedObjectContext) {
    self.managedContext = managedContext
  }
}

extension EditShowMinutesDoseTaskViewController: DatePickerDelegate {
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

  

