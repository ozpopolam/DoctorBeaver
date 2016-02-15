//
//  TableViewController.swift
//  tableView
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit



class ScheduleTableViewController: UITableViewController {
  

  // все задания для выбранных питомцев
  var schedule = [Task]()
  // выбранные притомцы
  var pets = [Pet]() {
    didSet {
      schedule = []
      for pet in pets {
        for task in pet.schedule {
          schedule.append(task)
        }
      }
    }
  }
  
  let headerCellId = "headerCell"
  let manyPetsCellId = "manyPetsCell"
  let singlePetCellId = "singlePetCell"
  
  
  // группы задания по времени выполнения и число задания в группах
  var sectionRow = [DayPartTask]()
  
  // группы заданий по времени выполнения
  var morningTask = [Task]()
  var dayTask = [Task]()
  var eveningTask = [Task]()
  var nightTask = [Task]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func reloadData() {
    tableView.reloadData()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    calculateNumberOfSectionsAndRows()
    return sectionRow.count
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellId) as! HeaderCell
    headerCell.titleLabel.text = sectionRow[section].dayPart.rawValue.lowercaseString
    return headerCell
  }
  
  typealias DayPartTask = (dayPart: DayPart, taskCount: Int)
  
  
  // группируем задания по времени выполнения и подбираем для этих групп заголовки
  func calculateNumberOfSectionsAndRows() {
  
    morningTask = []
    dayTask = []
    eveningTask = []
    nightTask = []
    
    sectionRow = []
    
    // разбиваем задания на группы
    for task in schedule {
      switch task.dayPart {
      case .Morning: morningTask.append(task)
      case .Day: dayTask.append(task)
      case .Evening: eveningTask.append(task)
      case .Night: nightTask.append(task)
      }
    }
    
    // если в группа не пустая - ей понадобится заголовок
    
    if morningTask.count > 0 {
      sectionRow.append((.Morning, morningTask.count))
    }
    if dayTask.count > 0 {
      sectionRow.append((.Day, dayTask.count))
    }
    if eveningTask.count > 0 {
      sectionRow.append((.Evening, eveningTask.count))
    }
    if nightTask.count > 0 {
      sectionRow.append((.Night, nightTask.count))
    }
    
    // возвращаем перечень заголовков групп и соответствующее количество заданий в них
    
    
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sectionRow[section].taskCount
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(manyPetsCellId, forIndexPath: indexPath) as! ManyPetsCell
    
    let task = taskForRow(atIndexPath: indexPath)
    
    cell.timeLabel.text = "\(task.time):00"
    cell.iconImageView.image = UIImage(named: task.icon)
    cell.taskTitleLabel.text = task.name.uppercaseString
    cell.taskDetailLabel.text = task.description
    if let petOwner = task.petOwner {
      cell.petImageView.image = UIImage(named: petOwner.image)
      cell.petNameLabel.text = petOwner.name
    }
    
    configureCellDoneState(cell, byTask: task)
    
    return cell
  }
  
  
  // вычисляем, какое задание соответствует данной ячейке
  func taskForRow(atIndexPath indexPath: NSIndexPath) -> Task {
    
    let dayPart = sectionRow[indexPath.section].dayPart
    var task: Task
    
    switch dayPart {
    case .Morning: task = morningTask[indexPath.row]
    case .Day: task = dayTask[indexPath.row]
    case .Evening: task = eveningTask[indexPath.row]
    case .Night: task = nightTask[indexPath.row]
    }
    
    return task
  }
  
  // проверяем, сделано ли задание и конфигурируем яйчейку
  func configureCellDoneState(cell: ManyPetsCell, byTask task: Task) {
    if task.done {
      cell.selectView.hidden = false
      cell.timeLabel.hidden = true
      cell.checkmarkImageView.hidden = false
    } else {
      cell.selectView.hidden = true
      cell.timeLabel.hidden = false
      cell.checkmarkImageView.hidden = true
    }
  }
  
  
  // выбрана ячейка - сделанность задания изменилась
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    if let cell = cell as? ManyPetsCell {
      let task = taskForRow(atIndexPath: indexPath)
      task.done = !task.done
      configureCellDoneState(cell, byTask: task)
    }
  }
  
}
