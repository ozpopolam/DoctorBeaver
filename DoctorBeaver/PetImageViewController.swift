//
//  PetImageViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 20.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class PetImageViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var petsRepository: PetsRepository! {
    didSet {
      if viewIsReadyToBeLoadedWithPetsRepository() {
        reloadImagesCollection()
      }
    }
  }
  var viewWasLoadedWithPetsRepository = false
  
  // settings for layout of UICollectionView
  let petImageCellId = "petImageCell"
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  var imagesNames = ["dog0", "cat0", "dog1", "cat1", "dog2", "cat2", "dog3", "cat3"]
  var imagesSelected = [Bool]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Картинка питомца".uppercaseString
    
    imagesNames.map{ _ in imagesSelected.append(false) }
    
    let numberOfCellsInALine: CGFloat = 3
    (sectionInset, minimumSpacing, cellSize, cellCornerRadius) = countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine)
    
    if viewIsReadyToBeLoadedWithPetsRepository() {
      reloadImagesCollection()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func viewIsReadyToBeLoadedWithPetsRepository() -> Bool {
    if isViewLoaded() && petsRepository != nil && !viewWasLoadedWithPetsRepository {
      viewWasLoadedWithPetsRepository = true
      return true
    } else {
      return false
    }
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
  
}

extension PetImageViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imagesNames.count
  }
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(petImageCellId, forIndexPath: indexPath) as? PetImageCell {
      
      //cell.backgroundColor = UIColor.greenColor()
      
      cell.petImageView.image = UIImage(named: imagesNames[indexPath.row])
      cell.petImageView.cornerProportion = VisualConfiguration.cornerProportion
      
      cell.selectedView.backgroundColor = VisualConfiguration.lightOrangeColor
      cell.selectedView.cornerProportion = VisualConfiguration.cornerProportion
      
      cell.selectedView.hidden = !imagesSelected[indexPath.row]
      
      return cell
    }
    
    
    return UICollectionViewCell()
  }
  
}

extension PetImageViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PetImageCell {
      imagesSelected[indexPath.row] = !imagesSelected[indexPath.row]
      
      cell.selectedView.hidden = !imagesSelected[indexPath.row]
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
