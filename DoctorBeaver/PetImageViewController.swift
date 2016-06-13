//
//  PetImageViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 20.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol PetImageViewControllerDelegate: class {
  func petImageViewControllerDidCancel(viewController: PetImageViewController)
  func petImageViewController(viewController: PetImageViewController, didSelectNewImageName imageName: String)
  func petImageViewController(viewController: PetImageViewController, didSelectNewImage image: UIImage)
  
}

class PetImageViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  weak var delegate: PetImageViewControllerDelegate?
  var petCurrentImageName: String = ""

  // settings for layout of UICollectionView
  let petImageCellId = "petImageCell"
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  let folderName = "DefaultPetImages/"
  var imagesNames = ["aquarium", "bird", "bunny", "cat0", "cat1", "cat2", "dog0", "dog1", "dog2", "fish", "snake"]
  
  lazy var imagePicker = UIImagePickerController()
  let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
  let photoLibraryIsAvailable = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
  
  var imagesSelection = [Bool]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Картинка питомца".uppercaseString
    
    // button "Cancel"
    decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
    
    if cameraIsAvailable || photoLibraryIsAvailable { // have place to pick image from
      // button "Add photo"
      decoratedNavigationBar.setButtonImage("camera", forButton: .CenterRight, withTintColor: VisualConfiguration.darkGrayColor)
      decoratedNavigationBar.centerRightButton.addTarget(self, action: #selector(addPhoto(_:)), forControlEvents: .TouchUpInside)
    }
    
    // button "Done"
    decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    
    // prepare list if images names
    imagesNames = imagesNames.map{ folderName + $0 } // update all names to full form
    imagesSelection = [Bool](count: imagesNames.count, repeatedValue: false) // at first, all images are not selected
    // set names in random order
    var randomOrderImagesNames: [String] = []
    for _ in 0..<imagesNames.count {
      let ind = Int(arc4random_uniform(UInt32(imagesNames.count)))
      randomOrderImagesNames.append(imagesNames.removeAtIndex(ind))
    }
    imagesNames = randomOrderImagesNames
    
    if let indexOfCurrentImageName = imagesNames.indexOf(petCurrentImageName) { // if current pet's image name is already in list, set selected state in imagesSelection array
      imagesSelection[indexOfCurrentImageName] = true
    } else { // if it is not, add it at the beginning or imagesNames-array and imagesSelection-array
      let firstIndex = 0
      imagesNames.insert(petCurrentImageName, atIndex: firstIndex)
      imagesSelection.insert(true, atIndex: firstIndex)
    }
    
    let numberOfCellsInALine: CGFloat = 3
    (sectionInset, minimumSpacing, cellSize, cellCornerRadius) = countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine)
    
    reloadImagesCollection()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func reloadImagesCollection() {
    collectionView.reloadData()
  }
  
  func countFlowLayoutValues(forNumberOfCellsInALine numberOfCellsInALine: CGFloat) -> (sectionInset: UIEdgeInsets, minimumSpacing: CGFloat, cellSize: CGSize, cellCornerRadius: CGFloat) {
    let maxWidth = view.frame.width
    
    let inset = floor(maxWidth * 3.0 / 100.0)
    let sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    
    let tempMinimumSpacing = maxWidth * 4.0 / 100.0 // temporary value to be specified
    
    let cellWidth = ceil( (maxWidth - (inset * 2 + tempMinimumSpacing * (numberOfCellsInALine - 1) ) ) / numberOfCellsInALine )
    
    let minimumSpacing = floor( (maxWidth - (inset * 2 + cellWidth * numberOfCellsInALine) ) / (numberOfCellsInALine - 1) )
    
    let cellHeight = cellWidth
    let cellSize = CGSize(width: cellWidth, height: cellHeight)
    
    let cellCornerRadius = cellWidth / CGFloat(VisualConfiguration.cornerProportion)
    
    return (sectionInset, minimumSpacing, cellSize, cellCornerRadius)
  }
  
  // Cancel-button
  func cancel(sender: UIButton) {
    delegate?.petImageViewControllerDidCancel(self)
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Done-button
  func done(sender: UIButton) {
    var petNewImageName: String? // expected new image name for per
    
    for ind in 0..<imagesSelection.count { // try to find selected image
      if imagesSelection[ind] {
        petNewImageName = imagesNames[ind]
        break
      }
    }
    
    if let petNewImageName = petNewImageName { // some image was selected
      if petNewImageName == petCurrentImageName { // check whether new name and old name are the same
        delegate?.petImageViewControllerDidCancel(self) // nothing has changed
      } else {
        delegate?.petImageViewController(self, didSelectNewImageName: petNewImageName)
      }
      
    } else { // no image was selected
      delegate?.petImageViewControllerDidCancel(self)
    }
    
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Camera-button
  func addPhoto(sender: UIButton) {
    if cameraIsAvailable && photoLibraryIsAvailable {
      // both Camera and PhotoLibrary are available - need to present popover to choose
      
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let pickerOptionsViewController = storyboard.instantiateViewControllerWithIdentifier("ImagePickerOptionsPopoverController") as? ImagePickerOptionsPopoverController {
        pickerOptionsViewController.modalPresentationStyle = .Popover
        pickerOptionsViewController.delegate = self
        
        if let popoverController = pickerOptionsViewController.popoverPresentationController {
          popoverController.delegate = self
          popoverController.sourceView = decoratedNavigationBar.centerRightButton.superview
          popoverController.permittedArrowDirections = .Up
          popoverController.backgroundColor = UIColor.whiteColor()
          popoverController.sourceRect = decoratedNavigationBar.centerRightButton.frame
        }
        
        presentViewController(pickerOptionsViewController, animated: true, completion: nil)
        
        var popoverWidth: CGFloat = 0.0
        var popoverHeight: CGFloat = 0.0
        
        if let filledPopoverWidth = pickerOptionsViewController.filledWidth {
          let halfWidth = view.frame.width / 2
          popoverWidth = filledPopoverWidth < halfWidth ? halfWidth : filledPopoverWidth
        }
        
        if let filledPopoverHeight = pickerOptionsViewController.filledHeight {
          popoverHeight = filledPopoverHeight
        }
        
        pickerOptionsViewController.preferredContentSize = CGSize(width: popoverWidth, height: popoverHeight)
      }
    } else {
      if cameraIsAvailable {
        // only camera is available
        getPhotoFrom(.Camera)
      } else if photoLibraryIsAvailable {
        // only photoLibrary is available
        getPhotoFrom(.PhotoLibrary)
      }
    }
  }
  
  
  func getPhotoFrom(sourceType: UIImagePickerControllerSourceType) {
    imagePicker.sourceType = sourceType
    
    if let mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType) {
      let imageMediaTypes = mediaTypes.filter{ $0.lowercaseString.containsString("image") }
      imagePicker.mediaTypes = imageMediaTypes
    }
    
    if sourceType == .Camera {
      imagePicker.cameraCaptureMode = .Photo
    }
    
    imagePicker.delegate = self
    
    presentViewController(imagePicker, animated: true, completion: nil)
  }
  
}

extension PetImageViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesNames.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(petImageCellId, forIndexPath: indexPath) as? PetImageCell {
      
      cell.selectedView.backgroundColor = VisualConfiguration.lightOrangeColor
      cell.selectedView.cornerProportion = VisualConfiguration.cornerProportion
      cell.selectedView.hidden = !imagesSelection[indexPath.row]
      
      cell.petImageView.image = UIImage(unsafelyNamed: imagesNames[indexPath.row])
      cell.petImageView.cornerProportion = VisualConfiguration.cornerProportion
      
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
}

extension PetImageViewController: UICollectionViewDelegate {
  
  // update imagesSelected and show or hide selectedView accordingly
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    imagesSelection[indexPath.row] = !imagesSelection[indexPath.row]
    
    var rowsToUpdate = [Int]()
    
    if imagesSelection[indexPath.row] { // if item was selected
      for ind in 0..<imagesSelection.count { // need to deselect all previously selected items
        if ind != indexPath.row && imagesSelection[ind] {
          imagesSelection[ind] = false
          rowsToUpdate.append(ind)
        }
      }
    }
    
    rowsToUpdate.append(indexPath.row) // selected item itself
    
    for row in rowsToUpdate { // update selectedView' visibility
      if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: row, inSection: indexPath.section)) as? PetImageCell {
        cell.selectedView.hidden = !imagesSelection[row]
      }
    }
    
  }
  
}

extension PetImageViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    return cellSize
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
    return sectionInset
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    return minimumSpacing
  }

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    return minimumSpacing
  }
  
}

extension PetImageViewController: UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
  }
}

extension PetImageViewController: ImagePickerOptionsPopoverControllerDelegate, UINavigationControllerDelegate {
  
  func popoverDidPickTakingPhotoWithCamera() {
    dismissViewControllerAnimated(true, completion: nil)
    getPhotoFrom(.Camera)
  }
  
  func popoverDidPickGettingPhotoFromLibrary() {
    dismissViewControllerAnimated(true, completion: nil)
    getPhotoFrom(.PhotoLibrary)
  }
  
}

extension PetImageViewController: UIImagePickerControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    dismissViewControllerAnimated(false, completion: nil) // dismiss UIImagePickerController
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      if let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? PetImageCell {
        cell.petImageView.image = pickedImage
      }
      
      
      
//      // present modal view controller to crop picker image
//      let storyboard = UIStoryboard(name: "Main", bundle: nil)
//      if let imageCropViewController = storyboard.instantiateViewControllerWithIdentifier("PhotoViewController") as? ImageCropViewController {
//        imageCropViewController.photo = pickedImage
//        imageCropViewController.delegate = self
//        presentViewController(imageCropViewController, animated: true, completion: nil)
//      }
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}


//extension PetImageViewController: ImageCropViewControllerDelegate {
//  func imageCropViewControllerDidCancel(viewController: ImageCropViewController) {
//    
//  }
//  
//  func imageCropViewController(viewController: ImageCropViewController, didCropImage image: UIImage) {
//    //    let imageFileManager = ImageFileManager(withImageFolderName: "PetImages")
//    //    imageFileManager.saveImage(image, withName: "photo")
//    imageView.image = image
//  }
//}
