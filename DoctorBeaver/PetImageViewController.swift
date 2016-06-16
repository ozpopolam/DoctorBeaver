//
//  PetImageViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 20.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol PetImageViewControllerDelegate: class {
  func petImageViewController(viewController: PetImageViewController, didSelectNewImageName imageName: String)
  func petImageViewController(viewController: PetImageViewController, didSelectNewImage newImage: UIImage, withName newImageName: String)
}

class PetImageViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  weak var delegate: PetImageViewControllerDelegate?
  var petInitialImage: UIImage!
  var petInitialImageName: String!
  
  // settings for layout of UICollectionView
  let petImageCellId = "petImageCell"
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  let folderName = "DefaultPetImages/"
  let defaultImagesNames = ["aquarium", "bird", "bunny", "cat0", "cat1", "cat2", "dog0", "dog1", "dog2", "fish", "snake"] // default images
  var imagesNames = [String]() // ~ image from photo/gallery + ~ pet's custom image + default images
  var images = [UIImage?]()
  
  //let importedImageName = "imported" // name of image from photo/gallery
  var importedImage: UIImage? // image from photo/gallery
  
  let noSelectionIndex = -1
  let noSelectionImageName = "noImage"
  var selectedIndex = 0 // index of selected items
  
  lazy var imagePicker = UIImagePickerController()
  // available sources
  let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
  let photoLibraryIsAvailable = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Картинка питомца".uppercaseString
    
    // button "Cancel"
    decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
    
    if cameraIsAvailable || photoLibraryIsAvailable { // image can be picked from camera or gallery
      // button "Add photo"
      decoratedNavigationBar.setButtonImage("camera", forButton: .CenterRight, withTintColor: UIColor.fogColor())
      decoratedNavigationBar.centerRightButton.addTarget(self, action: #selector(addPhoto(_:)), forControlEvents: .TouchUpInside)
    }
    
    // button "Done"
    decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    
    prepareDataSource()
    
    let numberOfCellsInALine: CGFloat = 3
    (sectionInset, minimumSpacing, cellSize, cellCornerRadius) = countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine)
    collectionView.alwaysBounceVertical = true
    
    reloadImagesCollection()
  }
  
  func prepareDataSource() {
    // prepare list of images names
    imagesNames = defaultImagesNames
    imagesNames = imagesNames.map{ folderName + $0 } // update all names to full form
    
    // set names in random order
    var randomOrderImagesNames: [String] = []
    for _ in 0..<imagesNames.count {
      let ind = Int(arc4random_uniform(UInt32(imagesNames.count)))
      randomOrderImagesNames.append(imagesNames.removeAtIndex(ind))
    }
    imagesNames = randomOrderImagesNames
    
    var petHasCustomImage = false
    
    // place current image name first
    if let indexOfCurrentImageName = imagesNames.indexOf(petInitialImageName) { // if current pet's image name is already in list (it is from defaults set), set it first
      if indexOfCurrentImageName != 0 {
        (imagesNames[0], imagesNames[indexOfCurrentImageName]) = (imagesNames[indexOfCurrentImageName], imagesNames[0])
      }
      selectedIndex = 0 // initially first image is selected
    } else {
      
      if petInitialImageName != noSelectionImageName {
        // pet has custom image
        petHasCustomImage = true
        imagesNames.insert(petInitialImageName, atIndex: 0)
        selectedIndex = 0 // initially first image is selected
      } else {
        // pet has no image - only placeholder
        selectedIndex = noSelectionIndex
      }
    }
    
    // store image created with imagesNames
    images = []
    var defaultImagesStartIndex = 0
    
    if petHasCustomImage {
      // must be loaded from disk
      images.append(petInitialImage)
      defaultImagesStartIndex = 1
    }
    
    // the rest pictures are added from .xcassests
    for ind in defaultImagesStartIndex..<imagesNames.count {
      images.append(UIImage(unsafelyNamed: imagesNames[ind]))
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func reloadImagesCollection() {
    collectionView.reloadData()
    
    if selectedIndex != noSelectionIndex {
      collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selectedIndex, inSection: 0), animated: false, scrollPosition: .Top)
    }
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
//    delegate?.petImageViewControllerDidCancel(self)
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Done-button
  func done(sender: UIButton) {
    var petNewImageName: String // new image name
    
    if selectedIndex == noSelectionIndex {
      petNewImageName = noSelectionImageName // no image was selected -> return placeholder image name
    } else {
      petNewImageName = imagesNames[selectedIndex]
    }
    
    if petNewImageName != petInitialImageName { // check whether new name and old name are the same
      if selectedIndex == 0 {
        if let importedImage = importedImage {
          // user selected imported image
          delegate?.petImageViewController(self, didSelectNewImage: importedImage, withName: petNewImageName)
        } else {
          delegate?.petImageViewController(self, didSelectNewImageName: petNewImageName)
        }
      } else {
        delegate?.petImageViewController(self, didSelectNewImageName: petNewImageName)
      }
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
      
      cell.selectionColor = VisualConfiguration.lightOrangeColor
      cell.unSelectionColor = UIColor.clearColor()
      
      cell.selected = indexPath.row == selectedIndex ? true : false
      
      cell.petImageView.image = images[indexPath.row]
      cell.petImageView.cornerProportion = VisualConfiguration.cornerProportion
      
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
}

extension PetImageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    if selectedIndex == indexPath.row { // user try to select already selected item
      collectionView.deselectItemAtIndexPath(indexPath, animated: false)
      selectedIndex = noSelectionIndex
      return false
    } else {
      return true
    }
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // update selectedTypeItemsInd
    selectedIndex = indexPath.row
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

extension PetImageViewController: ImagePickerOptionsPopoverControllerDelegate {
  
  func popoverDidPickTakingPhotoWithCamera() {
    dismissViewControllerAnimated(true, completion: nil)
    getPhotoFrom(.Camera)
  }
  
  func popoverDidPickGettingPhotoFromLibrary() {
    dismissViewControllerAnimated(true, completion: nil)
    getPhotoFrom(.PhotoLibrary)
  }
  
}

extension PetImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    dismissViewControllerAnimated(false, completion: nil) // dismiss UIImagePickerController
    
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      
      // present modal view controller to crop picker image
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      if let imageCropViewController = storyboard.instantiateViewControllerWithIdentifier("ImageCropViewController") as? ImageCropViewController {
        imageCropViewController.photo = pickedImage
        imageCropViewController.delegate = self
        presentViewController(imageCropViewController, animated: true, completion: nil)
      }
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}

extension PetImageViewController: ImageCropViewControllerDelegate {
  func imageCropViewControllerDidCancel(viewController: ImageCropViewController) {
    
  }
  
  func imageCropViewController(viewController: ImageCropViewController, didCropImage image: UIImage) {
    selectedIndex = 0
    let indexPath = NSIndexPath(forItem: selectedIndex, inSection: 0)
    
    let newImageName = String(NSDate().timeIntervalSince1970)
    
    // user has just imported image for the first time
    if importedImage == nil {
      imagesNames.insert(newImageName, atIndex: 0)
      images.insert(image, atIndex: 0)
      collectionView.insertItemsAtIndexPaths([indexPath])
    } else {
      // some image has been imported -> need to rewrite its cell with new image
      imagesNames[0] = newImageName
      images[0] = image
      
      if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PetImageCell {
        cell.petImageView.image = image
      }
    }
    
    importedImage = image
    collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .Top)
  }
}
