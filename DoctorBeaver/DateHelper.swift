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
  
  static func dateFromString(dateString: String, withFormat format: DateFormatterFormat) -> NSDate? {
    let df = dateFormatter
    df.dateFormat = format.rawValue
    return df.dateFromString(dateString)
  }
  
  // date to string with special format
  static func dateToString(date: NSDate, withDateFormat dateFormat: String = DateFormatterFormat.DateTime.rawValue) -> String {
    dateFormatter.dateFormat = dateFormat
    return dateFormatter.stringFromDate(date)
  }
  
  static let maxMinutes = 24 * 60
  
  // minutes in hh:mm format
  static func minutesToString(totalMinutes: Int) -> String {
    
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    
    return String(format: "%02d:%02d", hours, minutes)
  }
  
  // get minutes (hours * 60 + minutes) from date
  static func getMinutes(fromDate date: NSDate) -> Int {
    let hourComponent = DateHelper.calendar.component(.Hour, fromDate: date)
    let minuteComponent = DateHelper.calendar.component(.Minute, fromDate: date)
    let minutes = hourComponent * 60 + minuteComponent
    return minutes
  }
  
  static func compareDatesToUnit(firstDate firstDate: NSDate, secondDate: NSDate, unit: NSCalendarUnit) -> NSComparisonResult {
    return calendar.compareDate(firstDate, toDate: secondDate, toUnitGranularity: unit)
  }
  
  static func compareDatesToDayUnit(firstDate firstDate: NSDate, secondDate: NSDate) -> NSComparisonResult {
    return calendar.compareDate(firstDate, toDate: secondDate, toUnitGranularity: .Day)
  }
  
  static func calendarDayDifference(fromDate fd: NSDate, toDate sd: NSDate) -> Int {
    // 11.09.16 12.15 & 11.09.16 23.15 - the same day, 11.09.16 23.15 & 12.09.16 01.15 - one day difference
    
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