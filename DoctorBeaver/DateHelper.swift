//
//  File.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 30.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

struct DateHelper {
  static var calendar = NSCalendar.currentCalendar()
  
  static var dateFormatter: NSDateFormatter = {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "d.MM.y HH:mm"
      dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
      return dateFormatter
  }()
  
  static let maxMinutes = 24 * 60
  
  // минуты в виде hh:mm
  static func minutesToString(minutes: Int) -> String {
    var str: String = ""
    
    let h = minutes / 60
    if h < 10 {
      str += "0"
    }
    str += "\(h):"
    
    let m = minutes % 60
    if m < 10 {
      str += "0"
    }
    str += "\(m)"
    
    return str
  }
  
  static func dateToString(date: NSDate, withDateFormat dateFormat: String = "d.MM.y HH:mm") -> String {
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.stringFromDate(date)
  }
  
  // получить минуты (компонента-часы * 60 + компонента-минуты) из даты
  static func getMinutes(fromDate date: NSDate) -> Int {
    let hourComponent = VisualConfiguration.calendar.component(.Hour, fromDate: date)
    let minuteComponent = VisualConfiguration.calendar.component(.Minute, fromDate: date)
    let minutes = hourComponent * 60 + minuteComponent
    return minutes
  }
  
  // сравниваем даты по значение дня
  static func compareDatesToDayUnit(firstDate firstDate: NSDate, secondDate: NSDate) -> NSComparisonResult {
    return calendar.compareDate(firstDate, toDate: secondDate, toUnitGranularity: .Day)
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

  
  

