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
  
  // endDate can be set specifically or calculated from startDate by adding some days or times
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
  
  convenience init?(insertIntoManagedObjectContext managedContext: NSManagedObjectContext!) {
    if let entity = NSEntityDescription.entityForName(Task.entityName, inManagedObjectContext: managedContext) {
      self.init(entity: entity, insertIntoManagedObjectContext: managedContext)
      realizations = []
    } else {
      return nil
    }
  }
  
  func configure(withTypeItem typeItem: TaskTypeItem) {
    self.typeItem = typeItem
    
    name = ""
    typeId = typeItem.id
    
    timesPerDay = typeItem.timesPerDayForInitialization
    minutesForTimes = [typeItem.minutesForTimesForInitialization]
    doseForTimes = [typeItem.doseForTimesForInitialization]
    specialFeature = typeItem.specialFeatureForInitialization

    startDate = NSDate()
    frequency = []
    endDaysOrTimes = 0
    endDate = startDate
    
    comment = ""
  }
  
  var doseUnit: String {
    get {
      return typeItem.doseUnit
    }
  }
  
  var namePlaceholder: String {
    get {
      return typeItem.basicValues.taskNamePlaceholder
    }
  }
  
  var separator: Character {
    get {
      return typeItem.basicValues.separator.characters.first ?? " "
    }
  }
  
  var sectionTitles: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: typeItem.sectionTitles, withSeparator: separator)
    }
  }
  
  var timesPerDayTitle: String {
    get {
      return typeItem.timesPerDayTitle
    }
  }
  var timesPerDayOptions: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: typeItem.timesPerDayOptions, withSeparator: separator)
    }
  }
  
  var minutesForTimesTitle: String {
    get {
      return typeItem.minutesForTimesTitle
    }
  }
  var minutesForTimesOrderTitles: [String] {
    get {
      let allOrderTitles = getTwoDimArrayOfStrings(fromUnseparatedString: typeItem.minutesForTimesOrderTitles, withSeparator: separator)
      return timesPerDay == 1 ? allOrderTitles[0] : allOrderTitles[1]
    }
  }
  
  var doseForTimesTitle: String {
    get {
      return typeItem.doseForTimesTitle
    }
  }
  var doseForTimesOrderTitles: [String] {
    get {
      let allOrderTitles = getTwoDimArrayOfStrings(fromUnseparatedString: typeItem.doseForTimesOrderTitles, withSeparator: separator)
      return timesPerDay == 1 ? allOrderTitles[0] : allOrderTitles[1]
    }
  }
  var doseForTimesOptions: [[String]] {
    get {
      return getTwoDimArrayOfStrings(fromUnseparatedString: typeItem.doseForTimesOptions, withSeparator: separator)
    }
  }
  var doseForTimesForInitialization: String {
    get {
      return typeItem.doseForTimesForInitialization
    }
  }
  
  func dosePrintable(forTime time: Int) -> String {
    guard time < doseForTimes.count else { return "" }
    
    let whitespace = " "
    let stringDoses = getOneDimArrayOfStrings(fromUnseparatedString: doseForTimes[time], withSeparator: separator).filter{$0 != whitespace}
    let numberDoses = stringDoses.map{ Double($0) }.flatMap{ $0 }
    
    if numberDoses.count == stringDoses.count {
      let sumDoses = numberDoses.reduce(0, combine: { $0 + $1 })
      if sumDoses % 1 == 0 { // no need to show decimal part, which is zero
        return String(Int(sumDoses))
      } else {
        return String(sumDoses)
      }
    } else {
      return stringDoses.reduce("", combine: { $0 == "" ? $1 : $0 + whitespace + $1 })
    }
  }
  
  func doseAsArrayOfStrings(forTime time: Int) -> [String] {
    guard time < doseForTimes.count else { return [] }
    return getOneDimArrayOfStrings(fromUnseparatedString: doseForTimes[time], withSeparator: separator)
  }
  
  func doseFromArrayOfStrings(arrayOfStrings: [String]) -> String {
    return arrayOfStrings.reduce("", combine: { $0 == "" ? $1 : $0 + String(separator) + $1 })
  }
  
  var specialFeatureTitle: String {
    get {
      return typeItem.specialFeatureTitle
    }
  }
  var specialFeatureOptions: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: typeItem.specialFeatureOptions, withSeparator: separator)
    }
  }
  
  var startDateTitle: String {
    get {
      return typeItem.basicValues.startDateTitle
    }
  }
  
  var frequencyTitle: String {
    get {
      return typeItem.frequencyTitle
    }
  }
  var frequencySegmentTitles: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: typeItem.frequencySegmentTitles, withSeparator: separator)
    }
  }
  var frequencyOptions: [[String]] {
    get {
      
      guard !frequencyTitle.isEmpty else { return [] }
      
      let daysOptions = getOneDimArrayOfStrings(fromUnseparatedString: typeItem.basicValues.daysOptions, withSeparator: separator)
      let daysOptionsWithPrepos = daysOptions.map { typeItem.frequencyPreposition + " " + $0 }
      return [daysOptions, daysOptionsWithPrepos]
    }
  }
  
  var endDaysOrTimesTitle: String {
    get {
      return typeItem.basicValues.endDaysOrTimesTitle
    }
  }
  var endDaysOrTimesSegmentTitles: [String] {
    get {
      return getOneDimArrayOfStrings(fromUnseparatedString: typeItem.basicValues.endDaysOrTimesSegmentTitles, withSeparator: separator)
    }
  }
  
  func endDaysOrTimesOptions(byNewEndType newEndType: Task.EndType? = nil) -> [String] {
    var endType: EndType
    
    if let newEndType = newEndType {
      endType = newEndType
    } else {
      endType = self.endType
    }
    
    var stringOptions = ""
    if endType == .EndDays {
      stringOptions = typeItem.basicValues.daysOptions
    } else if endType == .EndTimes {
      stringOptions = typeItem.basicValues.timesOptions
    }
    
    let options = getOneDimArrayOfStrings(fromUnseparatedString: stringOptions, withSeparator: separator).map { typeItem.basicValues.endDaysOrTimesOptionsPreposition + " " + $0 }
    return options
  }
  
  var commentPlaceholder: String {
    get {
      return typeItem.basicValues.commentPlaceholder
    }
  }
  
  
  
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
    if let date = DateHelper.calendar.dateByAddingUnit(.Day, value: ed, toDate: startDate, options: []) {
      if let dateMinMin = DateHelper.calendar.dateByAddingUnit(.Minute, value: -1, toDate: date, options: []) {
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
        if let fullDaysDate = DateHelper.calendar.dateByAddingUnit(.Day, value: fullDays, toDate: date, options: []) {
          date = fullDaysDate
        }
      } else {
        // задана периодичность
        
        let activeDays = frequency[0]
        let passiveDays = frequency[1]
        
        let fullBlocks = fullDays / activeDays
        if fullBlocks > 0 {
          if let nextDate = DateHelper.calendar.dateByAddingUnit(.Day, value: fullBlocks * (activeDays + passiveDays), toDate: date, options: []) {
            date = nextDate
          }
        }
        
        let blocks = fullDays % activeDays
        if let nextDate = DateHelper.calendar.dateByAddingUnit(.Day, value: blocks, toDate: date, options: []) {
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
    components.year = DateHelper.calendar.component(.Year, fromDate: date)
    components.month = DateHelper.calendar.component(.Month, fromDate: date)
    components.day = DateHelper.calendar.component(.Day, fromDate: date)
    components.hour = minutes / 60
    components.minute = minutes % 60
    
    var nextRealizationDate = date
    if let nrd = DateHelper.calendar.dateFromComponents(components) {
      nextRealizationDate = nrd
    }
    
    let dateMinutes = DateHelper.getMinutes(fromDate: date)
    if dateMinutes > minutes {
      // следующий день
      if let nrd = DateHelper.calendar.dateByAddingUnit(.Day, value: 1, toDate: nextRealizationDate, options: []) {
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
  
  // копируем настройки
  func copySettings(fromTask task: Task, withPet wPet: Bool = false) {
    name = task.name
    typeId = task.typeId
    typeItem = task.typeItem
    
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
  
  // эквавалентны ли настройки двух заданий
  func settingsAreEqual(toTask task: Task) -> Bool {
    guard name == task.name else { return false }
    guard typeId == task.typeId else { return false }
    
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
  
  // детали выполнения задания в читабельном виде
  func details(forTime time: Int) -> String {
    let dsPrnt = dosePrintable(forTime: time)
    if !dsPrnt.isEmpty {
      return "\(dosePrintable(forTime: time)) \(doseUnit) \(specialFeature)"
    } else {
      return "\(specialFeature)"
    }
  }
  
  func getOneDimArrayOfStrings(fromUnseparatedString string: String, withSeparator separator: Character) -> [String] {
    let oneDimArray = string.characters.split(separator, maxSplit: string.characters.count, allowEmptySlices: false).map{String($0)}
    return oneDimArray
  }
  
  func getTwoDimArrayOfStrings(fromUnseparatedString string: String, withSeparator separator: Character) -> [[String]] {
    
    let twoDimSeparator = String(separator) + String(separator)
    var twoDimArray = [[String]]()
    
    let twoDimStringElements = string.componentsSeparatedByString(twoDimSeparator)
    for twoDimStringElement in twoDimStringElements {
      twoDimArray.append(getOneDimArrayOfStrings(fromUnseparatedString: twoDimStringElement, withSeparator: separator))
    }
    //return twoDimArray
    return (twoDimArray.filter{ !$0.isEmpty }).isEmpty ? [] : twoDimArray
  }
  
  
  
  
/////////////
  
  
  

  
}
