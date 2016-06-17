//
//  ViewController.swift
//  CALayerPlayground
//
//  Created by Anastasia Stepanova-Kolupakhina on 07.06.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol ImageCropViewControllerDelegate: class {
  func imageCropViewControllerDidCancel(viewController: ImageCropViewController)
  func imageCropViewController(viewController: ImageCropViewController, didCropImage image: UIImage)
}

class ImageCropViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  
  var photo: UIImage! // picture, loaded from Gallery
  weak var delegate: ImageCropViewControllerDelegate?
  
  var photoView: UIImageView!
  let borderSize = CGSize(width: 2, height: 2)
  var borderedPhotoViewFrame = CGRectZero
  
  let holeView = UIView()
  var laidOutHoleView = false
  var borderLayer = CAShapeLayer()
  var holeMask = CAShapeLayer()
  
  let cropView = UIView()
  var startCropRect = CGSize(width: 125, height: 125)
  
  var viewDidLayoutSubviewsOnce = false
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  var photoLaidOut = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Картинка питомца".uppercaseString
    
    // button "Cancel"
    decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
    
    // button "Done"
    decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    
    // add photoView to show picture
    photoView = UIImageView(image: photo)
    photoView.backgroundColor = UIColor.whiteColor()
    photoView.contentMode = .ScaleToFill
    view.addSubview(photoView)
    
    // add holeView to visualize hole and border for crop square
    holeView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
    view.addSubview(holeView)
    holeView.translatesAutoresizingMaskIntoConstraints = false
    
    // holeView lies below decoratedNavigationBar
    NSLayoutConstraint(item: holeView, attribute: .Left , relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0).active = true
    NSLayoutConstraint(item: holeView, attribute: .Top , relatedBy: .Equal, toItem: decoratedNavigationBar, attribute: .Bottom, multiplier: 1, constant: 0).active = true
    NSLayoutConstraint(item: holeView, attribute: .Right , relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0).active = true
    NSLayoutConstraint(item: holeView, attribute: .Bottom , relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0).active = true
    
    // borderLayer visualizes border for crop square
    borderLayer.fillColor = VisualConfiguration.lightOrangeColor.CGColor
    holeView.layer.addSublayer(borderLayer)
    
    // holeMask visualizes  transparent hole for crop square
    holeMask.fillRule = kCAFillRuleEvenOdd
    holeView.layer.mask = holeMask
    
    // movable view to control position and size of crop square
    holeView.addSubview(cropView)
    
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ImageCropViewController.moveCropRegion(_:)))
    panGestureRecognizer.maximumNumberOfTouches = 1
    panGestureRecognizer.delegate = self
    cropView.addGestureRecognizer(panGestureRecognizer)
    
    let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ImageCropViewController.scaleCropRegion(_:)))
    pinchGestureRecognizer.delegate = self
    cropView.addGestureRecognizer(pinchGestureRecognizer)
  }
  
  override func viewDidLayoutSubviews() {
    let fittedImageSize = fittedSize(ofImage: photo, inView: holeView, withInsetsSize: borderSize)
    
    let photoOriginX = CGRectGetMidX(holeView.frame) - fittedImageSize.width / 2.0
    let photoOriginY = CGRectGetMidY(holeView.frame) - fittedImageSize.height / 2.0
    
    let photoViewRect = CGRect(x: photoOriginX, y: photoOriginY, width: fittedImageSize.width, height: fittedImageSize.height)
    photoView.frame = photoViewRect
    
    if startCropRect.width > fittedImageSize.width + borderSize.width * 2 {
      startCropRect.width = fittedImageSize.width + borderSize.width * 2
      startCropRect.height = startCropRect.width
    }
    
    if startCropRect.height > fittedImageSize.height + borderSize.height * 2 {
      startCropRect.height = fittedImageSize.height + borderSize.height * 2
      startCropRect.width = startCropRect.height
    }
    
    let cropOriginX = CGRectGetMidX(holeView.bounds) - startCropRect.width / 2.0
    let cropOriginY = CGRectGetMidY(holeView.bounds) - startCropRect.height / 2.0
    
    let cropViewRect = CGRect(x: cropOriginX, y: cropOriginY, width: startCropRect.width, height: startCropRect.height)
    cropView.frame = cropViewRect
    
    borderedPhotoViewFrame = view.convertRect(photoView.frame, toView: holeView)
    borderedPhotoViewFrame.insetInPlace(dx: -borderSize.width, dy: -borderSize.height)
    
    updateCropBorderAndHole(withRectangle: cropView.frame)
  }
  
  // calculate size of image to fit in a photoView
  func fittedSize(ofImage image: UIImage, inView view: UIView, withInsetsSize insetsSize: CGSize) -> CGSize {
    var fittedImageWidth: CGFloat
    var fittedImageHeight: CGFloat
    
    let cutViewWidth = view.frame.size.width - insetsSize.width * 2
    let cutViewHeight = view.frame.size.height - insetsSize.height * 2
    
    // image-size is less than view-size
    if image.size.width <= cutViewWidth &&
      image.size.height <= cutViewHeight {
      return image.size
    } else {
      // image-size is bigger than view-size -> need to aspect fit
      let widthRation = cutViewWidth / image.size.width
      fittedImageHeight = image.size.height * widthRation
      if fittedImageHeight <= cutViewHeight {
        fittedImageWidth = image.size.width * widthRation
      } else {
        let heightRation = cutViewHeight / image.size.height
        fittedImageWidth = image.size.width * heightRation
        fittedImageHeight = image.size.height * heightRation
      }
      return CGSize(width: fittedImageWidth, height: fittedImageHeight)
    }
  }
  
  // update position and size of borderLayer and holeMask
  func updateCropBorderAndHole(withRectangle rect: CGRect) {
    borderLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.width / VisualConfiguration.cornerProportion).CGPath
    
    let holeRect = rect.insetBy(dx: borderSize.width, dy: borderSize.height)
    let holePath = UIBezierPath(rect: holeView.bounds)
    holePath.appendPath(UIBezierPath(roundedRect: holeRect, cornerRadius: holeRect.size.width / VisualConfiguration.cornerProportion))
    
    holeMask.path = holePath.CGPath
  }
  
  
  // move crop square with pan gesture
  func moveCropRegion(recognizer: UIPanGestureRecognizer) {
    let translationPoint = recognizer.translationInView(view)
    
    if let recognizerView = recognizer.view {
      recognizerView.center = CGPoint(x: recognizerView.center.x + translationPoint.x, y: recognizerView.center.y + translationPoint.y)
      
      updateOrigin(ofView: recognizerView, toStayInsideRect: borderedPhotoViewFrame)
      updateCropBorderAndHole(withRectangle: recognizerView.frame)
    }
    
    recognizer.setTranslation(CGPointZero, inView: view)
  }
  
  // move crop square to stay in rect
  func updateOrigin(ofView view: UIView, toStayInsideRect rect: CGRect) {
    if let rectIntersection = firstRect(view.frame, intersectsSecondRect: rect) {
      if rectIntersection.left > 0 {
        view.frame.origin.x = view.frame.origin.x + rectIntersection.left
      }
      if rectIntersection.top > 0 {
        view.frame.origin.y = view.frame.origin.y + rectIntersection.top
      }
      if rectIntersection.right > 0 {
        view.frame.origin.x = view.frame.origin.x - rectIntersection.right
      }
      if rectIntersection.bottom > 0 {
        view.frame.origin.y = view.frame.origin.y - rectIntersection.bottom
      }
    }
  }
  
  typealias ViewIntersection = (left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat)
  // get value of intersection of two rectangles
  func firstRect(firstRect: CGRect, intersectsSecondRect secondRect: CGRect) -> ViewIntersection? {
    let firstRectX = firstRect.origin.x
    let firstRectY = firstRect.origin.y
    let firstRectWidth = firstRect.size.width
    let firstRectHeight = firstRect.size.height
    
    let secondRectX = secondRect.origin.x
    let secondRectY = secondRect.origin.y
    let secondRectWidth = secondRect.size.width
    let secondRectHeight = secondRect.size.height
    
    var viewIntersection: ViewIntersection = (left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
    
    let left = secondRectX - firstRectX
    if left > 0 {
      viewIntersection.left = left
    }
    
    let top = secondRectY - firstRectY
    if top > 0 {
      viewIntersection.top = top
    }
    
    let right = (firstRectX + firstRectWidth) - (secondRectX + secondRectWidth)
    if right > 0 {
      viewIntersection.right = right
    }
    
    let bottom = (firstRectY + firstRectHeight) - (secondRectY + secondRectHeight)
    if bottom > 0 {
      viewIntersection.bottom = bottom
    }
    
    if viewIntersection.left > 0 || viewIntersection.top > 0 || viewIntersection.right > 0 || viewIntersection.bottom > 0 {
      return viewIntersection
    } else {
      return nil
    }
  }
  
  // scale crop square with pinch gesture
  func scaleCropRegion(recognizer: UIPinchGestureRecognizer) {
    let scale = recognizer.scale
    
    if let recognizerView = recognizer.view {
      let oldOrigin = recognizerView.frame.origin
      let oldSize = recognizerView.frame.size
      
      recognizerView.transform = CGAffineTransformScale(recognizerView.transform, scale, scale)
      
      if recognizerView.frame.size.width > borderedPhotoViewFrame.size.width ||
        recognizerView.frame.size.height > borderedPhotoViewFrame.height {
        recognizerView.frame.origin = oldOrigin
        recognizerView.frame.size = oldSize
      } else {
        updateOrigin(ofView: recognizerView, toStayInsideRect: borderedPhotoViewFrame)
        updateCropBorderAndHole(withRectangle: recognizerView.frame)
      }
      
    }
    
    recognizer.scale = 1
  }
  
  // Cancel-button
  func cancel(sender: UIButton) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // Done-button
  func done(sender: UIButton) {
    let croppedImage = getCroppedImage()
    delegate?.imageCropViewController(self, didCropImage: croppedImage)
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func getCroppedImage() -> UIImage {
    // crop border in photoView's coordinate
    let cropBorderRect = holeView.convertRect(cropView.frame, toView: photoView)
    // inside part of crop border -> actual cropped rectangle
    var cropPhotoRect = cropBorderRect.insetBy(dx: borderSize.width, dy: borderSize.height)
    
    if photo.imageOrientation != .Up {
      // photo is rotated under the hood -> need to correct rectangle's coordinate
      
      if photo.imageOrientation == .Right {
        let vHeight: CGFloat = photoView.frame.width
        let hPoint = cropPhotoRect.origin
        
        let x = hPoint.y
        let y = vHeight - hPoint.x - cropPhotoRect.height
        
        cropPhotoRect.origin = CGPoint(x: x, y: y)
      }
    }
    
    // correlation between picture's actual size (considering scale factor) and scaled picture inside image view
    let scale = photo.size.width * photo.scale / photoView.frame.size.width
    
    // cropped rectangle in real-size-picture's coordinate
    let actualSizePhotoRect = CGRect(x: cropPhotoRect.origin.x * scale, y: cropPhotoRect.origin.y * scale, width: cropPhotoRect.width * scale, height: cropPhotoRect.height * scale)
    
    // crop rectangle from original image
    if let croppedCgImage = CGImageCreateWithImageInRect(photo.CGImage, actualSizePhotoRect) {
      let croppedImage = UIImage(CGImage: croppedCgImage, scale: photo.scale, orientation: photo.imageOrientation)
      return croppedImage.ofMaxDimension(VisualConfiguration.maxImageDimension)
    } else {
      return photo
    }
    
  }
  
  
}

extension ImageCropViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}