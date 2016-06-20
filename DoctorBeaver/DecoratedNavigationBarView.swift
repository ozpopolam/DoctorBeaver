//
//  DecoratedNavigationBarView.swift
//  myView
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

@IBDesignable class DecoratedNavigationBarView: UIView {
  
  enum ButtonPosition {
    case Left
    case CenterRight
    case Right
  }

  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var centerRightButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  
  // DecoratedNavigationBarView view from the XIB file
  var view: UIView!
  var buttonIconSize = CGSize(width: 25, height: 25)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
  }
  
  func xibSetup() {
    view = loadViewFromNib()
    view.frame = bounds
    view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    addSubview(view)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: "DecoratedNavigationBarView", bundle: bundle)
    
    // assumes UIView is top level and only object in FakeNavigationBarView.xib file
    if let view = nib.instantiateWithOwner(self, options: nil)[0] as? UIView {
      return view
    } else {
      return UIView()
    }
  }
  
  func setButtonImage(name: String, forButton buttonPosition: ButtonPosition, withTintColor tintColor: UIColor, withAnimationDuration animationDuration: NSTimeInterval = 0) {
    var button: UIButton
    
    switch buttonPosition {
    case .Left: button = leftButton
    case .CenterRight: button = centerRightButton
    case .Right: button = rightButton
    }
    
    button.setImage(withName: name, ofSize: buttonIconSize, withTintColor: tintColor, withAnimationDuration: animationDuration)
  }
  
  func removeButtonImage(forButton buttonPosition: ButtonPosition, ofState state: UIControlState) {
    var button: UIButton
    
    switch buttonPosition {
    case .Left: button = leftButton
    case .CenterRight: button = centerRightButton
    case .Right: button = rightButton
    }
    
    button.setImage(nil, forState: state)
  }
  
  func showButton(buttonPosition: ButtonPosition, withAnimationDuration animationDuration: NSTimeInterval = 0) {
    var button: UIButton
    
    switch buttonPosition {
    case .Left: button = leftButton
    case .CenterRight: button = centerRightButton
    case .Right: button = rightButton
    }
    if button.hidden {
      button.hidden = false
      
      if animationDuration > 0 {
        button.alpha = 0.0
        UIView.animateWithDuration(animationDuration) {
          button.alpha = 1.0
        }
      }
    }
  }
  
  func hideButton(buttonPosition: ButtonPosition) {
    var button: UIButton
    
    switch buttonPosition {
    case .Left: button = leftButton
    case .CenterRight: button = centerRightButton
    case .Right: button = rightButton
    }
    
    if button.hidden != true {
      button.hidden = true
    }
  }
  
  func hideAllButtons() {
    let buttons = [leftButton, centerRightButton, rightButton]
    for button in buttons {
      if button.hidden != true {
        button.hidden = true
      }
    }
  }
}
