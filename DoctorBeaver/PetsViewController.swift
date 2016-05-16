//
//  PetViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 02.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class PetsViewController: UIViewController, PetsRepositorySettable {
  
  @IBOutlet weak var fakeNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var warningLabel: UILabel!
  
  let addPetSegueId = "addPetSegue"
  let editShowPetSegueId = "editShowPetSegue"
  
  // settings for layout of UICollectionView
  let petCellId = "petCell"
  var cellWidth: CGFloat = 0.0
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  var petsRepository: PetsRepository! {
    didSet {
      if viewIsReadyToBeLoadedWithPetsRepository() {
        fullyReloadPetCollection()
      }
    }
  }
  var viewWasLoadedWithPetsRepository = false
  
  var pets = [Pet]()
  var croppedPetImages: [Double: UIImage] = [ : ] // pet's id + cropped version of its icon

  let animationDuration = VisualConfiguration.animationDuration // to animate change of button's icon
  
  var sortedAZ = true // current sorting of pets
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Питомцы".uppercaseString
    
    // button "Sorting"
    fakeNavigationBar.setButtonImage("sortingZA", forButton: .Left, withTintColor: UIColor.fogColor())
    fakeNavigationBar.leftButton.addTarget(self, action: "sort:", forControlEvents: .TouchUpInside)
    
    // button "Add pet"
    fakeNavigationBar.setButtonImage("add", forButton: .Right, withTintColor: UIColor.fogColor())
    fakeNavigationBar.rightButton.addTarget(self, action: "add:", forControlEvents: .TouchUpInside)
    
    let numberOfCellsInALine: CGFloat = 2
    countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine) // count size and insets of cells
    
    if viewIsReadyToBeLoadedWithPetsRepository() {
      fullyReloadPetCollection()
    }
  }
  
  func viewIsReadyToBeLoadedWithPetsRepository() -> Bool {
    if isViewLoaded() && petsRepository != nil && !viewWasLoadedWithPetsRepository {
      viewWasLoadedWithPetsRepository = true
      return true
    } else {
      return false
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBarHidden = true // hide navigation bar
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  //Sorting-button
  func sort(sender: UIButton) {
    
    // configure button's icon and action
    fakeNavigationBar.setButtonImage(sortedAZ ? "sortingAZ" : "sortingZA", forButton: .Left, withTintColor: UIColor.fogColor(), withAnimationDuration: animationDuration)
    pets.sortInPlace(sortedByName(sortedAZ ? .OrderedDescending : .OrderedAscending))
    
    sortedAZ = !sortedAZ // new type of current sorting
    
    // reload all cells
    collectionView.performBatchUpdates({
      self.collectionView.reloadSections(NSIndexSet(index: 0))
      }, completion: nil)
  }
  
  func sortedByName(direction: NSComparisonResult) -> ((lh: Pet, rh: Pet) -> Bool) {
    return {
      (lh, rh) -> Bool in
      return lh.name.localizedStandardCompare(rh.name) == direction
    }
  }
  
  // Add-button
  func add(sender: UIButton) {
    performSegueWithIdentifier(addPetSegueId, sender: self)
  }
  
  // fetch data, show warning or reload collection view
  func fullyReloadPetCollection() {
    
    if petsRepository.countAll(Pet.entityName) == 0 {
      showWarningMessage("попробуйте сначала добавить хотя бы одного питомца")
    } else {
      hideWarningMessage()
      pets = petsRepository.fetchAllPets()
      
      // get cropped version of all pets' icons
      croppedPetImages = [ : ]
      for pet in pets {
        if let petImage = UIImage(named: pet.image) {
          croppedPetImages[pet.id] = petImage.cropCentralOneThirdSquare()
        }
      }
      
      collectionView.reloadData()
    }
    
  }
  
  func showWarningMessage(message: String) {
    collectionView.hidden = true
    warningLabel.text = message
  }
  
  func hideWarningMessage() {
    collectionView.hidden = false
    warningLabel.text = ""
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
  }
  
}

extension PetsViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pets.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(petCellId, forIndexPath: indexPath) as? PetCVCell {
      
      let pet = pets[indexPath.row]
      cell.layer.cornerRadius = cellCornerRadius
      
      cell.petImageView.image = UIImage(named: pet.image)
      cell.borderImageView.image = croppedPetImages[pet.id]
      
      cell.petName.font = VisualConfiguration.smallPetNameFont
      cell.petName.numberOfLines = 1
      
      cell.petName.adjustsFontSizeToFitWidth = true
      cell.petName.minimumScaleFactor = 0.75
      
      cell.petName.text = pets[indexPath.row].name
      cell.petName.textColor = VisualConfiguration.textBlackColor
      
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
}

extension PetsViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier(editShowPetSegueId, sender: self)
  }
}

extension PetsViewController: UICollectionViewDelegateFlowLayout {
  
  // counting sizes and insets of cells, based on its number
  func countFlowLayoutValues(forNumberOfCellsInALine numberOfCellsInALine: CGFloat) {
    let maxWidth = view.frame.size.width
    
    let inset = floor(maxWidth * 3.0 / 100.0)
    sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    
    let tempMinimumSpacing = maxWidth * 4.0 / 100.0 // temporary value to be specified
    
    let cellWidth = ceil( (maxWidth - (inset * 2 + tempMinimumSpacing * (numberOfCellsInALine - 1) ) ) / numberOfCellsInALine )
    
    minimumSpacing = floor( (maxWidth - (inset * 2 + cellWidth * numberOfCellsInALine) ) / (numberOfCellsInALine - 1) )
    
    let tempLabel = UILabel()
    tempLabel.font = VisualConfiguration.smallPetNameFont
    tempLabel.text = "X"
    tempLabel.sizeToFit()
    
    let cellHeight = ceil(cellWidth + tempLabel.frame.size.height)
    cellSize = CGSize(width: cellWidth, height: cellHeight)
    
    cellCornerRadius = cellWidth / CGFloat(VisualConfiguration.cornerProportion)
  }
  
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