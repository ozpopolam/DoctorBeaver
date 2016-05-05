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
  
  static let pickerFont: UIFont = {
    if let font = UIFont(name: "GillSans-SemiBold", size: 17.0) { return font }
    else { return UIFont.systemFontOfSize(systemFontSize) }
  }()
  
  static let segmentFont: UIFont = {
    if let font = UIFont(name: "GillSans", size: 13.0) { return font }
    else { return UIFont.systemFontOfSize(13.0) }
  }()
  
  static let petNameFont: UIFont = {
    if let font = UIFont(name: "Noteworthy-Light", size: 22.0) { return font }
    else { return UIFont.systemFontOfSize(systemFontSize) }
  }()
  
  static let smallPetNameFont: UIFont = {
    if let font = UIFont(name: "Noteworthy-Light", size: 20.0) { return font }
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

  static let pickerTextColor = UIColor.blackColor()
  
  static let segmentTintColor = UIColor.lightGrayColor()
  
}