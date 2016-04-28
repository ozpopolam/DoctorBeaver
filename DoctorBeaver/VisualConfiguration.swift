//
//  VisualConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import Foundation

// оформление приложения
struct VisualConfiguration {
  
  static let iconButtonSize = CGSize(width: 44.0, height: 44.0)
  
  static let systemFontSize: CGFloat = 17.0
  
  static let navigationBarFont: UIFont = {
    if let font = UIFont(name: "GillSans-SemiBold", size: 15.0) { return font }
    else { return UIFont.systemFontOfSize(systemFontSize) }
  }()
  
  static let textSemiBoldFont: UIFont = {
    if let font = UIFont(name: "GillSans-SemiBold", size: 15.0) { return font }
    else { return UIFont.systemFontOfSize(systemFontSize) }
  }()
  
  static let textLightFont: UIFont = {
    if let font = UIFont(name: "GillSans-Light", size: 15.0) { return font }
    else { return UIFont.systemFontOfSize(systemFontSize) }
  }()
  
  static let accentOnWhiteColor = UIColor.lightOrangeColor()
  
  ////
  
  enum DateFormatterFormat: String {
    case DateTime = "d.MM.y HH:mm"
    case Date = "d.MM.y"
  }
  
  static let calendar = NSCalendar.currentCalendar()
  
  static func minutesToString(minutes: Int) -> String {
    var s: String = ""
    
    let h = minutes / 60
    if h < 10 {
      s += "0"
    }
    s += "\(h):"
    
    let m = minutes % 60
    if m < 10 {
      s += "0"
    }
    s += "\(m)"
    
    return s
  }
  
  static var dateFormatter: NSDateFormatter {
    get {
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "d.MM.y HH:mm"
      dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU")
      return dateFormatter
    }
    
  }
  
  static func dateFromString(dateString: String, withFormat format: DateFormatterFormat) -> NSDate? {
    let df = dateFormatter
    df.dateFormat = format.rawValue
    return df.dateFromString(dateString)
  }
  
  static func stringFromDate(date: NSDate) -> String {
    return dateFormatter.stringFromDate(date)
  }
  
  
  static var pickerFont: UIFont {
    get {
      if let font = UIFont(name: "GillSans-SemiBold", size: 17.0) { return font }
      else { return UIFont.systemFontOfSize(17.0) }
    }
  }
  static let pickerTextColor = UIColor.blackColor()
  
  static var segmentFont: UIFont {
    get {
      if let font = UIFont(name: "GillSans", size: 13.0) { return font }
      else { return UIFont.systemFontOfSize(13.0) }
    }
  }
  static let segmentTintColor = UIColor.lightGrayColor()
  
///////////
  
  
  let backgroundColor = UIColor.lightOrangeColor()
  
  let navigationIconSize = CGSize(width: 25, height: 25)
  
  
  var basicFont: UIFont {
    get {
      if let font = UIFont(name: "GillSans", size: 17.0) { return font }
        else { return UIFont.systemFontOfSize(17.0) }
    }
  }
  
  var petNameFont: UIFont {
    get {
      if let font = UIFont(name: "Noteworthy-Light", size: 22.0) { return font }
      else { return UIFont.systemFontOfSize(22.0) }
    }
  }
  
  
  
  
  
}