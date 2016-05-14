//
//  SettingConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 25.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

enum SettingCellType {
  case TextFieldCell
  case TitleValueCell
  case TitleSwitchCell
  case TitleSegmentCell
  case DataPickerCell
  case TimePickerCell
  case DateTimePickerCell
  case ComplexPickerCell
}

enum CellState {
  case Visible
  case Active
  case Accessory
  case Hidden
}

enum ESMinutesDoseTaskTblCnfgType {
  case Minutes
  case Dose
}

class EditShowTaskTableConfiguration {
  
  var tskCnfg: TaskConfigurationByType!
  var task: Task!
  
  // структура ячеек, составляющее меню для настройки
  var cellTagTypeState: [[(tag: Int, type: SettingCellType, state: CellState)]]
  // заголовки секций
  var sectionTitles: [String]
  // заголовки названий и значений пунктов меню
  var titleValueTitles: [Int: String]
  var titleValueValues: [Int: String]
  // значения picker view
  var pickerOptions: [Int: [[String]]]
  // placeholder для text field
  var textFieldPlaceholders: [Int : String]
  
  
  // предыдущие расписания
  var previousMinutes: [Int: [Int]]
  // предыдущие минуты
  var previousDose: [Int: [String]]
  
  
  // предыдущее значение частоты
  var previousFrequency: [Int]
  // предыдущие значения для поля "Закончить"
  var previousDaysTimesDate: (days: Int, times: Int, date: NSDate)
  
  // расписание приема изменилось, необходимо пересчитать последний день приема
  var scheduleWasChanged = false
  
  var needToReloadEndDate = false
  
  init() {
    cellTagTypeState = []
    sectionTitles = []
    titleValueTitles = [:]
    titleValueValues = [:]
    pickerOptions = [:]
    textFieldPlaceholders = [:]
    
    previousMinutes = [:]
    previousDose = [:]
    previousFrequency = []
    previousDaysTimesDate = (days: 1, times: 1, date: NSDate())
  }
  
  // комплексная настройка для целого задания
  func configure(withTask task: Task) {
    
    tskCnfg = TaskConfigurationByType(task: task)
    self.task = task
    
    // видимость-невидимость ячеек в зависимости от типа задания
    configureCellTagTypeState(forType: task.type)
    // названия сегментов
    configureSectionTitles()
    
    // заголовки настроек
    titleValueTitles = [
      10: task.timesPerDayTitle,
      12: task.minutesForTimesTitle,
      14: task.doseForTimesTitle,
      16: task.specialFeatureTitle,
      
      20: task.startDateTitle,
      22: task.frequencyTitle,
      24: task.endDaysOrTimesTitle
    ]
    
    // значения настроек
    for cellTTSs in cellTagTypeState {
      for cellTTS in cellTTSs {
        if cellTTS.tag % 2 == 0 {
          titleValueValues[cellTTS.tag] = ""
          updateTitleValueValues(ofTag: cellTTS.tag, byTask: task)
        }
        
      }
    }
    
    // наполняем picker view значениями настраиваемых элементов
    pickerOptions = [
      11: [task.timesPerDayOptions],
      15: task.doseForTimesOptions,
      17: [task.specialFeatureOptions],
      23: task.frequencyOptions
    ]
    
    //наполняем placeholder для text field
    textFieldPlaceholders = [
      00: task.namePlaceholder
    ]
    
    updatePreviousMinutes()
    updatePreviousDose()
    updatePreviousFrequency()
    updatePreviousDaysTimesDate()
    
  }
  
  func updatePreviousMinutes() {
    previousMinutes[task.timesPerDay] = task.minutesForTimes
  }
  
  func updatePreviousDose() {
    previousDose[task.timesPerDay] = task.doseForTimes
  }
  
  // строим структуру меню на основании типа задания
  func configureCellTagTypeState(forType type: TaskType) {
    
    //    // общая структура меню
    //    cellTagTypeState = [
    //      [(00, .TextFieldCell, .Visible)],
    //      [
    //        (10, .TitleValueCell, .Visible), (11, .DataPickerCell, .Hidden),
    //        (12, .TitleValueCell, .Visible), (13, .TimePickerCell, .Hidden),
    //        (14, .TitleValueCell, .Visible), (15, .DataPickerCell, .Hidden),
    //        (16, .TitleValueCell, .Visible), (17, .DataPickerCell, .Hidden),
    //      ],
    //      [
    //        (20, .TitleValueCell, .Visible), (21, .DateTimePickerCell, .Hidden),
    //        (22, .TitleSegmentCell, .Visible), (23, .DataPickerCell, .Hidden),
    //        //250, 251, 252 - picker Views
    //        (24, .TitleValueCell, .Visible), (25, .ComplexPickerCell, .Hidden),
    //      ],
    //      [(30, .TextFieldCell, .Visible)]
    //    ]
    
    let type = task.type
    
    // название
    cellTagTypeState = [[(00, .TextFieldCell, .Visible)]]
    
    cellTagTypeState.append([])
    // раз в день
    switch type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure:
      cellTagTypeState[1].append((10, .TitleValueCell, .Visible))
      cellTagTypeState[1].append((11, .DataPickerCell, .Hidden))
    default:
      break
    }
    // время приема
    switch type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure:
      cellTagTypeState[1].append((12, .TitleValueCell, .Visible))
      cellTagTypeState[1].append((13, .TimePickerCell, .Hidden))
    default:
      break
    }
    // дозировка
    switch type {
    case .Pill, .Injection, .Drops, .Mixture:
      cellTagTypeState[1].append((14, .TitleValueCell, .Visible))
      cellTagTypeState[1].append((15, .DataPickerCell, .Hidden))
    default:
      break
    }
    // особые указания
    switch type {
    case .Pill, .Mixture, .Injection, .Drops, .Ointment:
      cellTagTypeState[1].append((16, .TitleValueCell, .Visible))
      cellTagTypeState[1].append((17, .DataPickerCell, .Hidden))
    default:
      break
    }
   
    cellTagTypeState.append([])
    // начать
    cellTagTypeState[2].append((20, .TitleValueCell, .Visible))
    cellTagTypeState[2].append((21, .DateTimePickerCell, .Hidden))
    // повторять
    switch type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure, .Vaccination, .WormTreatment, .FleaTreatment, .Grooming:
      cellTagTypeState[2].append((22, .TitleSegmentCell, .Visible))
      cellTagTypeState[2].append((23, .DataPickerCell, .Hidden))
    default:
      break
    }
    // закончить
    cellTagTypeState[2].append((24, .TitleValueCell, .Visible))
    cellTagTypeState[2].append((25, .ComplexPickerCell, .Hidden))
    
    // комментарий
    cellTagTypeState.append([(30, .TextFieldCell, .Visible)])
  }
  
  func getESMinutesDoseTaskTblCnfgType(ofTag tag: Int) -> ESMinutesDoseTaskTblCnfgType {
    if tag == 12 {
      return .Minutes
    } else {
      return .Dose
    }
  }
  
  // tag для секции и ряда
  func tagForIndexPath(indexPath: NSIndexPath) -> Int {
    return cellTagTypeState[indexPath.section][indexPath.row].tag
  }
  
  // секция и ряд для tag
  func indexPathForTag(tag: Int) -> NSIndexPath? {
    
    var cellTag = tag
    
    var cmplxTag = tag
    if tag == 26 {
      cmplxTag = 250
    } else if tag == 27 {
      cmplxTag = 251
    } else if tag == 28 {
      cmplxTag = 252
    }
    
    if cmplxTag > 100 {
      cellTag = cmplxTag / 10
    }
    
    for s in 0..<cellTagTypeState.count {
      for r in 0..<cellTagTypeState[s].count {
        if cellTagTypeState[s][r].tag == cellTag {
          return NSIndexPath(forRow: r, inSection: s)
        }
      }
    }
    return nil
  }
  
  // заголовки секций
  func configureSectionTitles() {
    sectionTitles = task.sectionTitles
  }
  
  // по tag обновляем значения полей по данным задания
  func updateTitleValueValues(ofTag tag: Int, byTask task: Task) {
    
    var strValue: String = ""
    switch tag {
      // название
    case 00:
      strValue = task.name
      
      // раз в день
    case 10:
      strValue = task.timesPerDayOptions[task.timesPerDay - 1]
      
      // время приема и дозировка
    case 12, 14:
      if task.timesPerDay > 1 {
        if let indexPath = indexPathForTag(tag) {
          cellTagTypeState[indexPath.section][indexPath.row].state = .Accessory
        }
      } else {
        if let indexPath = indexPathForTag(tag) {
          cellTagTypeState[indexPath.section][indexPath.row].state = .Visible
        }
      }
      
      if tag == 12 {
        // время приема
        if task.timesPerDay == 1 {
          let minutes = task.minutesForTimes[0]
          strValue = DateHelper.minutesToString(minutes)
        }
        
      } else {
        // дозировка
        if task.timesPerDay == 1 {
          strValue = tskCnfg.doseString() + " " + task.type.doseUnit()
        }
      }
      
      // особенности приема
    case 16:
      strValue = task.specialFeature
      
      // начать
    case 20:
      strValue = DateHelper.dateToString(task.startDate)
      
      // повторять
    case 22:
      if task.frequency.count == 2 {
        strValue = String(task.frequency[0]) + " / " + String(task.frequency[1])
      }
      
      // закончить
    case 24:
      switch task.endType {
      case .EndDate:
        strValue = DateHelper.dateToString(task.endDate)
      case .EndDays, .EndTimes:
        let endOptions = tskCnfg.endOptions()
        
        if task.endType == .EndDays {
          let endDays = -task.endDaysOrTimes
          strValue = "через " + endOptions[endDays - 1]
        } else {
          let endTimes = task.endDaysOrTimes
          strValue = "через " + endOptions[endTimes - 1]
        }
      }
      
      // комментарий
    case 30:
      if task.comment.isEmpty {
        strValue = "нет"
      } else {
        strValue = task.comment
      }
      
    default:
      break
    }
    
    titleValueValues[tag] = strValue
  }

  // начальные значения для picker view
  // получаем начальное строковое значение для picker view с tag
  func initialDPickerStrings(withTag tag: Int, andNewEndType endType: Task.EndType? = nil) -> [String] {
    switch tag {
      // раз в день
    case 11:
      if task.timesPerDay - 1 >= 0 {
        return [task.timesPerDayOptions[task.timesPerDay - 1]]
      }
      
      // дозировка
    case 15:
      if task.timesPerDay == 1 {
        return tskCnfg.doseStringsFromDoseString()
      } else {
        return []
      }
      
      // особенности приема
    case 17:
      return [task.specialFeature]
      
      // частота
    case 23:
      let frequencyOptions = task.frequencyOptions
      let activeDays = frequencyOptions[0]
      let passiveDays = frequencyOptions[1]
      
      let activeDay = task.frequency[0]
      let passiveDay = task.frequency[1]
      
      return [ activeDays[activeDay - 1], passiveDays[passiveDay - 1] ]
      
      // закончить через дни или разы
    case 25, 26:
      let endOptions = tskCnfg.endOptions(byNewEndType: endType)
      
      var et: Task.EndType
      
      if let endType = endType {
        et = endType
      } else {
        et = task.endType
      }
      
      if et == .EndDays {
        let endDays = previousDaysTimesDate.days
        return [endOptions[endDays - 1]]
        
      } else {
        let endTimes = previousDaysTimesDate.times
        return [endOptions[endTimes - 1]]
      }
      
    default:
      break
    }
    return []
  }
  
  // получаем начальное значение времени для picker view с tag
  func initialDTPickerTime(withTag tag: Int) -> Int {
    // время приема
    if tag == 13 {
      return task.minutesForTimes[0]
    }
    return -1
  }
  
  // получаем начальное значение времени и даты для picker view с tag
  func initialDTPickerDate(withTag tag: Int) -> (initialDate: NSDate, minimumDate: NSDate) {
    switch tag {
    // начать
    case 21:
      let idDate = NSDate(timeIntervalSince1970: task.pet.id)
      if let miDate = DateHelper.calendar.dateByAddingUnit(.Month, value: -1, toDate: idDate, options: []) {
        return (initialDate: task.startDate, minimumDate: miDate)
      } else {
        return (initialDate: task.startDate, minimumDate: idDate)
      }
      
    // закончить
    case 27:
      return (task.endDate, task.startDate)
    default:
      return (NSDate(), NSDate())
    }
  }
  
  // обновляем задания данными, полученными из picker view
  func updateTask(byTextFieldWithTag tag: Int, byString string: String) -> [Int] {
    let tagsToUpdate = [tag]
    
    switch tag {
    // название
    case 00:
      task.name = string
    // комментарий
    case 30:
      task.comment = string
    default:
      break
    }
    
    return tagsToUpdate
  }
  
  
  // обновляем задание строковым значением, выбранным в picker view, получаем список заголовков настроек, которые также надо обновить
  func updateTask(byPickerViewWithTag tag: Int, byStrings strings: [String]) -> [Int] {
    // обновляем по крайней мере одну ячейку - расположенную над данным picker view
    var tagsToUpdate = [tag - 1]
    
    switch tag {
      // раз в день
    case 11:
      let strValue = strings[0]
      if let ind = task.timesPerDayOptions.indexOf(strValue) {
        task.timesPerDay = ind + 1
        
        if let pm = previousMinutes[task.timesPerDay] {
          task.minutesForTimes = pm
        } else {
          task.correctMinutes()
          updatePreviousMinutes()
        }
        
        if let pd = previousDose[task.timesPerDay] {
          task.doseForTimes = pd
        } else {
          task.correctDose()
          updatePreviousDose()
        }
        
        scheduleWasChanged = true
      }
      // обновляем время приема и дозировку
      tagsToUpdate.append(12)
      tagsToUpdate.append(14)
      
      // дозировка при единичном употреблении
    case 15:
      task.doseForTimes = []
      task.doseForTimes.append("")
      task.doseForTimes[0] = tskCnfg.doseSeparatedString(fromStrings: strings)
      
      // особенности приема
    case 17:
      task.specialFeature = strings[0]
      
      // частота
    case 23:
      let frequencyOptions = task.frequencyOptions
      let activeDaysInd = 0
      let passiveDaysInd = 1
      
      if let ind = frequencyOptions[activeDaysInd].indexOf(strings[activeDaysInd]) {
        task.frequency[activeDaysInd] = ind + 1
      }
      if let ind = frequencyOptions[passiveDaysInd].indexOf(strings[passiveDaysInd]) {
        task.frequency[passiveDaysInd] = ind + 1
      }
      updatePreviousFrequency()
      
      scheduleWasChanged = true
      
      // закончить через число дней или раз
    case 25, 26:
      tagsToUpdate = [24]
      
      var endType: Task.EndType
      if tag == 25 {
        endType = .EndDays
      } else {
        endType = .EndTimes
      }
      
      let endOptions = tskCnfg.endOptions(byNewEndType: endType)
      
      if let ind = endOptions.indexOf(strings[0]) {
        
        if endType == .EndDays {
          task.endDaysOrTimes = -(ind + 1)
        } else {
          task.endDaysOrTimes = ind + 1
        }
        
        updatePreviousDaysTimesDate()
        
        scheduleWasChanged = true
      }
      
    default:
      break
    }
    
    return tagsToUpdate
  }
  
  // обновляем задание временным значением
  func updateTask(byPickerViewWithTag tag: Int, byMinutes minutes: Int) -> [Int] {
    let tagsToUpdate = [tag - 1]
    if tag == 13 {
      task.minutesForTimes = [minutes]
      
      scheduleWasChanged = true
    }
    return tagsToUpdate
  }
  
  // обновляем задание датой и временем
  func updateTask(task: Task, ByPickerViewWithTag tag: Int, byDateTimeValue value: NSDate) -> [Int] {
    var tagsToUpdate: [Int] = []
    
    // начать
    if tag == 21 {
      tagsToUpdate = [20]
      task.startDate = value
      
      let order = DateHelper.calendar.compareDate(task.startDate, toDate: task.endDate,
        toUnitGranularity: .Minute)
      // если начинаем, позже, чем заканчиваем - обновить "закончить"
      if order == .OrderedDescending {
        task.endDate = task.startDate
        
        needToReloadEndDate = true
        
        // обновляем надпись с датой окончания
        if task.endType == .EndDate {
          tagsToUpdate.append(24)
        }
      }
      
      scheduleWasChanged = true
      
    } else {
      // закончить в конкретную дату
      if tag == 27 {
        tagsToUpdate = [24]
        task.endDaysOrTimes = 0
        task.endDate = value
        updatePreviousDaysTimesDate()
        
        scheduleWasChanged = true
      }
    }
    return tagsToUpdate
  }
  
  // обновляем задание segmented Control
  func updateTask(bySegmentedControlWithTag tag: Int, andSegment segment: Int) -> [Int] {
    var tagsToUpdate: [Int] = []
    
    if tag == 22 {
      // выбрали "ежедневно"
      if segment == 0 {
        if task.frequency != [] {
          task.frequency = []
          tagsToUpdate = [tag]
        }
        
        scheduleWasChanged = true
        
      } else {
        // выбрали "периодически"
        if segment == 1 {
          if task.frequency == [] {
            task.frequency = previousFrequency
            tagsToUpdate = [tag]
          }
          
          scheduleWasChanged = true
          
        }
      }
    }
    return tagsToUpdate
  }
  
  func frequencySegmentTitles() -> [String] {
    return task.frequencySegmentTitles
  }
  func frequencySegmentTitle() -> String {
    if let str = titleValueValues[22] {
      return str
    } else {
      return ""
    }
  }
  func frequencySegmentFirstOption() -> Bool {
    return task.frequency.isEmpty
  }
  
  func endSegmentTitles() -> [String] {
    return task.endDaysOrTimesSegmentTitles
  }
  
  func endOptions(byNewEndType endType: Task.EndType? = nil) -> [String] {
    return tskCnfg.endOptions(byNewEndType: endType)
  }
  
  func updatePreviousDaysTimesDate() {
    let endType = task.endType
    switch endType {
    case .EndDate:
      previousDaysTimesDate.date = task.endDate
    case .EndDays:
      previousDaysTimesDate.days = -task.endDaysOrTimes
    case .EndTimes:
      previousDaysTimesDate.times = task.endDaysOrTimes
    }
  }
  
  
  
  func updatePreviousFrequency() {
    if !task.frequency.isEmpty {
      previousFrequency = task.frequency
    } else {
      previousFrequency = [1, 1]
    }
  }
  
  // переводи cell в новое состояние скрытости
  func toggleCellTagTypeState(atIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    if cellTagTypeState[section][row].state == .Hidden {
      cellTagTypeState[section][row].state = .Visible
    } else {
      if cellTagTypeState[section][row].state == .Visible {
        cellTagTypeState[section][row].state = .Hidden
      }
    }
  }
  
}