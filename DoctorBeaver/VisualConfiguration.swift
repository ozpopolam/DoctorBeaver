//
//  VisualConfiguration.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import Foundation

// appearance of app
struct VisualConfiguration {
  
  static let noImageName = "DefaultPetImages/noImage"
  static let maxImageDimension: CGFloat = 150.0
  static let renderedAtMaxX: CGFloat = 3.0
  
  static let barButtonSize = CGSize(width: 44.0, height: 44.0)
  static let barIconSize = CGSize(width: 25, height: 25)
  static let buttonIconSize = CGSize(width: 33, height: 33)
  static let accessoryIconSize = CGSize(width: 22, height: 22)
  static let infoIconSize = CGSize(width: 22, height: 22)
  
  let buttonIconSize = CGSize(width: 33, height: 33)
  
  static let animationDuration: NSTimeInterval = 0.5
  
  static let systemFontSize: CGFloat = 17.0
  
  static let tabBarFont: UIFont = {
    if let font = UIFont(name: "GillSans", size: 10.0) { return font }
    else { return UIFont.systemFontOfSize(systemFontSize) }
  }()
  
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
  
  static let iconNameFont: UIFont = {
    if let font = UIFont(name: "GillSans-Light", size: 20.0) { return font }
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
  
  static let cornerProportion: CGFloat = 6.4
  
  static let textBlackColor = UIColor.blackColor()
  static let textGrayColor = UIColor.lightGrayColor()
  static let textOrangeColor = UIColor.lightOrangeColor()
  
  static let blackColor = UIColor.blackColor()
  static let darkGrayColor = UIColor.fogColor()
  static let lightOrangeColor = UIColor.lightOrangeColor()
  static let lightGrayColor = UIColor.lightGrayColor()
  
  static let graySelection: UITableViewCellSelectionStyle = .Gray
  
  static let accentOnWhiteColor = UIColor.lightOrangeColor()
  static let pickerTextColor = UIColor.blackColor()
  static let segmentTintColor = UIColor.lightGrayColor()
  
}