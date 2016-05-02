//
//  EditShowMinutesDoseTaskTableConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

class EditShowMinutesDoseTaskTableConfiguration {
  
  var tskCnfg: TaskConfigurationByType!
  var task: Task!
  var tblType: ESMinutesDoseTaskTblCnfgType!
  
  
  let minutesStartTag = 1200
  
  let equalDoseTag = 1400
  let doseStartTag = 1402
  
  
  // структура ячеек, составляющее меню для настройки
  var cellTagTypeState: [[(tag: Int, type: SettingCellType, state: CellState)]]
  
  // заголовки названий и значений пунктов меню
  var titleValueTitles: [Int: String]
  var titleValueValues: [Int: String]
  // значения picker view
  var pickerOptions: [Int: [[String]]]
  
  // положение equal switch
  var equalDoseSwitchOn = false
  
  init() {
    cellTagTypeState = []
    titleValueTitles = [:]
    titleValueValues = [:]
    pickerOptions = [:]
  }
  
  // комплексная настройка для целого задания
  func configure(withTask task: Task, andtTblType tblType: ESMinutesDoseTaskTblCnfgType) {
    
    tskCnfg = TaskConfigurationByType(task: task)
    self.task = task
    self.tblType = tblType
    
    equalDoseSwitchOn = task.allDosesAreEqual()
    
    configureCellTagTypeState(forType: task.type)
    configureTitleValueTitles()
    configureTitleValueValues()
    
    // наполняем picker view значениями настраиваемых элементов
    if tblType == ESMinutesDoseTaskTblCnfgType.Dose {
      pickerOptions = [
        doseStartTag: tskCnfg.doseForTimesOptions(),
      ]
    }
  }
  
//  func indexPathForEqualSwitchCell() -> NSIndexPath? {
//    for s in 0..<cellTagTypeState.count {
//      for r in 0..<cellTagTypeState[s].count {
//        if cellTagTypeState[s][r].type == SettingCellType.TitleSwitchCell {
//          return NSIndexPath(forRow: r, inSection: s)
//        }
//      }
//    }
//    return nil
//  }
  
  
  func tagIsInMinutesTags(tag: Int) -> Bool {
    if tag - tag % 100 == minutesStartTag {
      return true
    } else {
      return false
    }
  }
  
  func tagIsInDoseTags(tag: Int) -> Bool {
    if tag - tag % 100 + doseStartTag % 100 == doseStartTag {
      return true
    } else {
      return false
    }
  }
  
  func pickerOptionsForDose(forTag tag: Int) -> [[String]]? {
    
    if tagIsInDoseTags(tag) {
      if let options = pickerOptions[doseStartTag] {
        return options
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  func configureTitleValueValues() {
    var tag = 0
    
    if tblType == ESMinutesDoseTaskTblCnfgType.Minutes {
      tag = minutesStartTag
    } else if tblType == ESMinutesDoseTaskTblCnfgType.Dose {
      tag = doseStartTag
    }

    for _ in 0..<task.timesPerDay {
      titleValueValues[tag] = ""
      tag += 2
    }
    
    // заполняем значения настроек по заданию
    for key in titleValueValues.keys {
      updateTitleValueValues(ofTag: key)
    }
    
  }
  
  func minutesForTimesTitle() -> String {
    return tskCnfg.minutesForTimesTitle()
  }
  
  func doseForTimesTitle() -> String {
    return tskCnfg.doseForTimesTitle()
  }
  
  // заголовки настроек
  func configureTitleValueTitles() {
    var titles: [String] = []
    var tag = 0
    
    if tblType == ESMinutesDoseTaskTblCnfgType.Minutes {
      titles = tskCnfg.minutesForTimesTitles()
      tag = minutesStartTag
      
    } else if tblType == ESMinutesDoseTaskTblCnfgType.Dose {
      titles = tskCnfg.doseForTimesTitles()
      tag = doseStartTag
    }
    
    for ind in 0..<task.timesPerDay {
      titleValueTitles[tag] = titles[ind]
      tag += 2
    }
  }
  
  // строим структуру меню на основании типа задания
  func configureCellTagTypeState(forType type: TaskType) {
    cellTagTypeState = []
    cellTagTypeState.append([])
    var tag = 0
    var titleCellState: CellState = .Visible
    var valueCellType: SettingCellType = .TitleValueCell
    var timeStartInd = 0
    
    if tblType == ESMinutesDoseTaskTblCnfgType.Minutes {
      tag = minutesStartTag
      valueCellType = .TimePickerCell
      
    } else if tblType == ESMinutesDoseTaskTblCnfgType.Dose {
      cellTagTypeState[0].append((equalDoseTag, .TitleSwitchCell, .Visible))
      tag = doseStartTag
      valueCellType = .DataPickerCell
      
      if equalDoseSwitchOn {
        cellTagTypeState[0].append((tag, .TitleValueCell, .Visible))
        tag += 1
        cellTagTypeState[0].append((tag, valueCellType, .Hidden))
        tag += 1
        timeStartInd = 1
        titleCellState = .Hidden
      }
    }
    
    for _ in timeStartInd..<task.timesPerDay {
      cellTagTypeState[0].append((tag, .TitleValueCell, titleCellState))
      tag += 1
      cellTagTypeState[0].append((tag, valueCellType, .Hidden))
      tag += 1
    }
  }
  
  // секция и ряд для tag
  func indexPathForTag(tag: Int) -> NSIndexPath? {
    for s in 0..<cellTagTypeState.count {
      for r in 0..<cellTagTypeState[s].count {
        if cellTagTypeState[s][r].tag == tag {
          return NSIndexPath(forRow: r, inSection: s)
        }
      }
    }
    return nil
  }
  
  // по tag обновляем значения полей по данным задания
  func updateTitleValueValues(ofTag tag: Int) {
    var strValue: String = ""
    
    if tblType == .Minutes {
      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
      let minutes = task.minutesForTimes[indInMinutesForTimes]
      strValue = DateHelper.minutesToString(minutes)
    } else if tblType == .Dose {
      let indInDoseForTimes = ( tag - doseStartTag ) / 2
      strValue = tskCnfg.doseString(atInd: indInDoseForTimes) + " " + task.type.doseUnit()
    }
    
    titleValueValues[tag] = strValue
  }
  
  // начальные значения для picker view
  // получаем начальное строковое значение для picker view с tag
  func initialDPickerStrings(withTag tag: Int, andNewEndType endType: Task.EndType? = nil) -> [String] {
    
    if tagIsInDoseTags(tag) {
      let indInDoseForTimes = ( tag - doseStartTag ) / 2
      return tskCnfg.doseStringsFromDoseString(atIndex: indInDoseForTimes)
    } else {
      return []
    }
  }
  
//  // получаем начальное значение времени для picker view с tag
//  func initialDTPickerTime(withTag tag: Int) -> Int {
//    if tagIsInMinutesTags(tag) {
//      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
//      return task.minutesForTimes[indInMinutesForTimes]
//    } else {
//      return -1
//    }
//  }
  
  // получаем начальное значение времени для picker view с tag
  func initialDTPickerTime(withTag tag: Int) -> (selectedMinutes: Int, minimumMinutes: Int, maximumMinutes: Int) {
    
    var selectedMinutes = 0
    var minimumMinutes = 0
    var almostMaximumMinutes = DateHelper.maxMinutes - 1
    
    if tagIsInMinutesTags(tag) {
      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
      selectedMinutes = task.minutesForTimes[indInMinutesForTimes]
      
      if indInMinutesForTimes > 0 {
        minimumMinutes = task.minutesForTimes[indInMinutesForTimes - 1] + 1
      }
      
      if indInMinutesForTimes < task.timesPerDay - 1 {
        almostMaximumMinutes = task.minutesForTimes[indInMinutesForTimes + 1] - 1
      }
    }
    return (selectedMinutes: selectedMinutes, minimumMinutes: minimumMinutes, maximumMinutes: almostMaximumMinutes)
  }
  
  // обновляем задания данными, полученными из picker view
  // обновляем задание строковым значением, выбранным в picker view, получаем список заголовков настроек, которые также надо обновить
  func updateTask(byPickerViewWithTag tag: Int, byStrings strings: [String]) -> [Int] {
    // обновляем по крайней мере одну ячейку - расположенную над данным picker view
    let tagsToUpdate = [tag - 1]
    
    if tagIsInDoseTags(tag) {
      let indInDoseForTimes = ( tag - doseStartTag ) / 2
      task.doseForTimes[indInDoseForTimes] = tskCnfg.doseSeparatedString(fromStrings: strings)
      return tagsToUpdate
    } else {
      return []
    }
    
  }
  
  // обновляем задание временным значением
  func updateTask(byPickerViewWithTag tag: Int, byMinutes minutes: Int) -> [Int] {
    let tagsToUpdate = [tag - 1]
    if tagIsInMinutesTags(tag) {
      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
      task.minutesForTimes[indInMinutesForTimes] = minutes
      return tagsToUpdate
      
    } else {
      return []
    }
  }
  
  // переводи cell в новое состояние скрытости
  func toggleCellTagTypeState(atIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    if cellTagTypeState[section][row].state == CellState.Hidden {
      cellTagTypeState[section][row].state = .Visible
    } else {
      if cellTagTypeState[section][row].state == CellState.Visible {
        cellTagTypeState[section][row].state = .Hidden
      }
    }
  }
  
//  func allDosesAreEqual() -> Bool {
//    return task.allDosesAreEqual()
//  }
  
  func equalSwitchIsEditable() -> Bool {
    return true
  }

  
}
