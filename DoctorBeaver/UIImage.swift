//
//  UIImage.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

extension UIImage {
  
  var sizeInPixels: (width: CGFloat, height: CGFloat) {
    get {
      return (width: size.width * scale, height: size.height * scale)
    }
  }
  
  // if name of image is void - right away return nil
  convenience init?(unsafelyNamed name: String?) {
    if let name = name {
      if !name.isEmpty {
        self.init(named: name)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
  
  // size in points of device
  func ofSize(size: CGSize) -> UIImage {
    if self.size == size {
      return self
    } else {
      let hasAlpha = true
      
      UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, 0.0)
      self.drawInRect(CGRect(origin: CGPointZero, size: size))
      
      let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
      return scaledImage
    }
  }
  
  // crop internal square of image
  func cropCentralOneThirdSquare() -> UIImage {
    let x = floor(sizeInPixels.width / 3)
    let y = floor(sizeInPixels.height / 3)
    let croppedWidth = x
    let croppedHeight = y
    
    let cropSquare = CGRectMake(x, y, croppedWidth, croppedHeight)
    let imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare)
    
    if let imageRef = imageRef {
      let croppedImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
      return croppedImage
    } else {
      return self
    }
  }
}
