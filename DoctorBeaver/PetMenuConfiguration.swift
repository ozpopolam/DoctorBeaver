//
//  PetMenuConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

// type of cells
enum PetMenuCellType {
  case TextFieldCell
  case TitleImageCell
  case TitleSwitchCell
  case IconTitleCell
  case AddCell
}

// states of cells
enum PetMenuCellState {
  case Visible
  case Hidden
  case Active
  case Disclosure
  case Detail
}

class PetMenuConfiguration {
  var pet: Pet!
  
  // structure of menu, consisting of cell
  // each cell is presented by its tag, type and state
  var cellsTagTypeState: [[(tag: Int, type: PetMenuCellType, state: PetMenuCellState)]] = []
  var sectionTitles: [String] = []
  
  // tags of cells and their pickers
  let menuSection = 0
  let nameTag = 00
  let imageTag = 02
  let selectedTitleTag = 04
  
  let taskSection = 1
  let taskTag = 10
  var taskAddTag = 0 // calculated based on amount of tasks
  
  var petHasTasksSectionTitle = ""
  var petHasNoTasksSectionTitle = ""
  
  // configuration of menu
  func configure(withPet pet: Pet, forMenuMode menuMode: PetMenuMode) {
    self.pet = pet
    
    sectionTitles = pet.sectionTitles
    petHasTasksSectionTitle = pet.sectionTitles[taskSection]
    petHasNoTasksSectionTitle = "нет ни одного задания"
    
    // structure of cells, forming the menu
    configureCellTagTypeState(forMenuMode: menuMode)
  }
  
  // forimg the structure of cells, forming the menu
  func configureCellTagTypeState(forMenuMode menuMode: PetMenuMode) {
    
    guard sectionTitles.count == 2 else { return }
    cellsTagTypeState = []
    
    cellsTagTypeState.append([])
    cellsTagTypeState[menuSection].append((nameTag, .TextFieldCell, .Visible))
    cellsTagTypeState[menuSection].append((imageTag, .TitleImageCell, .Disclosure))
    cellsTagTypeState[menuSection].append((selectedTitleTag, .TitleSwitchCell, .Visible))
    
    cellsTagTypeState.append([])
    for _ in 0..<pet.tasks.count {
      cellsTagTypeState[taskSection].append((taskTag, .IconTitleCell, .Detail))
    }
    cellsTagTypeState[taskSection].append((taskTag, .AddCell, .Hidden)) // add-task cell
    
    configureTasksSectionTitle()
  }
  
  func configureTasksSectionTitle() {
    if pet.hasNoTasks {
      sectionTitles[taskSection] = petHasNoTasksSectionTitle
    } else {
      sectionTitles[taskSection] = petHasTasksSectionTitle
    }
  }
  
  func addOneCellForTask() {
    if !pet.hasNoTasks {
      cellsTagTypeState[taskSection].insert((taskTag, .IconTitleCell, .Detail), atIndex: 0)
    }
  }
  
  func deleteOneCellForTask() {
    if !pet.hasNoTasks {
      cellsTagTypeState[taskSection].removeFirst()
    }
  }
  
  func tagForIndexPath(indexPath: NSIndexPath) -> Int {
    return cellsTagTypeState[indexPath.section][indexPath.row].tag
  }
  
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
  
  // MARK: update task by entered data from cells
  // after updating task, some cells, which are supposed to show this data, must be reloaded - return their tags
  func updatePet(byTextFieldWithTag tag: Int, byString string: String) {
    if tag == nameTag {
      pet.name = string
    }
  }
  
  func updatePet(byStateSwitchWithTag tag: Int, byState state: Bool) {
    if tag == selectedTitleTag {
      pet.selected = state
    }
  }
  
}