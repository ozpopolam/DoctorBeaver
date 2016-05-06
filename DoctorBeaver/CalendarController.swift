//
//  CalendarController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class CalendarController: UIViewController {
  
  @IBOutlet weak var dateLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateLabel.font = VisualConfiguration.pickerFont
    let today = NSDate()
    update(withDate: today)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func update(withDate date: NSDate) {
    let todayString = DateHelper.dateToString(date, withDateFormat: DateFormatterFormat.DateVerbal.rawValue)
    dateLabel.text = todayString
  }
  
}
