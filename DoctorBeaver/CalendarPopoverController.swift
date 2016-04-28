//
//  FakeAlertController.swift
//  popover
//
//  Created by Anastasia Stepanova-Kolupakhina on 23.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol CalendarPopoverControllerDelegate: class {
  func calendar(cpc: CalendarPopoverController, didPickDate date: NSDate)
  func calendarDidCancel(cpc: CalendarPopoverController)
}



class CalendarPopoverController: UIViewController {
  
  //@IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var cancelButton: UIButton!
  
  @IBOutlet weak var doneButton: UIButton!
  
  weak var delegate: CalendarPopoverControllerDelegate?
  var date: NSDate?
  
  var activeWidth: CGFloat?
  var activeHeight: CGFloat?
  let buttonIconSize = CGSize(width: 33, height: 33)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    calculateActiveWidthAndHeight()
    
    cancelButton.setImage(withName: "cancelOrange", ofSize: buttonIconSize, withTintColor: UIColor.fogColor())
    doneButton.setImage(withName: "doneOrange", ofSize: buttonIconSize, withTintColor: UIColor.fogColor())
    
    datePicker.calendar = DateHelper.calendar
    datePicker.datePickerMode = .Date
    if let date = date {
      datePicker.setDate(date, animated: true)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func calculateActiveWidthAndHeight() {
    let margin: CGFloat = 8.0
    let halfMargin = margin / 2
    var aw: CGFloat = 0.0
    var ah = halfMargin
    
    let subViews: [UIView] = [datePicker, cancelButton]
    for sv in subViews {
      if aw < margin + sv.frame.width + margin {
        aw = margin + sv.frame.width + margin
      }
      ah += sv.frame.height + halfMargin
    }
    
    if aw > view.frame.width {
      aw = view.frame.width
    }
    
    if ah > view.frame.height {
      ah = view.frame.height
    }
    
    activeWidth = aw
    activeHeight = ah
  }
  
  // результат выбор неинтересен, скрыть календарь без последствий
  @IBAction func cancel(sender: UIButton) {
    delegate?.calendarDidCancel(self)
  }
  
  // выбрана новая дата для расписания
  @IBAction func done(sender: UIButton) {
    delegate?.calendar(self, didPickDate: datePicker.date)
  }
  
  
}
