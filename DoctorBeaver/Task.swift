//
//  Task.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import CoreData


class Task: NSManagedObject {
  
  static var entityName: String {
    get {
      return "Task"
    }
  }
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(Task.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      realizations = []
    } else {
      return nil
    }
  }
  
  func configure(withTypeId typeId: Int) {
    self.typeId = typeId
    name = "Название"
    
    timesPerDay = 1
    minutesForTimes = [540] // 9 утра
    
    let tskCnfg = TaskConfigurationByType(task: self)
    doseForTimes = tskCnfg.doseForConfiguration()
    specialFeature = tskCnfg.specialFeatureForConfiguration()
    
//    startDate = NSDate()
//    frequency = []
//    
//    endDaysOrTimes = 0
//    endDate = startDate
    comment = ""
  }
  
  func copySettings(fromTask task: Task, withPet wPet: Bool = false) {
    typeId = task.typeId
    name = task.name
    
    timesPerDay = task.timesPerDay
    minutesForTimes = task.minutesForTimes
    doseForTimes = task.doseForTimes
    specialFeature = task.specialFeature
    
    startDate = task.startDate
    frequency = task.frequency
    
    endDaysOrTimes = task.endDaysOrTimes
    endDate = task.endDate
    comment = task.comment
    
    if wPet {
      pet = task.pet
    }
  }
  
  func settingsAreEqual(toTask task: Task) -> Bool {
    guard typeId == task.typeId else { return false }
    guard name == task.name else { return false }
    
    guard timesPerDay == task.timesPerDay else { return false }
    guard minutesForTimes == task.minutesForTimes else { return false }
    guard doseForTimes == task.doseForTimes else { return false }
    guard specialFeature == task.specialFeature else { return false }
    
    guard startDate == task.startDate else { return false }
    guard frequency == task.frequency else { return false }
    
    guard endDaysOrTimes == task.endDaysOrTimes else { return false }
    guard endDate == task.endDate else { return false }
    guard comment == task.comment else { return false }
    
    return true
  }
  
  func settingsMinutesAreEqual(toTask task: Task) -> Bool {
    return true
  }
  
  func settingsDoseAreEqual(toTask task: Task) -> Bool {
    return true
  }
  
  // корректируем расписание при изменении числа раз в день
  func correctMinutes() {
    var difference = timesPerDay - minutesForTimes.count
    
    if difference != 0 {
      
      var insertMinutes: Bool
      if difference > 0 {
        // необходимо вставить
        insertMinutes = true
      } else {
        // необходимо убрать лишние минуты
        insertMinutes = false
      }
      
      difference = abs(difference)
      for _ in 0..<difference {
        
        if insertMinutes {
          // вставляем минуты
          let gi = gapAtIndInMinutes(biggest: true)
          
          var newMinutes = minutesForTimes[gi.ind] + gi.gap / 2
          if newMinutes > DateHelper.maxMinutes {
            newMinutes = newMinutes % DateHelper.maxMinutes
          }
          
          var inserted = false
          for ind in 0..<minutesForTimes.count {
            if newMinutes < minutesForTimes[ind] {
              minutesForTimes.insert(newMinutes, atIndex: ind)
              inserted = true
              break
            }
          }
          
          if !inserted {
            minutesForTimes.append(newMinutes)
          }
          
        } else {
          // удаляем минуты
          let gi = gapAtIndInMinutes(biggest: false)
          
          if gi.ind + 1 < minutesForTimes.count {
            minutesForTimes.removeAtIndex(gi.ind + 1)
          } else {
            minutesForTimes.removeAtIndex(0)
          }
        }
        
      }
    }
  }
  
  // находим самый большой или самый маленький интервал в расписании
  func gapAtIndInMinutes(biggest biggest: Bool) -> (gap: Int, ind: Int) {
    
    var gap = 0
    var ind = 0
    
    if minutesForTimes.count == 1 {
      return (gap: DateHelper.maxMinutes, ind: 0)
    } else {
      var gaps: [Int] = []
      
      for tpd in 0..<minutesForTimes.count - 1 {
        gaps.append(minutesForTimes[tpd + 1] - minutesForTimes[tpd])
      }
      
      let totalGaps = gaps.reduce(0, combine: { $0 + $1 })
      if totalGaps < DateHelper.maxMinutes {
        gaps.append(DateHelper.maxMinutes - totalGaps)
      }
      
      
      if biggest {
        if let gmax = gaps.maxElement() {
          gap = gmax
          if let imax = gaps.indexOf(gmax) {
            ind = imax
          }
        }
      } else {
        if let gmin = gaps.minElement() {
          gap = gmin
          if let imin = gaps.indexOf(gmin) {
            ind = imin
          }
        }
      }
    }
    
    return (gap: gap, ind: ind)
  }
  
  // корректируем дозировку при изменении числа раз в день
  func correctDose() {
    guard doseForTimes.count != 0 else { return }
    
    var difference = timesPerDay - doseForTimes.count
    if difference != 0 {
      
      var insertDose: Bool
      if difference > 0 {
        // необходимо вставить
        insertDose = true
      } else {
        // необходимо убрать лишние дозировки
        insertDose = false
      }
      
      difference = abs(difference)
      if insertDose {
        if allDosesAreEqual() {
          for _ in 0..<difference {
            doseForTimes.append(doseForTimes[0])
          }
        } else {
          for ind in 0..<difference {
            doseForTimes.append(doseForTimes[ind])
          }
        }
        
      } else {
        for _ in 0..<difference {
          doseForTimes.removeLast()
        }
      }
    } 
  }
  
  // устанавливаем единые дозировки
  func setAllDosesEqual() {
    let dose = doseForTimes[0]
    
    for ind in 1..<timesPerDay {
      if doseForTimes[ind] != dose {
        doseForTimes[ind] = dose
      }
    }
  }
  
  // проверяем, все ли дозы одинаковые
  func allDosesAreEqual() -> Bool {
    guard doseForTimes.count != 0 else { return true }
    
    if doseForTimes.count == 1 {
      return true
    } else {
      for ind in 0..<doseForTimes.count - 1 {
        if doseForTimes[ind] != doseForTimes[ind + 1] {
          return false
        }
      }
    }
    return true
  }
  
  // детали выполнения задания
  func details(forTime time: Int) -> String {
    let dsPrnt = dosePrintable(forTime: time)
    if !dsPrnt.isEmpty {
      return "\(dosePrintable(forTime: time)) \(type.doseUnit()) \(specialFeature)"
    } else {
      return "\(specialFeature)"
    }
  }
  
  // дозировка в читабельном виде
  func dosePrintable(forTime time: Int) -> String {
    switch type {
    case .Pill:
      
      var dp = doseForTimes[time]
      
      if let char = dp.characters.first {
        if char == doseSeparator {
          dp = String(dp.characters.dropFirst())
        }
      }
      
      if let char = dp.characters.last {
        if char == doseSeparator {
          dp = String(dp.characters.dropLast())
        }
      }
      
      dp = dp.stringByReplacingOccurrencesOfString(String(doseSeparator), withString: " ")
      return dp
      
    case .Injection:
      var sum: Double = 0
      var dp = ""
      
      let dose = doseForTimes[time] + String(doseSeparator)
      for s in dose.characters {
        if s != doseSeparator {
          dp += String(s)
        } else {
          if let m = Double(dp) {
            sum += m
          }
          dp = ""
        }
      }
      
      return String(sum)
      
    case .Drops, .Mixture:
      return doseForTimes[time]
      
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  
  // печатаем блоком
  func printInBlock() {
    print("   TASK of \(pet.name)")
    print("   name: \(name)")
    print("   type: \(type.toString())")
    print("   timesPerDay: \(timesPerDay)")
    
    var s: String = ""
    for mft in minutesForTimes {
      s += " "
      
      let h = mft / 60
      if h < 10 {
        s += "0"
      }
      s += "\(h):"
      
      let m = mft % 60
      if m < 10 {
        s += "0"
      }
      s += "\(m)"
    }
    print("   minutesForTimes: [" + s + " ]")
    
    s = ""
    for dft in doseForTimes {
      s += " \(dft)"
    }
    print("   doseForTimes: [" + s + " ]")
    print("   specialFeature: \(specialFeature)")
    print("   startDate: \(VisualConfiguration.stringFromDate(startDate))")
    
    s = ""
    for f in frequency {
      s += " \(f)"
    }
    print("   frequency: [" + s + " ]")
    
    if endDaysOrTimes < 0 {
      print("   endDays: \(-endDaysOrTimes)")
    } else {
      if endDaysOrTimes > 0 {
        print("   endTimes: \(endDaysOrTimes)")
      }
    }
    
    print("   endDate: \(VisualConfiguration.stringFromDate(endDate))")
    
    if comment.isEmpty {
      print("   comment: #")
    } else {
      print("   comment: \(comment)")
    }
    
    for r in realizations {
      if let r = r as? Realization {
        r.printInBlock()
      }
    }
    
    print("")
  }
  
  // тип задания
  var type: TaskType {
    get {
      if let t = TaskType(rawValue: typeId) {
        return t
      } else {
        return .Error
      }
    }
  }
  
  // разделитель для дозировки
  let doseSeparator: Character = ";"

///
  
  enum EndType: Int {
    case EndDate = 2
    case EndDays = 0
    case EndTimes = 1
  }
  
  
  
  var endType: EndType {
    get {
      if endDaysOrTimes == 0 {
        return .EndDate
      } else {
        if endDaysOrTimes < 0 {
          return .EndDays
        } else {
          return .EndTimes
        }
      }
    }
  }
///
  
  // подсчитать конечную дату, если задано число дней или число раз
  func countEndDate() {
    if endDaysOrTimes < 0 {
      endDate = countEndDate(withEndDays: -endDaysOrTimes)
    } else {
      if endDaysOrTimes > 0 {
        endDate = countEndDate(withEndTimes: endDaysOrTimes)
      }
    }
  }
  
  // подсчитать конечную дату, если задано число дней
  func countEndDate(withEndDays ed: Int) -> NSDate {
    if let date = VisualConfiguration.calendar.dateByAddingUnit(.Day, value: ed, toDate: startDate, options: []) {
      if let dateMinMin = VisualConfiguration.calendar.dateByAddingUnit(.Minute, value: -1, toDate: date, options: []) {
        return dateMinMin
      } else {
        return startDate
      }
    } else {
      return startDate
    }
  }
  
  // подсчитать конечную дату, если задано число раз
  func countEndDate(withEndTimes endTimes: Int) -> NSDate {
    
    var date = startDate
    
    let fullDays = (endTimes - 1) / timesPerDay
    
    if fullDays > 0 {
      // прибавляем количество целых дней
      if frequency.count == 0 {
        // задание нужно выполнять ежедневно
        if let fullDaysDate = VisualConfiguration.calendar.dateByAddingUnit(.Day, value: fullDays, toDate: date, options: []) {
          date = fullDaysDate
        }
      } else {
        // задана периодичность
        
        let activeDays = frequency[0]
        let passiveDays = frequency[1]
        
        let fullBlocks = fullDays / activeDays
        if fullBlocks > 0 {
          if let nextDate = VisualConfiguration.calendar.dateByAddingUnit(.Day, value: fullBlocks * (activeDays + passiveDays), toDate: date, options: []) {
            date = nextDate
          }
        }
        
        let blocks = fullDays % activeDays
        if let nextDate = VisualConfiguration.calendar.dateByAddingUnit(.Day, value: blocks, toDate: date, options: []) {
          date = nextDate
        }
      }
    }
    
    // реорганизованное расписание приема
    var arrangedMFT = arrangeMinutesForTimes(byMinutesOfDate: date)
    
    let timesOfPartialDay = (endTimes - 1) % timesPerDay
    date = getDateForNextRealization(atMinutes: arrangedMFT[timesOfPartialDay], forDate: date)
    
    return date
  }
  
  // реорганизовать расписание приема, чтобы оно начиналось со времени переданной даты
  func arrangeMinutesForTimes(byMinutesOfDate date: NSDate) -> [Int] {
    
    if timesPerDay <= 1 {
      return minutesForTimes
    }
    
    var arrangedMFT: [Int] = []
    let minutes = DateHelper.getMinutes(fromDate: date)
    
    if minutes <= minutesForTimes[0] || minutesForTimes[timesPerDay - 1] < minutes {
      return minutesForTimes
    } else {
      
      var indToDivide = 0
      
      for i in 0..<minutesForTimes.count {
        if minutesForTimes[i] >= minutes {
          indToDivide = i
          break
        }
      }
      
      let pref = minutesForTimes.prefixUpTo(indToDivide)
      let suff = minutesForTimes.suffixFrom(indToDivide)
      arrangedMFT = Array (suff) + Array(pref)
      
      return arrangedMFT
    }
  }
  
  // вычисляем новую дату, комбинируя старую и новое время
  func getDateForNextRealization(atMinutes minutes: Int, forDate date: NSDate) -> NSDate {
    
    let components = NSDateComponents()
    components.year = VisualConfiguration.calendar.component(.Year, fromDate: date)
    components.month = VisualConfiguration.calendar.component(.Month, fromDate: date)
    components.day = VisualConfiguration.calendar.component(.Day, fromDate: date)
    components.hour = minutes / 60
    components.minute = minutes % 60
    
    var nextRealizationDate = date
    if let nrd = VisualConfiguration.calendar.dateFromComponents(components) {
      nextRealizationDate = nrd
    }
    
    let dateMinutes = DateHelper.getMinutes(fromDate: date)
    if dateMinutes > minutes {
      // следующий день
      if let nrd = VisualConfiguration.calendar.dateByAddingUnit(.Day, value: 1, toDate: nextRealizationDate, options: []) {
        nextRealizationDate = nrd
      }
    }
    
    return nextRealizationDate
  }
  
  // выясняем, распологается ли дата между датами начала и конца
  func dateInTaskStartEndRange(date: NSDate) -> Bool {
    if DateHelper.compareDatesToDayUnit(firstDate: startDate, secondDate: date) != .OrderedDescending && DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) != .OrderedDescending {
      return true
    } else {
      return false
    }
  }
  
  // список выполненности задания на конкретную дату
  func getDone(forDate date: NSDate) -> [Int] {
    
    //self.printInBlock()
    
    let transition = getDateTransitionType(forDate: date)
    
    var done: [Int] = []
    for _ in 0..<timesPerDay {
      done.append(-1)
    }
    
    var sMinutes: Int
    var eMinutes: Int
    
    let mMin = 0
    let mMax = 1440
    
    switch transition {
    case .PassToPass:
      return done
      
    case .ActToAct:
      sMinutes = mMin
      
      if DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) == .OrderedSame {
        eMinutes = DateHelper.getMinutes(fromDate: endDate)
      } else {
        eMinutes = mMax
      }
      
    case .PassToAct:
      sMinutes = DateHelper.getMinutes(fromDate: startDate)
      
      if DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) == .OrderedSame {
        eMinutes = DateHelper.getMinutes(fromDate: endDate)
      } else {
        eMinutes = mMax
      }
      
    case .ActToPass:
      sMinutes = mMin
      
      if DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) == .OrderedSame {
        eMinutes = DateHelper.getMinutes(fromDate: endDate)
      } else {
        eMinutes = DateHelper.getMinutes(fromDate: startDate) - 1
      }
      
    }
    
    for ind in 0..<timesPerDay {
      if sMinutes <= minutesForTimes[ind] && minutesForTimes[ind] <= eMinutes {
        done[ind] = 0
      }
    }
    
    return done
  }
  
  // тип перехода даты
  enum DayTransitionType {
    // переход от неактивной даты к активной
    case PassToAct
    // череда активных дат
    case ActToAct
    // череда неактивных дат
    case PassToPass
    // переход от неактивной даты к активной
    case ActToPass
  }
  
  // получить тип перехода по дате
  func getDateTransitionType(forDate date: NSDate) -> DayTransitionType {
    
    let firstDay = DateHelper.compareDatesToDayUnit(firstDate: startDate, secondDate: date) == .OrderedSame
    let lastDay = DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) == .OrderedSame
    
    if firstDay {
      // дата - первый день
      return .PassToAct
    } else {
      
      if frequency.count == 0 {
        // дата - среди активных дат
        
        if lastDay {
          // дата - последний день
          return .ActToPass
        } else {
          // дата - среди последовательности активных дат
          return .ActToAct
        }
        
      } else {
        // дата - среди череды активных и неактивных дат
        
        let dayDifference = DateHelper.calendarDayDifference(fromDate: startDate, toDate: date)
        
        let activeDays = frequency[0]
        let passiveDays = frequency[1]
        
        let dayInBlock = dayDifference % (activeDays + passiveDays)
        
        
        if 0 <= dayInBlock && dayInBlock <= (activeDays - 1) {
          
          if dayInBlock == 0 {
            // переход от неактивного к активному
            return .PassToAct
            
          } else {
            // среди активных
            return .ActToAct
          }
          
        } else {
          
          if dayInBlock == activeDays {
            // переход от активного к неактивному
            return .ActToPass
          } else {
            // среди неактивных
            return .PassToPass
          }
          
        }
        
      }
    }
  }
  
//  func printRealizations() {
//    
////    print("startDate: \(VisualConfiguration.stringFromDate(startDate))")
////    print("endDate: \(VisualConfiguration.stringFromDate(endDate))")
////    print("")
////    
////    let dateFormatter = NSDateFormatter()
////    dateFormatter.dateFormat = "d.MM.y"
////    dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
////    
////    var date = startDate
////    
////    repeat {
////      
////      let ds = dateFormatter.stringFromDate(date)
////      
////      
////      //print(VisualConfiguration.stringFromDate(date))
////      
////      let done = getDone(forDate: date)
////      
////      var dd = ""
////      
////      for ind in 0..<done.count {
////        if let d = done[ind] {
////          let mts = VisualConfiguration.minutesToString(minutesForTimes[ind])
////          dd += mts + " "
////          
////        }
////      }
////      
////      print("\(ds) \(dd)")
////      date = VisualConfiguration.calendar.dateByAddingUnit(.Day, value: 1, toDate: date, options: [])!
////      
////    } while compareDateToDayUnit(firstDate: endDate, secondDate: date) != .OrderedAscending
//    
//    
//  }
  
  
  ////
  
  

}
