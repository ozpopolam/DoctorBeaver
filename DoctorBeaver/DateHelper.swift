//
//  DateHelper.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 30.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit


enum DateFormatterFormat: String {
  case DateTime = "d.MM.y HH:mm"
  case Date = "d.MM.y"
  case DateVerbal = "d MMMM y, EEEE"
}

struct DateHelper {
  static var calendar = NSCalendar.currentCalendar()
  
  static var dateFormatter: NSDateFormatter = {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = DateFormatterFormat.DateTime.rawValue
      dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
      return dateFormatter
  }()
  
  // дата в строку
  static func dateFromString(dateString: String, withFormat format: DateFormatterFormat) -> NSDate? {
    let df = dateFormatter
    df.dateFormat = format.rawValue
    return df.dateFromString(dateString)
  }
  
  // дата из строки
  static func dateToString(date: NSDate, withDateFormat dateFormat: String = DateFormatterFormat.DateTime.rawValue) -> String {
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.stringFromDate(date)
  }
  
  static let maxMinutes = 24 * 60
  
  // минуты в виде строки hh:mm
  static func minutesToString(totalMinutes: Int) -> String {
    
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    
    return String(format: "%02d:%02d", hours, minutes)
  }
  
  // получить минуты (компонента-часы * 60 + компонента-минуты) из даты
  static func getMinutes(fromDate date: NSDate) -> Int {
    let hourComponent = DateHelper.calendar.component(.Hour, fromDate: date)
    let minuteComponent = DateHelper.calendar.component(.Minute, fromDate: date)
    let minutes = hourComponent * 60 + minuteComponent
    return minutes
  }
  
  // сравниваем даты по значение дня
  static func compareDatesToDayUnit(firstDate firstDate: NSDate, secondDate: NSDate) -> NSComparisonResult {
    return calendar.compareDate(firstDate, toDate: secondDate, toUnitGranularity: .Day)
  }
  
  static func compareDatesToUnit(firstDate firstDate: NSDate, secondDate: NSDate, unit: NSCalendarUnit) -> NSComparisonResult {
    return calendar.compareDate(firstDate, toDate: secondDate, toUnitGranularity: unit)
  }
  
  // календарная разница в днях
  static func calendarDayDifference(fromDate fd: NSDate, toDate sd: NSDate) -> Int {
    let dayComponents = calendar.components(.Day, fromDate: fd, toDate: sd, options: [])
    
    let daysApart = dayComponents.day
    
    if let ssd = calendar.dateByAddingUnit(.Day, value: -daysApart, toDate: sd, options: []) {
      
      let sameDate = calendar.isDate(fd, inSameDayAsDate: ssd)
      
      if sameDate {
        return daysApart
      } else {
        return daysApart + 1
      }
      
    } else {
      return -1
    }
    
  }
  
}

  
  

