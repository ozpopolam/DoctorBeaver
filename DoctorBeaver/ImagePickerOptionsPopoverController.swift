//
//  ImagePickerOptionsPopoverController.swift
//
//  Created by Anastasia Stepanova-Kolupakhina on 23.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol ImagePickerOptionsPopoverControllerDelegate: class {
  func popoverDidPickTakingPhotoWithCamera()
  func popoverDidPickGettingPhotoFromLibrary()
}

class ImagePickerOptionsPopoverController: UIViewController {
  
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var photoLibraryButton: UIButton!
  
  weak var delegate: ImagePickerOptionsPopoverControllerDelegate?
  
  var filledWidth: CGFloat?
  var filledHeight: CGFloat?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    cameraButton.setTitle("Сделать фото", forState: .Normal)
    photoLibraryButton.setTitle("Выбрать из галереи", forState: .Normal)
    
    calculateFilledWidthAndHeight()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func calculateFilledWidthAndHeight() {
    let margin: CGFloat = 8.0
    
    var widestControlWidth: CGFloat = 0.0
    var lowestControlButton: CGFloat = 0.0
    
    
    let controls: [UIView] = [cameraButton, photoLibraryButton]
    for control in controls {
      
      if control.frame.size.width > widestControlWidth {
        widestControlWidth = control.frame.size.width
      }
      
      let controlBottomY = control.frame.origin.y + control.frame.size.height - 1
      
      if controlBottomY > lowestControlButton {
        lowestControlButton = controlBottomY
      }
      
    }
    
    filledWidth = widestControlWidth
    filledHeight = margin + cameraButton.frame.height + margin + photoLibraryButton.frame.height + margin
  }
  
  @IBAction func takePhotoWithCamera(sender: UIButton) {
    delegate?.popoverDidPickTakingPhotoWithCamera()
  }
  
  @IBAction func getPhotoFromLibrary(sender: UIButton) {
    delegate?.popoverDidPickGettingPhotoFromLibrary()
  }
  
}