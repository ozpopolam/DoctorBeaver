//
//  TaskMenuConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 25.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

// type of cells
enum TaskMenuCellType {
  case TextFieldCell
  case TitleValueCell
  case TitleSwitchCell
  case TitleSegmentCell
  case DataPickerCell
  case TimePickerCell
  case DateTimePickerCell
  case ComplexPickerCell
}

// states of cells
enum TaskMenuCellState {
  case Visible
  case Active
  case Accessory
  case Hidden
}

// type of menu, which is about to be shown when user select corresponding cell
enum MinutesDoseMenuType {
  case Minutes
  case Dose
}

class TaskMenuConfiguration {
  var task: Task!
  
  // structure of menu, consisting of cell
  // each cell is presented by its tag, type and state
  var cellsTagTypeState: [[(tag: Int, type: TaskMenuCellType, state: TaskMenuCellState)]] = []
  
  var sectionTitles: [String] = []
  
  // titles and values for TitleValueCell
  var titleValueTitles: [Int: String] = [:] // [tag: title]
  var titleValueValues: [Int: String] = [:] // [tag: value]
  
  var pickerOptions: [Int: [[String]]] = [:]
  var textFieldPlaceholders: [Int : String] = [:]
  
  // tags of cells and their pickers
  let nameTag = 00
  let timesPerDayTitleTag = 10
  let timesPerDayPickerTag = 11
  
  let minutesForTimesTitleTag = 12
  let minutesForTimesPickerTag = 13
  
  let doseForTimesTitleTag = 14
  let doseForTimesPickerTag = 15
  
  let specialFeatureTitleTag = 16
  let specialFeaturePickerTag = 17
  
  let startDateTitleTag = 20
  let startDatePickerTag = 21
  
  let frequencyTitleTag = 22
  let frequencyPickerTag = 23
  
  let endDateTitleTag = 24
  let endDateAllPickersTag = 25
  
  let endDaysPickerTag = 250
  let endTimesPickerTag = 251
  let endDatePickerTag = 252
  
  let commentTag = 30
  
  // storing previous values
  var previousMinutes: [Int: [Int]] = [:]
  var previousDose: [Int: [String]] = [:]
  var previousFrequency: [Int] = []
  var previousDaysTimesDate: (days: Int, times: Int, date: NSDate) = (days: 1, times: 1, date: NSDate())
  
  // some part of schedule (timesPerDay, minutesForTimes, startDate, frequency, endDaysOrTimes or endDate) was changed
  var scheduleWasChanged = false
  
  // configuration of menu
  func configure(withTask task: Task) {
    self.task = task
    
    sectionTitles = task.sectionTitles
    
    // structure of cells, forming the menu
    configureCellTagTypeState()
    
    titleValueTitles = [
      timesPerDayTitleTag: task.timesPerDayTitle,
      minutesForTimesTitleTag: task.minutesForTimesTitle,
      doseForTimesTitleTag: task.doseForTimesTitle,
      specialFeatureTitleTag: task.specialFeatureTitle,
      
      startDateTitleTag: task.startDateTitle,
      frequencyTitleTag: task.frequencyTitle,
      endDateTitleTag: task.endDaysOrTimesTitle
    ]
    
    for sectionCellsTagTypeState in cellsTagTypeState {
      for cellTagTypeState in sectionCellsTagTypeState {
        if cellTagTypeState.tag % 2 == 0 {
          updateTitleValueValues(ofTag: cellTagTypeState.tag)
        }
      }
    }
    
    pickerOptions = [
      timesPerDayPickerTag: [task.timesPerDayOptions],
      doseForTimesPickerTag: task.doseForTimesOptions,
      specialFeaturePickerTag: [task.specialFeatureOptions],
      frequencyPickerTag: task.frequencyOptions
    ]
    
    textFieldPlaceholders = [
      nameTag: task.namePlaceholder,
      commentTag: task.commentPlaceholder
    ]
    
    // save previous values in case user decides to go back to them
    savePreviousMinutes()
    savePreviousDose()
    savePreviousFrequency()
    savePreviousDaysTimesDate()
  }

  // forimg the structure of cells, forming the menu
  func configureCellTagTypeState() {
    
    guard sectionTitles.count == 4 else { return }
    
    //  basic structure of menu
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
    //
    //        (24, .TitleValueCell, .Visible), (25, .ComplexPickerCell, .Hidden),
    //                                         //250, 251, 252 - picker views
    //      ],
    //      [(30, .TextFieldCell, .Visible)]
    //    ]
    
    cellsTagTypeState = [[(nameTag, .TextFieldCell, .Visible)]]
    
    if sectionTitles[1].isFilledWithSomething {
      cellsTagTypeState.append([])
      
      if task.timesPerDayTitle.isFilledWithSomething {
        cellsTagTypeState[1].append((timesPerDayTitleTag, .TitleValueCell, .Visible))
        cellsTagTypeState[1].append((timesPerDayPickerTag, .DataPickerCell, .Hidden))
      }
      
      if task.minutesForTimesTitle.isFilledWithSomething {
        cellsTagTypeState[1].append((minutesForTimesTitleTag, .TitleValueCell, .Visible))
        cellsTagTypeState[1].append((minutesForTimesPickerTag, .TimePickerCell, .Hidden))
      }
      
      if task.doseForTimesTitle.isFilledWithSomething {
        cellsTagTypeState[1].append((doseForTimesTitleTag, .TitleValueCell, .Visible))
        cellsTagTypeState[1].append((doseForTimesPickerTag, .DataPickerCell, .Hidden))
      }
      
      if task.specialFeatureTitle.isFilledWithSomething {
        cellsTagTypeState[1].append((specialFeatureTitleTag, .TitleValueCell, .Visible))
        cellsTagTypeState[1].append((specialFeaturePickerTag, .DataPickerCell, .Hidden))
      }
      
    }
    
    if sectionTitles[2].isFilledWithSomething {
      cellsTagTypeState.append([])
      
      if task.startDateTitle.isFilledWithSomething {
        cellsTagTypeState[2].append((startDateTitleTag, .TitleValueCell, .Visible))
        cellsTagTypeState[2].append((startDatePickerTag, .DateTimePickerCell, .Hidden))
      }
      
      if task.frequencyTitle.isFilledWithSomething {
        cellsTagTypeState[2].append((frequencyTitleTag, .TitleSegmentCell, .Visible))
        cellsTagTypeState[2].append((frequencyPickerTag, .DataPickerCell, .Hidden))
      }
      
      if task.endDaysOrTimesTitle.isFilledWithSomething {
        cellsTagTypeState[2].append((endDateTitleTag, .TitleValueCell, .Visible))
        cellsTagTypeState[2].append((endDateAllPickersTag, .ComplexPickerCell, .Hidden))
      }
      
    }
    
    cellsTagTypeState.append([])
    cellsTagTypeState[3].append((commentTag, .TextFieldCell, .Visible))
  }
  
  func savePreviousMinutes() {
    previousMinutes[task.timesPerDay] = task.minutesForTimes
  }
  
  func savePreviousDose() {
    previousDose[task.timesPerDay] = task.doseForTimes
  }
  
  func savePreviousFrequency() {
    if !task.frequency.isEmpty {
      previousFrequency = task.frequency
    } else {
      previousFrequency = [1, 1]
    }
  }
  
  func savePreviousDaysTimesDate() {
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
  
  
/////
  func getESMinutesDoseTaskTblCnfgType(ofTag tag: Int) -> ESMinutesDoseTaskTblCnfgType {
    if tag == minutesForTimesTitleTag {
      return .Minutes
    } else {
      return .Dose
    }
  }
////
  
  func tagForIndexPath(indexPath: NSIndexPath) -> Int {
    return cellsTagTypeState[indexPath.section][indexPath.row].tag
  }
  
  func tagForEndType(endType: Task.EndType) -> Int {
    switch endType {
    case .EndDays: return endDaysPickerTag
    case .EndTimes: return endTimesPickerTag
    case .EndDate: return endDatePickerTag
    }
  }
  
  func indexPathForTag(tag: Int) -> NSIndexPath? {
    var cellTag: Int
    
    if tag == endDaysPickerTag || tag == endTimesPickerTag || tag == endDatePickerTag {
      cellTag = endDateAllPickersTag
    } else {
      cellTag = tag
    }
    
    for s in 0..<cellsTagTypeState.count {
      for r in 0..<cellsTagTypeState[s].count {
        if cellsTagTypeState[s][r].tag == cellTag {
          return NSIndexPath(forRow: r, inSection: s)
        }
      }
    }
    return nil
  }
  
  
  // update values-part of TitleValueCell by task
  func updateTitleValueValues(ofTag tag: Int) {
    
    var strValue: String = ""
    switch tag {

    case nameTag:
      strValue = task.name
      
    case timesPerDayTitleTag:
      strValue = task.timesPerDayOptions[task.timesPerDay - 1]
      
    case minutesForTimesTitleTag, doseForTimesTitleTag:
      if task.timesPerDay > 1 {
        if let indexPath = indexPathForTag(tag) {
          cellsTagTypeState[indexPath.section][indexPath.row].state = .Accessory
        }
      } else {
        if let indexPath = indexPathForTag(tag) {
          cellsTagTypeState[indexPath.section][indexPath.row].state = .Visible
        }
      }
      
      if tag == minutesForTimesTitleTag {
        if task.timesPerDay == 1 {
          let minutes = task.minutesForTimes[0]
          strValue = DateHelper.minutesToString(minutes)
        }
        
      } else {
        if task.timesPerDay == 1 {
          strValue = task.dosePrintable(forTime: 0) + " " + task.doseUnit
        }
      }
      
    case specialFeatureTitleTag:
      strValue = task.specialFeature
      
    case startDateTitleTag:
      strValue = DateHelper.dateToString(task.startDate)
      
    case frequencyTitleTag:
      if task.frequency.count == 2 {
        strValue = String(task.frequency[0]) + " / " + String(task.frequency[1])
      }
      
    case endDateTitleTag:
      switch task.endType {
      case .EndDate:
        strValue = DateHelper.dateToString(task.endDate)
      case .EndDays, .EndTimes:
        let endOptions = task.endDaysOrTimesOptions()
        
        if task.endType == .EndDays {
          let endDays = -task.endDaysOrTimes
          strValue = endOptions[endDays - 1]
        } else {
          let endTimes = task.endDaysOrTimes
          strValue = endOptions[endTimes - 1]
        }
        
      }
      
    case commentTag:
      strValue = task.comment
      
    default:
      break
    }
    
    titleValueValues[tag] = strValue
  }

 // MARK: get initial values for picker
  func initialDataPickerValues(withTag tag: Int, andNewEndType endType: Task.EndType? = nil) -> [String] {
    switch tag {

    case timesPerDayPickerTag:
      if task.timesPerDay - 1 >= 0 {
        return [task.timesPerDayOptions[task.timesPerDay - 1]]
      }
      
    case doseForTimesPickerTag:
      if task.timesPerDay == 1 {
        return task.doseAsArrayOfStrings(forTime: 0)
      } else {
        return []
      }

    case specialFeaturePickerTag:
      return [task.specialFeature]
      
    case frequencyPickerTag:
      let frequencyOptions = task.frequencyOptions
      let activeDays = frequencyOptions[0]
      let passiveDays = frequencyOptions[1]
      
      let activeDay = task.frequency[0]
      let passiveDay = task.frequency[1]
      
      return [ activeDays[activeDay - 1], passiveDays[passiveDay - 1] ]
      
    case endDaysPickerTag, endTimesPickerTag:
      let endOptions = task.endDaysOrTimesOptions(byNewEndType: endType)
      
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
  
  func initialDateTimePickerTime(withTag tag: Int) -> Int {
    if tag == minutesForTimesPickerTag {
      return task.minutesForTimes[0]
    }
    return -1
  }
  
  func initialDateTimePickerDate(withTag tag: Int) -> (initialDate: NSDate, minimumDate: NSDate) {
    switch tag {
      
    case startDatePickerTag:
      let idDate = NSDate(timeIntervalSince1970: task.pet.id)
      if let miDate = DateHelper.calendar.dateByAddingUnit(.Month, value: -1, toDate: idDate, options: []) {
        return (initialDate: task.startDate, minimumDate: miDate)
      } else {
        return (initialDate: task.startDate, minimumDate: idDate)
      }
      
    case endDatePickerTag:
      return (task.endDate, task.startDate)
    default:
      return (NSDate(), NSDate())
    }
  }
  
 // MARK: update task by entered data from cells
  // after updating task, some cells, which are supposed to show this data, must be reloaded - return their tags
  func updateTask(byTextFieldWithTag tag: Int, byString string: String) -> [Int] {
    
    let tagsToUpdate = [tag]
    switch tag {

    case nameTag:
      task.name = string

    case commentTag:
      task.comment = string
    default:
      break
    }
    
    return tagsToUpdate
  }
  
  func updateTask(byPickerViewWithTag tag: Int, byStrings strings: [String]) -> [Int] {
    // TitleValueCell above picker, which show its value, must be reloaded
    var tagsToUpdate = [tag - 1]
    
    switch tag {

    case timesPerDayPickerTag:
      let strValue = strings[0]
      if let ind = task.timesPerDayOptions.indexOf(strValue) {
        task.timesPerDay = ind + 1
        
        if let pm = previousMinutes[task.timesPerDay] {
          task.minutesForTimes = pm
        } else {
          task.correctMinutes()
          savePreviousMinutes()
        }
        
        if let pd = previousDose[task.timesPerDay] {
          task.doseForTimes = pd
        } else {
          task.correctDose()
          savePreviousDose()
        }
        
        scheduleWasChanged = true
      }

      tagsToUpdate.append(minutesForTimesTitleTag)
      tagsToUpdate.append(doseForTimesTitleTag)
      
    case doseForTimesPickerTag:
      task.doseForTimes = []
      task.doseForTimes.append("")
      task.doseForTimes[0] = task.doseFromArrayOfStrings(strings)
      
    case specialFeaturePickerTag:
      task.specialFeature = strings[0]
      
    case frequencyPickerTag:
      let frequencyOptions = task.frequencyOptions
      let activeDaysInd = 0
      let passiveDaysInd = 1
      
      if let ind = frequencyOptions[activeDaysInd].indexOf(strings[activeDaysInd]) {
        task.frequency[activeDaysInd] = ind + 1
      }
      if let ind = frequencyOptions[passiveDaysInd].indexOf(strings[passiveDaysInd]) {
        task.frequency[passiveDaysInd] = ind + 1
      }
      savePreviousFrequency()
      
      scheduleWasChanged = true
      
    case endDaysPickerTag, endTimesPickerTag:
      tagsToUpdate = [endDateTitleTag]
      
      var endType: Task.EndType
      if tag == endDaysPickerTag {
        endType = .EndDays
      } else {
        endType = .EndTimes
      }
      
      let endOptions = task.endDaysOrTimesOptions(byNewEndType: endType)
      if let ind = endOptions.indexOf(strings[0]) {
        
        if endType == .EndDays {
          task.endDaysOrTimes = -(ind + 1)
        } else {
          task.endDaysOrTimes = ind + 1
        }
        
        savePreviousDaysTimesDate()
        
        scheduleWasChanged = true
      }
      
    default:
      break
    }
    return tagsToUpdate
  }
  
  func updateTask(byPickerViewWithTag tag: Int, byMinutes minutes: Int) -> [Int] {
    let tagsToUpdate = [tag - 1]
    if tag == minutesForTimesPickerTag {
      task.minutesForTimes = [minutes]
      
      scheduleWasChanged = true
    }
    return tagsToUpdate
  }
  
  func updateTask(byPickerViewWithTag tag: Int, byDateTimeValue value: NSDate) -> [Int] {
    var tagsToUpdate: [Int] = []
    
    if tag == startDatePickerTag {
      tagsToUpdate = [startDateTitleTag]
      task.startDate = value
      
      let order = DateHelper.calendar.compareDate(task.startDate, toDate: task.endDate,
        toUnitGranularity: .Minute)

      if order == .OrderedDescending {
        task.endDate = task.startDate

        if task.endType == .EndDate {
          tagsToUpdate.append(endDateTitleTag)
        }
      }
      
      scheduleWasChanged = true
      
    } else {

      if tag == endDatePickerTag {
        tagsToUpdate = [endDateTitleTag]
        task.endDaysOrTimes = 0
        task.endDate = value
        savePreviousDaysTimesDate()
        
        scheduleWasChanged = true
      }
    }
    return tagsToUpdate
  }
  
  func updateTask(bySegmentedControlWithTag tag: Int, andSegment segment: Int) -> [Int] {
    var tagsToUpdate: [Int] = []
    
    if tag == frequencyTitleTag {
      
      if segment == 0 { // first option - everyday
        if task.frequency != [] {
          task.frequency = []
          tagsToUpdate = [tag]
        }
        
        scheduleWasChanged = true
        
      } else {
        if segment == 1 { // second option - periodically
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
    if let str = titleValueValues[frequencyTitleTag] {
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
    return task.endDaysOrTimesOptions(byNewEndType: endType)
  }
  
  // change state of cell from hidden to visible or vice versa
  func toggleCellTagTypeState(atIndexPath indexPath: NSIndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    
    if cellsTagTypeState[section][row].state == .Hidden {
      cellsTagTypeState[section][row].state = .Visible
    } else {
      if cellsTagTypeState[section][row].state == .Visible {
        cellsTagTypeState[section][row].state = .Hidden
      }
    }
  }
  
}