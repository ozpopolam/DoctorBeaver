//
//  ScheduleTableViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 09.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleTableViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var warningLabel: UILabel!
  
  // cell's id
  let headerId = "headerView"
  let basicPetCellId = "basicPetCell"
  let manyPetsCellId = "manyPetsCell"
  
  let taskMenuSegueId = "taskMenuSegue"
  
  // info icon with i-symbol
  var infoIcon: UIImage?
  
  var petsRepository: PetsRepository!
  var scheduleWasSet = false
  var viewWasLoadedWithSchedule = false
  
  var pets: [Pet] = []
  var date = NSDate()
  
  typealias TimeRealization = (timeInDay: Int, realization: Realization)
  var timeRealizations: [TimeRealization] = []
  
  var headerNames: [String] = []
  var indexesForHeader: [Int] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    warningLabel.text = "на сегодня расписание пусто, попробуйте выбрать другой день"
    
    tableView.tableFooterView = UIView(frame: .zero)
    
    infoIcon = UIImage(named: "info")
    infoIcon = infoIcon?.ofSize(VisualConfiguration.infoIconSize)
    
    let tableSectionHeaderNib = UINib(nibName: "TableSectionHeaderView", bundle: nil)
    tableView.registerNib(tableSectionHeaderNib, forHeaderFooterViewReuseIdentifier: headerId)
    
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
  
    if pets.count == 1 {
      // only one pet -> will use BasicPetCell
      tableView.rowHeight = 44.0
    } else {
      // will use ManyPetsCell
      tableView.rowHeight = 88.0
    }
    
    // find tasks which may be executed in a specified date
    possibleTasks = getPossibleTasks(fromPets: pets, forDate: date)
    
    if possibleTasks.count == 0 {
      showWarningMessage()
    } else {
      // find realizations of task's execution in a specified date
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
    
    if task.dateInTaskStartEndRange(date) {
      possibleTasks.append(task)
    }
    
    if possibleTasks.count != 0 {
      
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
  
  func showWarningMessage() {
    if tableView.hidden == false {
      tableView.hidden = true
    }
    if warningLabel.hidden == true {
      warningLabel.hidden = false
    }
  }
  
  // find task wich can be possibly executed in a specified date
  func getPossibleTasks(fromPets pets: [Pet], forDate date: NSDate) -> [Task] {
    var tasks: [Task] = []
    
    for pet in pets {
      for task in pet.tasks {
        
          
          if task.dateInTaskStartEndRange(date) {
            tasks.append(task)
          }
        }
      
    }
    
    return tasks
  }
  
  // find realizations of task' execution
  func getRealizations(fromTasks tasks: [Task], forDate date: NSDate) -> [Realization] {
    
    var realizations: [Realization] = []
    
    for task in tasks {
      if let realization = getRealization(fromRealizations: task.realizations, forDate: date) {
        // if task has already had a realization-list for a date
        realizations.append(realization)
      } else {
        
        // task hasn't had a realiation-list -> need to calculate it
        let done = task.getDone(forDate: date)
        
        let realization = Realization()
        realization.task = task
        realization.date = date
        realization.done = done
        
        if petsRepository.add(realization) {
          realizations.append(realization)
        }        
      }
    }
    return realizations
  }
  
  // find a realization for a specific date from realizations list
  func getRealization(fromRealizations realizations: LinkingObjects<Realization>, forDate date: NSDate) -> Realization? {
    for realization in realizations {
      if DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: realization.date) == .OrderedSame {
        return realization
      }
    }
    return nil
  }
  
  // create pairs (timeOfTask'sExecution, realization)
  func getTimeRealizations(fromRealizations realizations: [Realization]) -> [TimeRealization] {
    var timeRealizations: [TimeRealization] = []
    
    for realization in realizations {
      for time in 0..<realization.task!.timesPerDay {
        // -1 - время не актуально
        if realization.done[time] != -1 {
          timeRealizations.append((timeInDay: time, realization: realization))
        }
      }
    }
    
    return timeRealizations
  }
  
  // sort (time, realization) by time and pet's name
  func sortedByMinutesAndNameASC(lh: TimeRealization, rh: TimeRealization) -> Bool {
    if lh.realization.task!.minutesForTimes[lh.timeInDay] == rh.realization.task!.minutesForTimes[rh.timeInDay] {
      
      return lh.realization.task!.pet!.name.localizedStandardCompare(rh.realization.task!.pet!.name) == .OrderedAscending
    } else {
      
      var lhm = lh.realization.task!.minutesForTimes[lh.timeInDay]
      if minutesIsNight(lhm) {
        lhm += DateHelper.maxMinutes
      }
      
      var rhm = rh.realization.task!.minutesForTimes[rh.timeInDay]
      if minutesIsNight(rhm) {
        rhm += DateHelper.maxMinutes
      }
      
      return lhm < rhm
    }
  }
  
  func minutesIsNight(minutes: Int) -> Bool {
    if 0...299 ~= minutes || 1260...DateHelper.maxMinutes ~= minutes {
      return true
    } else {
      return false
    }
  }
  
  func calculateHeadersAndIndexes(ofTimeRealizations timeRealizations: [TimeRealization]) {
    let partOfTheDayNames = ["утро", "день", "вечер", "ночь"]
    var partOfTheDayAmount: [Int] = [0, 0, 0, 0]
    
    for tr in timeRealizations {
      switch tr.realization.task!.minutesForTimes[tr.timeInDay] {
      // morning (from 5 to 11.59)
      case 300...719:
        partOfTheDayAmount[0] += 1
      // day (from 12 to 16.59)
      case 720...1019:
        partOfTheDayAmount[1] += 1
      // evening (from 17 to 20.59)
      case 1020...1259:
        partOfTheDayAmount[2] += 1
      // night (from 21 to 4.59)
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
    if segue.identifier == taskMenuSegueId {
      if let task = sender as? Task, let destinationViewController = segue.destinationViewController as? TaskMenuViewController {
        destinationViewController.delegate = self
        destinationViewController.petsRepository = petsRepository
        destinationViewController.task = task
        destinationViewController.menuMode = .Show
        destinationViewController.hidesBottomBarWhenPushed = true
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
    
    if viewIsReadyToBeLoadedWithSchedule() {
      reloadScheduleTable()
    }
  }
  
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
    if pets.count == 1 { // only one pet in schedule
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
  
  // configure basic part of a cell, identical both for BasicPetCell and ManyPetsCell
  func configureBasicPetCell(cell: BasicPetCell, forRowAtIndexPath indexPath: NSIndexPath) {
    cell.tintColor = UIColor.lightGrayColor()
    
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    let minutes = tr.realization.task!.minutesForTimes[tr.timeInDay]
    let minutesString = DateHelper.minutesToString(minutes)
    cell.timeLabel.text = minutesString
    
    let iconName = tr.realization.task!.typeItem!.iconName
    cell.iconImageView.image = UIImage(named: iconName)
    
    if tr.realization.task!.name.isEmpty {
      cell.taskTitleLabel.text = tr.realization.task!.typeItem!.name
    } else {
      cell.taskTitleLabel.text = tr.realization.task!.name
    }
    
    cell.taskDetailLabel.text = tr.realization.task!.details(forTime: tr.timeInDay)
    
    if let infoIcon = infoIcon {
      let detailButton = UIButton(type: .Custom)
      detailButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: VisualConfiguration.infoIconSize)
      detailButton.setImage(withImage: infoIcon, ofSize: VisualConfiguration.infoIconSize, withTintColor: UIColor.blackColor())
      detailButton.addTarget(self, action: #selector(detailButtonTapped(_:)), forControlEvents: .TouchUpInside)
      
      cell.accessoryView = detailButton
    }
    
    configureCellDoneState(cell, forRowAtIndexPath: indexPath)
  }

  // determine, which cell contains tapped detail-button and call accessoryButtonTappedForRowWithIndexPath
  func detailButtonTapped(sender: UIButton) {
    let senderPoint = sender.convertPoint(CGPointZero, toView: tableView)
    if let indexPath = tableView.indexPathForRowAtPoint(senderPoint) {
      tableView(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
    }
  }
  
  // configure specific part of a ManyPetsCell
  func configureManyPetsCell(cell: ManyPetsCell, forRowAtIndexPath indexPath: NSIndexPath) {
    configureBasicPetCell(cell, forRowAtIndexPath: indexPath)
    
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    cell.petNameLabel.text = tr.realization.task!.pet!.name
    cell.petImageView.image = tr.realization.task!.pet!.image
  }
  
  func configureCellDoneState(cell: BasicPetCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    if tr.realization.done[tr.timeInDay] == 1 {
      // task is executed
      cell.selectView.hidden = false
      cell.timeLabel.hidden = true
      cell.checkmarkImageView.hidden = false
    } else {
      if tr.realization.done[tr.timeInDay] == 0 {
        // task must be executed but hasn't been yet
        cell.selectView.hidden = true
        cell.timeLabel.hidden = false
        cell.checkmarkImageView.hidden = true
      }
    }
  }
  
  func timeRealizationForRowAtIndexPath(indexPath: NSIndexPath) -> TimeRealization {
    var row = 0
    for ind in 0..<indexPath.section {
      row += indexesForHeader[ind]
    }
    row += indexPath.row
    
    return timeRealizations[row]
  }
  
  func indexPathForTimeRealization(timeRealization: TimeRealization) -> NSIndexPath? {
    
    if let index = timeRealizations.indexOf({$0.timeInDay == timeRealization.timeInDay && $0.realization == timeRealization.realization} ) {
      
      var section = 0
      var countInSections = 0
      repeat {
        countInSections += indexesForHeader[section]
        if index < countInSections {
          break
        }
        section += 1
      } while section < indexesForHeader.count
      
      let row = indexesForHeader[section] - 1 - (countInSections - 1 - index)
      return NSIndexPath(forRow: row, inSection: section)
      
    } else {
      return nil
    }
    
  }
  
  func indexPathsForTask(task: Task) -> [NSIndexPath] {
    let timeRealizationsForTask = timeRealizations.filter {$0.realization.task == task}
    
    var indexPaths = [NSIndexPath]()
    
    for timeRealization in timeRealizationsForTask {
      if let indexPath = indexPathForTimeRealization(timeRealization) {
        indexPaths.append(indexPath)
      }
    }
    
    return indexPaths
  }
  
}

extension ScheduleTableViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerId) as? TableSectionHeaderView {
      header.titleLabel.text = headerNames[section]
      header.view.backgroundColor = VisualConfiguration.lightOrangeColor
      return header
    } else {
      return nil
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let tr = timeRealizationForRowAtIndexPath(indexPath)
    
    if tr.realization.done[tr.timeInDay] == 0 {
      petsRepository.performChanges {
        tr.realization.done[tr.timeInDay] = 1
      }
    } else {
      if tr.realization.done[tr.timeInDay] == 1 {
        petsRepository.performChanges {
          tr.realization.done[tr.timeInDay] = 0
        }
      }
    }
    
    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BasicPetCell {
      configureCellDoneState(cell, forRowAtIndexPath: indexPath)
    }
  }
  
  func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    let timeRealization = timeRealizationForRowAtIndexPath(indexPath)
    let task = timeRealization.realization.task
    performSegueWithIdentifier(taskMenuSegueId, sender: task)
  }
  
}

extension ScheduleTableViewController: TaskMenuViewControllerDelegate {
  
  func taskMenuViewController(viewController: TaskMenuViewController, didDeleteTask task: Task) {
    timeRealizations = timeRealizations.filter { $0.realization.task != task } // delete timeRealizations of task, which is about to be deleted itself
    
    petsRepository.delete(task)
    
    // try to reload table
    prepareDataSourceAndReloadTable()
  }
  
  func taskMenuViewController(viewController: TaskMenuViewController, didSlightlyEditScheduleOfTask task: Task) {
    let indexPaths = indexPathsForTask(task) // get indices for rows of edited task
    tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    
    petsRepository.saveOrRollback() // save changes in task
  }
  
  func taskMenuViewController(viewController: TaskMenuViewController, didFullyEditScheduleOfTask task: Task) {
    timeRealizations = timeRealizations.filter { $0.realization.task != task } // delete outdated timeRealizations
    
    //let _ = task.realizations.map{petsRepository.deleteObject($0 as! NSManagedObject)}
    
    for realization in task.realizations {
      if let realization = realization as? Realization {
        //petsRepository.deleteObject(realization)
      }
    }
    //task.realizations = []
    
    petsRepository.saveOrRollback()
    
    updateScheduleTable(withTask: task)
  }
  
  func taskMenuViewController(viewController: TaskMenuViewController, didAddTask task: Task) { }
  
}