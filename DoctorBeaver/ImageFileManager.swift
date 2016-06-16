//
//  ImageFileManager.swift
//  ImagePicker
//
//  Created by Anastasia Stepanova-Kolupakhina on 24.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import UIKit

struct ImageFileManager {
  
  private let fileManager: NSFileManager
  private let documentDirectoryURL: NSURL?
  private let imageFilenameExtension = "png"
  
  var imageFolderName: String {
    didSet {
      imageFolderURL = documentDirectoryURL?.URLByAppendingPathComponent(imageFolderName)
    }
  }
  private var imageFolderURL: NSURL?
  
  init(withImageFolderName imageFolderName: String = "PetImages") {
    fileManager = NSFileManager.defaultManager()
    documentDirectoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    self.imageFolderName = imageFolderName
    imageFolderURL = documentDirectoryURL?.URLByAppendingPathComponent(imageFolderName)
  }
  
  private func createImageFolder() -> Bool {
    if let imageFolderURL = imageFolderURL {
      do {
        try fileManager.createDirectoryAtURL(imageFolderURL, withIntermediateDirectories: true, attributes: [:])
        return true
      } catch {
        print("Can't create image folder!")
      }
    }
    return false
  }
  
  private func constructURLForImage(withName imageName: String, byCreatingImageFolder shouldCreateFolder: Bool = false) -> NSURL? {
    
    if let imageFolderURL = imageFolderURL, let path = imageFolderURL.path  {
      //print(imageFolderURL)
      
      if !fileManager.fileExistsAtPath(path) {
        // folder for images doesn't exist
        
        if shouldCreateFolder { // try to create folder
          if !createImageFolder() { // can't do it
            return nil
          }
        } else { // can't create folder -> can't construct url
          return nil
        }
        
      }
      
      // add extension to filename
      if let extendedImageName = NSString(string: imageName).stringByAppendingPathExtension(imageFilenameExtension) {
        let imageURL = imageFolderURL.URLByAppendingPathComponent(extendedImageName) // construct url
        return imageURL
      }
    }
    
    return nil
  }
  
  func saveImage(image: UIImage, withName imageName: String) -> Bool {
    
    if let imageURL = constructURLForImage(withName: imageName, byCreatingImageFolder: true) {
      // url has been constructed
      if let imageData = UIImagePNGRepresentation(image) {
        return imageData.writeToURL(imageURL, atomically: true) // saving file
      }
    }
    
    return false
  }
  
  func getImage(withName imageName: String) -> UIImage? {
    if let imageURL = constructURLForImage(withName: imageName), let path = imageURL.path {
      return UIImage(contentsOfFile: path)
    }
    return nil
  }
  
}