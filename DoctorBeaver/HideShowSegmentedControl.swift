//
//  HideShowSegmentedControl.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 01.03.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class HideShowSegmentedControl: UISegmentedControl {
  
  var currentSegment = 0
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    currentSegment = self.selectedSegmentIndex
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    if currentSegment == self.selectedSegmentIndex {
      sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
  }
  
}
