//
//  TaskTypeViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 03.06.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class TaskTypeViewController: UIViewController {
  
  @IBOutlet weak var decoratedNavigationBar: DecoratedNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  weak var delegateForTaskMenu: TaskMenuViewControllerDelegate?
  
  let addTaskSegueId = "addTaskSegue"
  var unwindSegueId: String? // id of a possible unwind segue
  
  // settings for layout of UICollectionView
  let iconTitleCollectionCellId = "menuIconTitleCollectionCell"
  
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  let animationDuration = VisualConfiguration.animationDuration // to animate change of button's icon
  
  var pet: Pet! // pet to add task
  var petsRepository: PetsRepository! {
    didSet {
      if viewIsReadyToBeLoadedWithPetsRepository() {
        reloadTypeItemsCollection()
      }
    }
  }
  var viewWasLoadedWithPetsRepository = false
  var typeItems = [TaskTypeItem]()
  var selectedTypeItemsInd = 0 // always must select some cell
  var task: Task? // task which is about to be created
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    decoratedNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    decoratedNavigationBar.titleLabel.text = "Вид задания".uppercaseString
    
    decoratedNavigationBar.setButtonImage("cancel", forButton: .Left, withTintColor: UIColor.fogColor())
    decoratedNavigationBar.leftButton.addTarget(self, action: #selector(cancel(_:)), forControlEvents: .TouchUpInside)
    
    decoratedNavigationBar.setButtonImage("done", forButton: .Right, withTintColor: UIColor.fogColor())
    decoratedNavigationBar.rightButton.addTarget(self, action: #selector(done(_:)), forControlEvents: .TouchUpInside)
    
    collectionView.backgroundColor = UIColor.whiteColor()
    
    let numberOfCellsInALine: CGFloat = 4
    countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine) // count size and insets of cells
    collectionView.alwaysBounceVertical = true
    
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
      collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: .None)
    }
  }
  
  // Cancel-button
  func cancel(sender: UIButton) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  // Done-button
  func done(sender: UIButton) {
//    if let task = petsRepository.insertTask() {
//      task.pet = pet
//      task.configure(withTypeItem: typeItems[selectedTypeItemsInd])
//      self.task = task // save in a variable
//      performSegueWithIdentifier(addTaskSegueId, sender: task)
//    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == addTaskSegueId {
      
      if let task = sender as? Task, let destinationViewController = segue.destinationViewController as? TaskMenuViewController {
        destinationViewController.delegate = delegateForTaskMenu
        destinationViewController.petsRepository = petsRepository
        destinationViewController.task = task
        destinationViewController.menuMode = .Add
        destinationViewController.unwindSegueId = unwindSegueId
      }
    }
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
      cell.selectedView.backgroundColor = VisualConfiguration.lightOrangeColor
      
      cell.selectionColor = VisualConfiguration.lightOrangeColor
      cell.unSelectionColor = UIColor.clearColor()
      cell.selected = indexPath.row == selectedTypeItemsInd ? true : false
      
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
    if indexPath.row != selectedTypeItemsInd {
      return true
    } else {
      return false
    }
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    selectedTypeItemsInd = indexPath.row
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