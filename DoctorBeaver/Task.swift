//
//  Task.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import RealmSwift

class IntObject: Object {
  dynamic var value = 0
  
  convenience init(_ intValue: Int) {
    self.init()
    self.value = intValue
  }
}

class RealmIntArray: Object {
  let list = List<IntObject>()
  
  func updateWith(array: [Int]) {
    list.removeAll()
    for value in array {
      list.append(IntObject(value))
    }
  }
  
  func toArray() -> [Int] {
    var array = [Int]()
    for ind in 0..<list.count {
      array.append(list[ind].value)
    }
    return array
  }
}

class StringObject: Object {
  dynamic var value = ""
  
  convenience init(_ strValue: String) {
    self.init()
    self.value = strValue
  }
}

class RealmStringArray: Object {
  let list = List<StringObject>()
  
  func updateWith(array: [String]) {
    list.removeAll()
    for value in array {
      list.append(StringObject(value))
    }
  }
  
  func toArray() -> [String] {
    var array = [String]()
    for ind in 0..<list.count {
      array.append(list[ind].value)
    }
    return array
  }
}

class Task: Object, CascadeDeletable {
  dynamic var pet: Pet?
  
  dynamic var name = ""
  dynamic var typeId = 0
  dynamic var typeItem: TaskTypeItem?
  
  dynamic var timesPerDay = 0
  private dynamic var minutesForTimes_: RealmIntArray?
  var minutesForTimes: [Int] {
    get {
      if let minutesForTimes_ = minutesForTimes_ {
        return minutesForTimes_.toArray()
      } else { return [] }
    }
    set {
      if minutesForTimes_ == nil {
        minutesForTimes_ = RealmIntArray()
      }
      minutesForTimes_?.updateWith(newValue)
    }
  }
  
  private dynamic var doseForTimes_: RealmStringArray?
  var doseForTimes: [String] {
    get {
      if let doseForTimes_ = doseForTimes_ {
        return doseForTimes_.toArray()
      } else { return [] }
    }
    set {
      if doseForTimes_ == nil {
        doseForTimes_ = RealmStringArray()
      }
      doseForTimes_?.updateWith(newValue)
    }
  }
  
  dynamic var specialFeature = ""
  
  dynamic var startDate = NSDate()
  
  private dynamic var frequency_: RealmIntArray?
  var frequency: [Int] {
    get {
      if let frequency_ = frequency_ {
        return frequency_.toArray()
      } else { return [] }
    }
    set {
      if frequency_ == nil {
        frequency_ = RealmIntArray()
      }
      frequency_?.updateWith(newValue)
    }
  }
  
  dynamic var endDaysOrTimes = 0
  dynamic var endDate = NSDate()
  dynamic var comment = ""
  
  let realizations = LinkingObjects(fromType: Realization.self, property: "task")
  
  // CascadeDeletable
  var linkedObjectsToDelete: [Object] {
    var objects = [Object]()
    for realization in realizations {
      objects.append(realization)
    }
    return objects
  }
  
  override static func ignoredProperties() -> [String] {
    return ["minutesForTimes", "doseForTimes", "frequency"]
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
  
  
  func configure(withTypeItem typeItem: TaskTypeItem) {
    self.typeItem = typeItem
    
    name = typeItem.name
    typeId = typeItem.id
    
    timesPerDay = typeItem.timesPerDayForInitialization
    minutesForTimes = [typeItem.minutesForTimesForInitialization]
    doseForTimes = [typeItem.doseForTimesForInitialization]
    specialFeature = typeItem.specialFeatureForInitialization
    
    startDate = NSDate()
    frequency = []
    endDaysOrTimes = 0
    
    if let nextDay = DateHelper.calendar.dateByAddingUnit(.Day, value: 1, toDate: startDate, options: []) {
      endDate = nextDay
    } else {
      endDate = startDate
    }
    
    comment = ""
  }
  
  var doseUnit: String {
    get {
      return typeItem!.doseUnit
    }
  }
  
  var namePlaceholder: String {
    get {
      return typeItem!.basicValues!.taskNamePlaceholder
    }
  }
  
  var separator: Character {
    get {
      return typeItem!.basicValues!.separator.characters.first ?? " "
    }
  }
  
  var sectionTitles: [String] {
    get {
      return String.getOneDimArrayOfStrings(fromUnseparatedString: typeItem!.sectionTitles, withSeparator: separator)
    }
  }
  
  var timesPerDayTitle: String {
    get {
      return typeItem!.timesPerDayTitle
    }
  }
  var timesPerDayOptions: [String] {
    get {
      return String.getOneDimArrayOfStrings(fromUnseparatedString: typeItem!.timesPerDayOptions, withSeparator: separator)
    }
  }
  
  var minutesForTimesTitle: String {
    get {
      return typeItem!.minutesForTimesTitle
    }
  }
  var minutesForTimesOrderTitles: [String] {
    get {
      let allOrderTitles = String.getTwoDimArrayOfStrings(fromUnseparatedString: typeItem!.minutesForTimesOrderTitles, withSeparator: separator)
      return timesPerDay == 1 ? allOrderTitles[0] : allOrderTitles[1]
    }
  }
  
  var doseForTimesTitle: String {
    get {
      return typeItem!.doseForTimesTitle
    }
  }
  var doseForTimesOrderTitles: [String] {
    get {
      let allOrderTitles = String.getTwoDimArrayOfStrings(fromUnseparatedString: typeItem!.doseForTimesOrderTitles, withSeparator: separator)
      return timesPerDay == 1 ? allOrderTitles[0] : allOrderTitles[1]
    }
  }
  var doseForTimesOptions: [[String]] {
    get {
      return String.getTwoDimArrayOfStrings(fromUnseparatedString: typeItem!.doseForTimesOptions, withSeparator: separator)
    }
  }
  var doseForTimesForInitialization: String {
    get {
      return typeItem!.doseForTimesForInitialization
    }
  }
  var doseForTimesEqualTitle: String {
    get {
      return typeItem!.doseForTimesEqualTitle
    }
  }
  
  func dosePrintable(forTime time: Int) -> String {
    guard time < doseForTimes.count else { return "" }
    
    let whitespace = " "
    let stringDoses = String.getOneDimArrayOfStrings(fromUnseparatedString: doseForTimes[time], withSeparator: separator).filter{$0 != whitespace}
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
    return String.getOneDimArrayOfStrings(fromUnseparatedString: doseForTimes[time], withSeparator: separator)
  }
  
  func doseFromArrayOfStrings(arrayOfStrings: [String]) -> String {
    return arrayOfStrings.reduce("", combine: { $0 == "" ? $1 : $0 + String(separator) + $1 })
  }
  
  var specialFeatureTitle: String {
    get {
      return typeItem!.specialFeatureTitle
    }
  }
  var specialFeatureOptions: [String] {
    get {
      return String.getOneDimArrayOfStrings(fromUnseparatedString: typeItem!.specialFeatureOptions, withSeparator: separator)
    }
  }
  
  var startDateTitle: String {
    get {
      return typeItem!.basicValues!.startDateTitle
    }
  }
  
  var frequencyTitle: String {
    get {
      return typeItem!.frequencyTitle
    }
  }
  var frequencySegmentTitles: [String] {
    get {
      return String.getOneDimArrayOfStrings(fromUnseparatedString: typeItem!.frequencySegmentTitles, withSeparator: separator)
    }
  }
  var frequencyOptions: [[String]] {
    get {
      
      guard !frequencyTitle.isEmpty else { return [] }
      
      let daysOptions = String.getOneDimArrayOfStrings(fromUnseparatedString: typeItem!.basicValues!.daysOptions, withSeparator: separator)
      let daysOptionsWithPrepos = daysOptions.map { typeItem!.frequencyPreposition + " " + $0 }
      return [daysOptions, daysOptionsWithPrepos]
    }
  }
  
  var endDaysOrTimesTitle: String {
    get {
      return typeItem!.basicValues!.endDaysOrTimesTitle
    }
  }
  var endDaysOrTimesSegmentTitles: [String] {
    get {
      return String.getOneDimArrayOfStrings(fromUnseparatedString: typeItem!.basicValues!.endDaysOrTimesSegmentTitles, withSeparator: separator)
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
      stringOptions = typeItem!.basicValues!.daysOptions
    } else if endType == .EndTimes {
      stringOptions = typeItem!.basicValues!.timesOptions
    }
    
    let options = String.getOneDimArrayOfStrings(fromUnseparatedString: stringOptions, withSeparator: separator).map { typeItem!.basicValues!.endDaysOrTimesOptionsPreposition + " " + $0 }
    return options
  }
  
  var commentPlaceholder: String {
    get {
      return typeItem!.basicValues!.commentPlaceholder
    }
  }
  
  // MARK: methods
  
  // count endDate if endDays or endTimes was set
  func countEndDate() {
    if endDaysOrTimes < 0 {
      endDate = countEndDate(withEndDays: -endDaysOrTimes)
    } else {
      if endDaysOrTimes > 0 {
        endDate = countEndDate(withEndTimes: endDaysOrTimes)
      }
    }
  }
  
  // count endDate if endDays was set
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
  
  // count endDate if endTimes was set
  func countEndDate(withEndTimes endTimes: Int) -> NSDate {
    
    var date = startDate
    
    let fullDays = (endTimes - 1) / timesPerDay
    
    if fullDays > 0 {
      // add amount of fullDays
      if frequency.count == 0 {
        // task must be performed everyday
        if let fullDaysDate = DateHelper.calendar.dateByAddingUnit(.Day, value: fullDays, toDate: date, options: []) {
          date = fullDaysDate
        }
      } else {
        
        // task must be performed periodically
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
    
    // reorganize task's schedule
    var arrangedMFT = arrangeMinutesForTimes(byMinutesOfDate: date)
    
    let timesOfPartialDay = (endTimes - 1) % timesPerDay
    date = getDateForNextRealization(atMinutes: arrangedMFT[timesOfPartialDay], forDate: date)
    
    return date
  }
  
  // reorganize task's schedule to begin with specified date
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
  
  // calculate new date, by combining the old one and new time
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
      // next day
      if let nrd = DateHelper.calendar.dateByAddingUnit(.Day, value: 1, toDate: nextRealizationDate, options: []) {
        nextRealizationDate = nrd
      }
    }
    
    return nextRealizationDate
  }
  
  func dateInTaskStartEndRange(date: NSDate) -> Bool {
    if DateHelper.compareDatesToDayUnit(firstDate: startDate, secondDate: date) != .OrderedDescending && DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) != .OrderedDescending {
      return true
    } else {
      return false
    }
  }
  
  // list of task's fulfillment on a concrete date
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
  
  enum DayTransitionType {
    // transition from inactive date to active
    case PassToAct
    // sequence of active dates
    case ActToAct
    // sequence of inactive dates
    case PassToPass
    // transition from active date to inactive
    case ActToPass
  }
  
  func getDateTransitionType(forDate date: NSDate) -> DayTransitionType {
    
    let firstDay = DateHelper.compareDatesToDayUnit(firstDate: startDate, secondDate: date) == .OrderedSame
    let lastDay = DateHelper.compareDatesToDayUnit(firstDate: date, secondDate: endDate) == .OrderedSame
    
    if firstDay {
      // date is the first day
      return .PassToAct
    } else {
      
      if frequency.count == 0 {
        // date is in a sequence of active dates
        if lastDay {
          // date is the last day
          return .ActToPass
        } else {
          // date is in a sequence of active dates
          return .ActToAct
        }
        
      } else {
        // date is in a sequence of transitions from active date to inactive
        
        let dayDifference = DateHelper.calendarDayDifference(fromDate: startDate, toDate: date)
        
        let activeDays = frequency[0]
        let passiveDays = frequency[1]
        
        let dayInBlock = dayDifference % (activeDays + passiveDays)
        
        
        if 0 <= dayInBlock && dayInBlock <= (activeDays - 1) {
          
          if dayInBlock == 0 {
            return .PassToAct
            
          } else {
            return .ActToAct
          }
          
        } else {
          
          if dayInBlock == activeDays {
            return .ActToPass
          } else {
            return .PassToPass
          }
          
        }
        
      }
    }
  }
  
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
  
  func allSettingsAreEqual(toTask task: Task) -> Bool {
    guard name == task.name else { return false }
    guard typeId == task.typeId else { return false }
    guard specialFeature == task.specialFeature else { return false }
    guard doseForTimes == task.doseForTimes else { return false }
    guard comment == task.comment else { return false }
    
    return scheduleSettingsAreEqual(toTask: task)
  }
  
  func scheduleSettingsAreEqual(toTask task: Task) -> Bool {
    guard timesPerDay == task.timesPerDay else { return false }
    guard minutesForTimes == task.minutesForTimes else { return false }
    guard startDate == task.startDate else { return false }
    guard frequency == task.frequency else { return false }
    guard endDaysOrTimes == task.endDaysOrTimes else { return false }
    guard endDate == task.endDate else { return false }
    
    return true
  }
  
  // correct minutes values when timesPerDay has changed
  func correctMinutes() {
    var difference = timesPerDay - minutesForTimes.count
    
    if difference != 0 {
      
      var insertMinutes: Bool
      if difference > 0 {
        insertMinutes = true
      } else {
        insertMinutes = false
      }
      
      difference = abs(difference)
      for _ in 0..<difference {
        
        if insertMinutes {
          // insert minutes
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
          // delete minutes
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
  
  // find the biggest or the least gap between minutes
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
  
  // correct dose values when timesPerDay has changed
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
  
  func setAllDosesEqual() {
    let dose = doseForTimes[0]
    
    for ind in 1..<timesPerDay {
      if doseForTimes[ind] != dose {
        doseForTimes[ind] = dose
      }
    }
  }
  
  func allDosesAreEqual() -> Bool {
    let firstDose = doseForTimes[0]
    let unEqualDoses = doseForTimes.filter { $0 != firstDose }
    return unEqualDoses.isEmpty
  }
  
  // details of task's execution in readable format
  func details(forTime time: Int) -> String {
    let dsPrnt = dosePrintable(forTime: time)
    if !dsPrnt.isEmpty {
      return "\(dosePrintable(forTime: time)) \(doseUnit) \(specialFeature)"
    } else {
      return "\(specialFeature)"
    }
  }
  
}
