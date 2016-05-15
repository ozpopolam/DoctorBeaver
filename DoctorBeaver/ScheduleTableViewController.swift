//
//  TableViewController.swift
//  tableView
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class ScheduleTableViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var warningLabel: UILabel!
  
  // id ячеек
  let headerCellId = "headerCell"
  let basicPetCellId = "basicPetCell"
  let manyPetsCellId = "manyPetsCell"
  
  // addEditTask
  let editShowTaskSegueId = "editShowTaskSegue"
  
  // максимальная высота ячейки
  let maxCellHeight: CGFloat = 88.0
  // размер инонки с i
  let infoIconSize = CGSize(width: 22, height: 22)
  // иконка со значком i
  var infoIcon: UIImage?
  
  var petsRepository: PetsRepository!
  var scheduleWasSet = false
  var viewWasLoadedWithSchedule = false
  
  // питомцы, чьи задания будут отображены
  var pets: [Pet] = []
  // дата отображаемых заданий
  var date = NSDate()
  let calendar = NSCalendar.currentCalendar()
  
  var accessoryButtonTask: Task?
  
  typealias TimeRealization = (timeInDay: Int, realization: Realization)
  var timeRealizations: [TimeRealization] = []
  
  var headerNames: [String] = []
  var indexesForHeader: [Int] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // высота ячеек будет вычислена из Auto Layout
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = maxCellHeight
    warningLabel.text = "на сегодня расписание пусто, попробуйте выбрать другой день"
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    infoIcon = UIImage(named: "info")
    infoIcon = infoIcon?.ofSize(infoIconSize)
    
    // если view загружено, подгружаем в него данные
    if viewIsReadyToBeLoadedWithSchedule() {
      reloadScheduleTable()
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func reloadScheduleTable() {
    var possibleTasks: [Task] = []
    var realizations: [Realization] = []
    
    // выбираем задания, в которых может быть искомая дата
    possibleTasks = getPossibleTasks(fromPets: pets, forDate: date)
    
    if possibleTasks.count == 0 {
      showWarningMessage()
    } else {
      // ищем конкретные планы выполнения задания по дате
      realizations = getRealizations(fromTasks: possibleTasks, forDate: date)
      if realizations.count == 0 {
        showWarningMessage()
      } else {
        timeRealizations = getTimeRealizations(fromRealizations: realizations)
        if timeRealizations.count == 0 {
          showWarningMessage()
        } else {
          timeRealizations.sortInPlace(sortedByMinutesAndNameASC)
          prepareDataSourceAndReloadTable()
        }
      }
    }
    
  }
  
  func prepareDataSourceAndReloadTable() {
    
    if timeRealizations.count == 0 {
      showWarningMessage()
    } else {
      
      calculateHeadersAndIndexes(ofTimeRealizations: timeRealizations)
      
      if self.isViewLoaded() {
        if tableView.hidden == true {
          tableView.hidden = false
        }
        if warningLabel.hidden == false {
          warningLabel.hidden = true
        }
        tableView.reloadData()
      }
    }
  }
  
  func updateScheduleTable(withTask task: Task) {
    var possibleTasks: [Task] = []
    var realizations: [Realization] = []
    var taskTimeRealizations: [TimeRealization] = []
    
    // проверяем, может ли в задании быть искомая дата
    if task.dateInTaskStartEndRange(date) {
      possibleTasks.append(task)
    }
    
    if possibleTasks.count != 0 {
      // ищем конкретные планы выполнения задания по дате
      realizations = getRealizations(fromTasks: possibleTasks, forDate: date)
      if realizations.count != 0 {
        taskTimeRealizations = getTimeRealizations(fromRealizations: realizations)
        
        for ttr in taskTimeRealizations {
          timeRealizations.append(ttr)
        }
      }
    }
    
    if timeRealizations.count == 0 {
      showWarningMessage()
    } else {
      timeRealizations.sortInPlace(sortedByMinutesAndNameASC)
      prepareDataSourceAndReloadTable()
    }
    
  }
  
  // показываем строку с предупреждением
  func showWarningMessage() {
    if tableView.hidden == false {
      tableView.hidden = true
    }
    if warningLabel.hidden == true {
      warningLabel.hidden = false
    }
  }
  
  // выбираем задания, которые могут быть актуальны для заданной даты
  func getPossibleTasks(fromPets pets: [Pet], forDate date: NSDate) -> [Task] {
    var tasks: [Task] = []
    
    for pet in pets {
      for task in pet.tasks {
        if let task = task as? Task {
          
          if task.dateInTaskStartEndRange(date) {
            tasks.append(task)
          }
        }
      }
    }
    
    return tasks
  }
  
  // выбираем конкретные планы выполнения задания по дате
  func getRealizations(fromTasks tasks: [Task], forDate date: NSDate) -> [Realization] {
    
    var realizations: [Realization] = []
    
    for task in tasks {
      if let realization = getRealization(fromRealizations: task.realizations, forDate: date) {
        // если для даты уже есть список "сделано-несделано", то добавляем его в итоговый список
        realizations.append(realization)
      } else {
        // списка нет - вычисляем новый список, добавляем его в базу
        let done = task.getDone(forDate: date)
        
        if let realization = petsRepository.insertRealization() {
          realization.task = task
          realization.date = date
          realization.done = done
          
          realizations.append(realization)
          petsRepository.saveOrRollback()
        }
      }
    }
    return realizations
  }
  
  // выбираем конкретные планы выполнения задания по дате у определенного задания
  func getRealization(fromRealizations realizations: NSOrderedSet, forDate date: NSDate) -> Realization? {
    for realization in realizations {
      if let realization = realization as? Realization {
        if DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: realization.date) == .OrderedSame {
          return realization
        }
      }
    }
    return nil
  }
  
  // составляем пары из времени выполнения и конкретного планы выполнения задания
  func getTimeRealizations(fromRealizations realizations: [Realization]) -> [TimeRealization] {
    var timeRealizations: [TimeRealization] = []
    
    for realization in realizations {
      for time in 0..<realization.task.timesPerDay {
        // -1 - время не актуально
        if realization.done[time] != -1 {
          timeRealizations.append((timeInDay: time, realization: realization))
        }
      }
    }
    
    return timeRealizations
  }
  
  // сортируем конкретные планы выполнения по времени и по имени питомца
  func sortedByMinutesAndNameASC(lh: TimeRealization, rh: TimeRealization) -> Bool {
    if lh.realization.task.minutesForTimes[lh.timeInDay] == rh.realization.task.minutesForTimes[rh.timeInDay] {
      // время задания равно - соритуем по имени питомца
      
      return lh.realization.task.pet.name.localizedStandardCompare(rh.realization.task.pet.name) == .OrderedAscending
    } else {
      
      var lhm = lh.realization.task.minutesForTimes[lh.timeInDay]
      if minutesIsNight(lhm) {
        lhm += DateHelper.maxMinutes
      }
      
      var rhm = rh.realization.task.minutesForTimes[rh.timeInDay]
      if minutesIsNight(rhm) {
        rhm += DateHelper.maxMinutes
      }
      
      return lhm < rhm
    }
  }
  
  // минуты в ночное время
  func minutesIsNight(minutes: Int) -> Bool {
    if 0...299 ~= minutes || 1260...DateHelper.maxMinutes ~= minutes {
      return true
    } else {
      return false
    }
  }
  
  // вычисляем число и значения заголовков
  func calculateHeadersAndIndexes(ofTimeRealizations timeRealizations: [TimeRealization]) {
    let partOfTheDayNames = ["утро", "день", "вечер", "ночь"]
    var partOfTheDayAmount: [Int] = [0, 0, 0, 0]
    
    for tr in timeRealizations {
      switch tr.realization.task.minutesForTimes[tr.timeInDay] {
      // утро с 5 до 11.59
      case 300...719:
        partOfTheDayAmount[0] += 1
      // день с 12 до 16.59
      case 720...1019:
        partOfTheDayAmount[1] += 1
      // вечер c 17 до 20.59
      case 1020...1259:
        partOfTheDayAmount[2] += 1
      // ночь с 21 до 5
      default:
        partOfTheDayAmount[3] += 1
      }
    }
    
    headerNames = []
    indexesForHeader = []
    for ind in 0..<partOfTheDayAmount.count {
      if partOfTheDayAmount[ind] != 0 {
        headerNames.append(partOfTheDayNames[ind])
        indexesForHeader.append(partOfTheDayAmount[ind])
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == editShowTaskSegueId {
      
      if let destinationVC = segue.destinationViewController as? EditShowTaskViewController {
        destinationVC.petsRepository = petsRepository
        if let accessoryButtonTask = accessoryButtonTask {
          destinationVC.delegate = self
          destinationVC.task = accessoryButtonTask
          destinationVC.hidesBottomBarWhenPushed = true
        }
      }
    }
    
  }
  
  func setSchedule(withPetsRepository petsRepository: PetsRepository, withPets pets: [Pet], andDate date: NSDate) {
    self.petsRepository = petsRepository
    self.pets = pets
    self.date = date
    
    if !self.scheduleWasSet {
      self.scheduleWasSet = true
    }
    
    // если view загружено, подгружаем в него данные расписания
    if viewIsReadyToBeLoadedWithSchedule() {
      reloadScheduleTable()
    }
  }
  
  // проверяем, можно ли обновить view переданными данными
  func viewIsReadyToBeLoadedWithSchedule() -> Bool {
    if isViewLoaded() && scheduleWasSet {
      self.viewWasLoadedWithSchedule = true
      return true
    } else {
      return false
    }
  }
  
}

extension ScheduleTableViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return indexesForHeader.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return indexesForHeader[section]
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if pets.count == 1 {
      if let cell = tableView.dequeueReusableCellWithIdentifier(basicPetCellId, forIndexPath: indexPath) as? BasicPetCell {
        configureBasicPetCell(cell, forRowAtIndexPath: indexPath)
        return cell
      }
    } else {
      if let cell = tableView.dequeueReusableCellWithIdentifier(manyPetsCellId, forIndexPath: indexPath) as? ManyPetsCell {
        configureManyPetsCell(cell, forRowAtIndexPath: indexPath)
        return cell
      }
    }
    
    return UITableViewCell()
  }
  
  // конфигурируем базовую часть ячейки, общую для всех
  func configureBasicPetCell(cell: BasicPetCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.tintColor = UIColor.lightGrayColor()
    
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    let minutes = tr.realization.task.minutesForTimes[tr.timeInDay]
    let minutesString = DateHelper.minutesToString(minutes)
    cell.timeLabel.text = minutesString
    
    let iconName = tr.realization.task.typeItem.iconName
    cell.iconImageView.image = UIImage(named: iconName)
    
    if tr.realization.task.name.isEmpty {
      cell.taskTitleLabel.text = tr.realization.task.typeItem.name
    } else {
      cell.taskTitleLabel.text = tr.realization.task.name
    }
    
    cell.taskDetailLabel.text = tr.realization.task.details(forTime: tr.timeInDay)
    
    if let infoIcon = infoIcon {
      let detailButton = UIButton(type: .Custom)
      detailButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: infoIconSize)
      detailButton.setImage(withImage: infoIcon, ofSize: infoIconSize, withTintColor: UIColor.blackColor())
      detailButton.addTarget(self, action: "detailButtonTapped:", forControlEvents: .TouchUpInside)
      
      cell.accessoryView = detailButton
    }
    
    configureCellDoneState(cell, forRowAtIndexPath: indexPath)
  }
  
  // определяем, detail-кнопка какой ячейки была нажата и вызываем accessoryButtonTappedForRowWithIndexPath
  func detailButtonTapped(sender: UIButton) {
    let senderPoint = sender.convertPoint(CGPointZero, toView: tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(senderPoint) {
      tableView(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
    }
  }
  
  // конфигурируем часть ячейки, актуальную только для варианта с множеством питомцев
  func configureManyPetsCell(cell: ManyPetsCell, forRowAtIndexPath indexPath: NSIndexPath) {
    configureBasicPetCell(cell, forRowAtIndexPath: indexPath)
    
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    cell.petNameLabel.text = tr.realization.task.pet.name
    cell.petImageView.image = UIImage(named: tr.realization.task.pet.image)
  }
  
  // конфигурируем состояние выполненности задания
  func configureCellDoneState(cell: BasicPetCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    if tr.realization.done[tr.timeInDay] == 1 {
      // задание выполнено
      cell.selectView.hidden = false
      cell.timeLabel.hidden = true
      cell.checkmarkImageView.hidden = false
    } else {
      if tr.realization.done[tr.timeInDay] == 0 {
        // задание не выполнено
        cell.selectView.hidden = true
        cell.timeLabel.hidden = false
        cell.checkmarkImageView.hidden = true
      }
    }
  }
  
  // получаем TimeRealization для indexPath
  func timeRealizationForRowAtIndexPath(indexPath: NSIndexPath) -> TimeRealization {
    
    var row = 0
    for ind in 0..<indexPath.section {
      row += indexesForHeader[ind]
    }
    
    row += indexPath.row
    
    return timeRealizations[row]
  }
  
}

extension ScheduleTableViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellId) as? HeaderCell {
      headerCell.titleLabel.text = headerNames[section]
      return headerCell
    } else {
      return nil
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    if tr.realization.done[tr.timeInDay] == 0 {
      tr.realization.done[tr.timeInDay] = 1
    } else {
      if tr.realization.done[tr.timeInDay] == 1 {
        tr.realization.done[tr.timeInDay] = 0
      }
    }
    
    petsRepository.saveOrRollback()
    
    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BasicPetCell {
      configureCellDoneState(cell, forRowAtIndexPath: indexPath)
    }
  }
  
  
  
  func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    let timeRealization = timeRealizationForRowAtIndexPath(indexPath)
    accessoryButtonTask = timeRealization.realization.task
    performSegueWithIdentifier(editShowTaskSegueId, sender: self)
  }
  
}

extension ScheduleTableViewController: EditShowTaskVCDelegate {
  func editShowTaskVC(viewController: EditShowTaskViewController, didDeleteTask task: Task) {
    navigationController?.popViewControllerAnimated(true)
    
    timeRealizations = timeRealizations.filter { $0.realization.task != task } // delete timeRealizations of task, which is about to be deleted itself
    
    // delete task and save it
    petsRepository.deleteObject(task)
    petsRepository.saveOrRollback()
    
    // try to reload table
    prepareDataSourceAndReloadTable()
  }
  
  func editShowTaskVC(viewController: EditShowTaskViewController, didSlightlyEditScheduleOfTask task: Task) {
    petsRepository.saveOrRollback() // save changes in task
    tableView.reloadData() // reload table
  }
  
  func editShowTaskVC(viewController: EditShowTaskViewController, didFullyEditScheduleOfTask task: Task) {
    
    timeRealizations = timeRealizations.filter { $0.realization.task != task } // delete outdated timeRealizations
    
    
    task.realizations.map{petsRepository.deleteObject($0 as! NSManagedObject)}
    
    
    for realization in task.realizations {
      if let realization = realization as? Realization {
        petsRepository.deleteObject(realization)
      }
    }
    task.realizations = []
    
    // сохраняем изменения
    petsRepository.saveOrRollback()
    
    updateScheduleTable(withTask: task)
  }
  
}