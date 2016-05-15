//
//  StgDatePicker.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 14.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
  func datePicker(picker: UIDatePicker, didPickDate date: NSDate)
  func datePicker(picker: UIDatePicker, didPickMinutes minutes: Int)
  func dateStillNeeded(fromPicker picker: UIDatePicker) -> Bool
}

class StgDatePicker: UIDatePicker {
  
  weak var delegate: DatePickerDelegate?
  var pickerWithLimits = false
  var miDate: NSDate?
  var maDate: NSDate?
  var selectedDate: NSDate?
  
  var isEmpty = true // data sourse is empty
  var needToResetInitialValues = false // need to be reloaded, when user selected some value, but later it wasn't used
  
  // дата и время
  func configure(withDelegate delegate: DatePickerDelegate, selectedDate sDate: NSDate, andMinimumDate mDate: NSDate) {
    self.delegate = delegate
    datePickerMode = .DateAndTime
    locale = NSLocale(localeIdentifier: "ru_RU")
    
    minimumDate = mDate
    
    if let date = DateHelper.calendar.dateByAddingUnit(.Year, value: 1, toDate: mDate, options: []) {
      maximumDate = date
    } else {
      maximumDate = sDate
    }
    setDate(sDate, animated: true)
    
    isEmpty = false
  }
  
  func configure(withSelectedDate sDate: NSDate) {
    setDate(sDate, animated: true)
  }
  
  // время
  func configure(withDelegate delegate: DatePickerDelegate, selectedMinutes minutes: Int) {
    self.delegate = delegate
    datePickerMode = .Time
    locale = NSLocale(localeIdentifier: "ru_RU")
    minimumDate = nil
    maximumDate = nil
    
    let components = NSDateComponents()
    components.hour = minutes / 60
    components.minute = minutes % 60
    
    if let date = DateHelper.calendar.dateFromComponents(components) {
      setDate(date, animated: true)
    } else {
      setDate(NSDate(), animated: true)
    }
    
    isEmpty = false
  }
  
  // время с ограничениями
  func configure(withDelegate delegate: DatePickerDelegate, selectedMinutes sMinutes: Int, minimumMinutes miMinutes: Int, maximumMinutes maMinutes: Int) {
    self.delegate = delegate
    datePickerMode = .Time
    pickerWithLimits = true
    locale = NSLocale(localeIdentifier: "ru_RU")
    minimumDate = nil
    maximumDate = nil
    
    let components = NSDateComponents()
    
    components.hour = miMinutes / 60
    components.minute = miMinutes % 60
    if let date = DateHelper.calendar.dateFromComponents(components) {
      minimumDate = date
      miDate = date
    }
    
    components.hour = maMinutes / 60
    components.minute = maMinutes % 60
    if let date = DateHelper.calendar.dateFromComponents(components) {
      maximumDate = date
      maDate = date
    }
    
    components.hour = sMinutes / 60
    components.minute = sMinutes % 60
    if let date = DateHelper.calendar.dateFromComponents(components) {
      setDate(date, animated: true)
      selectedDate = date
    } else {
      setDate(NSDate(), animated: true)
    }
    
    isEmpty = false
  }
  
  func didPick() {
    // дата
    if datePickerMode == .DateAndTime {
      if let delegate = delegate {
        if delegate.dateStillNeeded(fromPicker: self) {
          needToResetInitialValues = false
          delegate.datePicker(self, didPickDate: self.date)
        } else {
          needToResetInitialValues = true
        }
      }
      //время
    } else if datePickerMode == .Time {
      let components = DateHelper.calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: self.date)
      let minutes = components.hour * 60 + components.minute
      
      if let delegate = delegate {
        if delegate.dateStillNeeded(fromPicker: self) {
          needToResetInitialValues = false
          delegate.datePicker(self, didPickMinutes: minutes)
        } else {
          needToResetInitialValues = true
        }
      }
    }
  }
  
}
