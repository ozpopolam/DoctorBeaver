//
//  EditShowMinutesDoseTaskTableConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

// type of cells
enum MinutesDoseMenuCellType {
  case TitleSwitchCell
  case TitleValueCell
  case TimePickerCell
  case DataPickerCell
}

// states of cells
enum MinutesDoseMenuCellState {
  case Visible
  case Hidden
}

class MinutesDoseMenuConfiguration {
  var task: Task!
  var menuType = MinutesDoseMenuType.Minutes
  
  let minutesStartTag = 1200
  let equalDoseTag = 1400
  let doseStartTag = 1402
  
  // structure of menu, consisting of cell
  // each cell is presented by its tag, type and state
  var cellsTagTypeState: [[(tag: Int, type: MinutesDoseMenuCellType, state: MinutesDoseMenuCellState)]] = []
  
  // titles and values for TitleValueCell
  var titleValueTitles: [Int: String] = [:] // [tag: title]
  var titleValueValues: [Int: String] = [:] // [tag: value]
  
  var pickerOptions: [Int: [[String]]] = [:]
  
  var doseForTimesEqualTitle = "" // title for equal dose
  
  // положение equal switch
  var equalDoseSwitchOn = false
  
  // configuration of menu
  func configure(withTask task: Task, andType type: MinutesDoseMenuType) {
    self.task = task
    menuType = type
    equalDoseSwitchOn = task.allDosesAreEqual()
    
    // structure of cells, forming the menu
    configureCellTagTypeState()
    configureTitleValueTitles()
    configureTitleValueValues()
    
    if menuType == .Dose {
      pickerOptions = [doseStartTag: task.doseForTimesOptions]
    }
    
    doseForTimesEqualTitle = task.typeItem.doseForTimesEqualTitle
  }
  
  // forimg the structure of cells, forming the menu
  func configureCellTagTypeState() {
    cellsTagTypeState = []
    
    var valueCellType = MinutesDoseMenuCellType.TitleValueCell
    var titleCellState = MinutesDoseMenuCellState.Hidden
    
    var startIndForCellPairs = 0 // (titleValue and picker cells)
    var tag = 0
    
    cellsTagTypeState.append([])
    
    if menuType == .Minutes {
      tag = minutesStartTag
      valueCellType = .TimePickerCell // will be picking minutes
      titleCellState = .Visible
      
    } else if menuType == .Dose {
      // cell with switch for all equal doses
      cellsTagTypeState[0].append((equalDoseTag, .TitleSwitchCell, .Visible))
      tag = doseStartTag
      valueCellType = .DataPickerCell // will be picking doses
      
      if equalDoseSwitchOn { // all doses are equal -> need to add only one visible title cell and picker cell to pick it
        cellsTagTypeState[0].append((tag, .TitleValueCell, .Visible))
        tag += 1
        cellsTagTypeState[0].append((tag, .DataPickerCell, .Hidden))
        tag += 1
        
        startIndForCellPairs = 1 // first dose at index 0 we have already added, so we will continue from index 1
        titleCellState = .Hidden // need to hide cells the rest doses, which are the same
      } else { //  different doses
        titleCellState = .Visible
      }
      
    }
    
    // add pairs of cells for choosing minutes or dose
    for _ in startIndForCellPairs..<task.timesPerDay {
      cellsTagTypeState[0].append((tag, .TitleValueCell, titleCellState))
      tag += 1
      cellsTagTypeState[0].append((tag, valueCellType, .Hidden))
      tag += 1
    }
  }
  
  // set all titles-part of TitleValueCell
  func configureTitleValueTitles() {
    var titles = [String]()
    var tag = 0
    
    if menuType == .Minutes {
      titles = task.minutesForTimesOrderTitles // "First time", "Second time", ...
      tag = minutesStartTag
      
    } else if menuType == .Dose {
      titles = task.doseForTimesOrderTitles // "First dose", "Second dose", ...
      tag = doseStartTag
    }
    
    for ind in 0..<task.timesPerDay {
      titleValueTitles[tag] = titles[ind]
      tag += 2
    }
  }
  
  // set all values-part of TitleValueCell
  func configureTitleValueValues() {
    var tag = 0
    
    if menuType == .Minutes {
      tag = minutesStartTag
    } else if menuType == .Dose {
      tag = doseStartTag
    }
    
    for _ in 0..<task.timesPerDay { // create list of tags
      titleValueValues[tag] = ""
      tag += 2
    }
    
    // fill dictionary with tags and values
    for key in titleValueValues.keys {
      updateTitleValueValues(ofTag: key)
    }
    
  }
  
  // update values-part of TitleValueCell by task
  func updateTitleValueValues(ofTag tag: Int) {
    var strValue: String = ""
    
    if menuType == .Minutes {
      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2 // translate tag to index
      let minutes = task.minutesForTimes[indInMinutesForTimes]
      strValue = DateHelper.minutesToString(minutes)
      
    } else if menuType == .Dose {
      let time = ( tag - doseStartTag ) / 2
      strValue = task.dosePrintable(forTime: time) + " " + task.doseUnit
      //tskCnfg.doseString(atInd: indInDoseForTimes) + " " + task.type.doseUnit()
    }
    
    titleValueValues[tag] = strValue
  }
  
  
  
  func indexPathForEqualSwitchCell() -> NSIndexPath? {
    for s in 0..<cellsTagTypeState.count {
      for r in 0..<cellsTagTypeState[s].count {
        if cellsTagTypeState[s][r].type == MinutesDoseMenuCellType.TitleSwitchCell {
          return NSIndexPath(forRow: r, inSection: s)
        }
      }
    }
    return nil
  }
  
  // return dose options if cell's tag in dose-tags
  func pickerOptionsForDose(forTag tag: Int) -> [[String]]? {
    if tagIsInDoseTags(tag) {
      if let options = pickerOptions[doseStartTag] {
        return options
      }
    }
    return nil
  }
  
//  func minutesForTimesTitle() -> String {
//    return task.minutesForTimesTitle
//  }
//  
//  func doseForTimesTitle() -> String {
//    return task.doseForTimesTitle
//  }
  
  func indexPathForTag(tag: Int) -> NSIndexPath? {
    for s in 0..<cellsTagTypeState.count {
      for r in 0..<cellsTagTypeState[s].count {
        if cellsTagTypeState[s][r].tag == tag {
          return NSIndexPath(forRow: r, inSection: s)
        }
      }
    }
    return nil
  }
  
// MARK: get initial values for picker
  func initialDataPickerValues(withTag tag: Int) -> [String] {
    if tagIsInDoseTags(tag) {
      let time = ( tag - doseStartTag ) / 2
      return task.doseAsArrayOfStrings(forTime: time)
    } else {
      return []
    }
  }
  
  func tagIsInDoseTags(tag: Int) -> Bool { // is tag in dose-tags
    if tag - tag % 100 + doseStartTag % 100 == doseStartTag {
      return true
    } else {
      return false
    }
  }
  
//  func initialDateTimePickerTime(withTag tag: Int) -> Int {
//    if tagIsInMinutesTags(tag) {
//      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
//      return task.minutesForTimes[indInMinutesForTimes]
//    } else {
//      return -1
//    }
//  }
  
  func initialDateTimePickerTime(withTag tag: Int) -> (selectedMinutes: Int, minimumMinutes: Int, maximumMinutes: Int) {
    
    var selectedMinutes = 0
    var minimumMinutes = 0
    var maximumMinutes = DateHelper.maxMinutes - 1
    
    if tagIsInMinutesTags(tag) {
      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
      selectedMinutes = task.minutesForTimes[indInMinutesForTimes]
      
      // minimum minutes of picker[ind] must be > than minutes of picker[ind - 1]
      if indInMinutesForTimes > 0 {
        minimumMinutes = task.minutesForTimes[indInMinutesForTimes - 1] + 1
      }
      
      // if picker [ind] is not the last one, maximum minutes must be < than selected minutes of picker [ind + 1]
      if indInMinutesForTimes < task.timesPerDay - 1 {
        maximumMinutes = task.minutesForTimes[indInMinutesForTimes + 1] - 1
      }
    }
    return (selectedMinutes: selectedMinutes, minimumMinutes: minimumMinutes, maximumMinutes: maximumMinutes)
  }
  
  func tagIsInMinutesTags(tag: Int) -> Bool { // is tag in minutes-tags
    if tag - tag % 100 == minutesStartTag {
      return true
    } else {
      return false
    }
  }
  
// MARK: update task by entered data from cells
  // after updating task, some cells, which are supposed to show this data, must be reloaded - return their tags
  func updateTask(byPickerViewWithTag tag: Int, byStrings strings: [String]) -> [Int] {
    
    // TitleValueCell above picker, which show its value, must be reloaded
    let tagsToUpdate = [tag - 1]
    
    if tagIsInDoseTags(tag) {
      
      let dose = task.doseFromArrayOfStrings(strings)
      
      if equalDoseSwitchOn { // all doses must be equal - set selected dose to all doses of task
        for ind in 0..<task.doseForTimes.count {
          task.doseForTimes[ind] = dose
        }
      } else { // set selected dose to only one dose of task
        let indInDoseForTimes = ( tag - doseStartTag ) / 2
        task.doseForTimes[indInDoseForTimes] = dose
      }
      
      return tagsToUpdate
    } else {
      return []
    }
    
  }
  
  func updateTask(byPickerViewWithTag tag: Int, byMinutes minutes: Int) -> [Int] {
    
    // TitleValueCell above picker, which show its value, must be reloaded
    let tagsToUpdate = [tag - 1]
    
    if tagIsInMinutesTags(tag) {
      let indInMinutesForTimes = ( tag - minutesStartTag ) / 2
      task.minutesForTimes[indInMinutesForTimes] = minutes
      return tagsToUpdate
      
    } else {
      return []
    }
  }
  
  
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
  
  func allDosesAreEqual() -> Bool {
    return task.allDosesAreEqual()
  }
  
}
