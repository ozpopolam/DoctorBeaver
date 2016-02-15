//
//  Image.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

extension UIImage {
  func ofSize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    self.drawInRect(CGRect(origin: CGPointZero, size: size))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
