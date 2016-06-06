//
//  Image.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

extension UIImage {
  
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
  
  func cropCentralOneThirdSquare() -> UIImage {
    let x = floor(self.size.width / 3)
    let y = floor(self.size.height / 3)
    let width = x
    let height = y
    
    let cropSquare = CGRectMake(x, y, width, height)
    let imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare)
    
    if let imageRef = imageRef {
      let croppedImage = UIImage(CGImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
      return croppedImage
    } else {
      return self
    }
  }
}
