//
//  TaskTypeViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 03.06.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class TaskTypeViewController: UIViewController, PetsRepositorySettable {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  let addPetSegueId = "addPetSegue"
  
  // settings for layout of UICollectionView
  let iconTitleCollectionCellId = "menuIconTitleCollectionCell"
  
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  let animationDuration = VisualConfiguration.animationDuration // to animate change of button's icon
  
  var petsRepository: PetsRepository! {
    didSet {
      if viewIsReadyToBeLoadedWithPetsRepository() {
        reloadTypeItemsCollection()
      }
    }
  }
  var viewWasLoadedWithPetsRepository = false
  var typeItems = [TaskTypeItem]()
  var selectedTypeItemsInd: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Вид задания".uppercaseString
    
    collectionView.backgroundColor = UIColor.whiteColor()
    
    let numberOfCellsInALine: CGFloat = 4
    countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine) // count size and insets of cells
    
    if viewIsReadyToBeLoadedWithPetsRepository() {
      reloadTypeItemsCollection()
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
  
  // fetch type items and show then in a collection
  func reloadTypeItemsCollection() {
    typeItems = petsRepository.fetchAllTaskTypeItems()
    if !typeItems.isEmpty {
      typeItems.sortInPlace { $0.id < $1.id }
      collectionView.reloadData()
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  }
  
}

extension TaskTypeViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return typeItems.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(iconTitleCollectionCellId, forIndexPath: indexPath) as? MenuIconTitleCollectionCell {
      let typeItem = typeItems[indexPath.row]
      
      cell.selectedView.layer.cornerRadius = cellCornerRadius
      
      if let selectedTypeItemsInd = selectedTypeItemsInd {
        if indexPath.row == selectedTypeItemsInd {
          cell.selectedView.backgroundColor = VisualConfiguration.lightOrangeColor
        } else {
          cell.selectedView.backgroundColor = UIColor.clearColor()
        }
      } else {
        cell.selectedView.backgroundColor = UIColor.clearColor()
      }
      
      cell.containerView.layer.cornerRadius = cellCornerRadius
      
      cell.iconView.image = UIImage(named: typeItem.iconName)
      
      
      cell.iconTitle.font = VisualConfiguration.iconNameFont
      cell.iconTitle.text = typeItem.name
      cell.iconTitle.numberOfLines = 2
      cell.iconTitle.adjustsFontSizeToFitWidth = true
      cell.iconTitle.minimumScaleFactor = 0.75
      
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
}

extension TaskTypeViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    if let selectedTypeItemsInd = selectedTypeItemsInd {
      if indexPath.row == selectedTypeItemsInd {
        return true
      }
    }
    return false
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
  }
  
}

extension TaskTypeViewController: UICollectionViewDelegateFlowLayout {
  
  // counting sizes and insets of cells, based on its number
  func countFlowLayoutValues(forNumberOfCellsInALine numberOfCellsInALine: CGFloat) {
    let maxWidth = view.frame.size.width
    
    let inset = floor(maxWidth * 3.0 / 100.0)
    sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    
    let tempMinimumSpacing = maxWidth * 4.0 / 100.0 // temporary value to be specified
    
    let cellWidth = ceil( (maxWidth - (inset * 2 + tempMinimumSpacing * (numberOfCellsInALine - 1) ) ) / numberOfCellsInALine )
    
    minimumSpacing = floor( (maxWidth - (inset * 2 + cellWidth * numberOfCellsInALine) ) / (numberOfCellsInALine - 1) )
    
    let tempLabel = UILabel()
    tempLabel.font = VisualConfiguration.iconNameFont
    tempLabel.text = "X"
    tempLabel.sizeToFit()
    
    let cellHeight = ceil(cellWidth + tempLabel.frame.size.height * 2)
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