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
  
  var imagesSelection = [Bool]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Картинка питомца".uppercaseString
    
    // button "Cancel"
    decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
    
    // button "Add photo"
    decoratedNavigationBar.setButtonImage("camera", forButton: .CenterRight, withTintColor: UIColor.fogColor())
    decoratedNavigationBar.centerRightButton.addTarget(self, action: #selector(addPhoto(_:)), forControlEvents: .TouchUpInside)
    decoratedNavigationBar.centerRightButton.hidden = true
    
    // button "Done"
    decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: VisualConfiguration.darkGrayColor)
    decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    
    // prepare list of images names
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
    //    editState = false // stop editing task
    //    closePickerCellsForShowState()
    //    deactivateAllActiveTextFields()
    //    configureForEditState(withAnimationDuration: animationDuration)
    //
    //    edited = taskDidChange()
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
