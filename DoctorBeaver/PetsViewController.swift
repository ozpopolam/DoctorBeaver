//
//  PetViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 02.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class PetsViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var warningLabel: UILabel!
  
  // id ячеек
  let petCellId = "petCell"
  var cellWidth: CGFloat = 0.0
  var cellSize = CGSize(width: 0.0, height: 0.0)
  var cellCornerRadius: CGFloat = 0.0
  var sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
  var minimumSpacing: CGFloat = 0.0
  
  var managedContext: NSManagedObjectContext!
  var viewWasLoadedWithManagedContext = false
  
  // питомцы, которые будут отражены
  var pets = [Pet]()
  // id питомца - обрезанное изображение
  var croppedPetImages: [Double: UIImage] = [ : ]
  
  
  // тип сортировки
  var sortedAZ = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Питомцы".uppercaseString
    
    // кнопка сортировки
    fakeNavigationBar.setButtonImage("sorting", forButton: .Left, withTintColor: UIColor.fogColor())
    fakeNavigationBar.leftButton.addTarget(self, action: "sort:", forControlEvents: .TouchUpInside)
    
    // кнопка добавления нового питомца
    fakeNavigationBar.setButtonImage("add", forButton: .Right, withTintColor: UIColor.fogColor())
    fakeNavigationBar.rightButton.addTarget(self, action: "add:", forControlEvents: .TouchUpInside)
    
    // число ячеек в линии
    let numberOfCellsInALine: CGFloat = 2
    // считаем размеры ячеек и отступы
    countFlowLayoutValues(forNumberOfCellsInALine: numberOfCellsInALine)
    
    // проверяем, загружен ли контекст
    if viewIsReadyToBeLoaded(withManagedContext: managedContext) {
      // настраиваем view
      fullyReloadPetCollection()
    }
  }
  
  // размеры ячеек и отступов по числу ячеек в ряде
  func countFlowLayoutValues(forNumberOfCellsInALine numberOfCellsInALine: CGFloat) {
    let maxWidth = view.frame.size.width
    
    let inset = floor(maxWidth * 3.0 / 100.0)
    sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    
    let tempMinimumSpacing = maxWidth * 4.0 / 100.0
    
    let cellWidth = ceil( (maxWidth - (inset * 2 + tempMinimumSpacing * (numberOfCellsInALine - 1) ) ) / numberOfCellsInALine )
    
    minimumSpacing = floor( (maxWidth - (inset * 2 + cellWidth * numberOfCellsInALine) ) / (numberOfCellsInALine - 1) )
    
    let tempLabel = UILabel()
    tempLabel.font = VisualConfiguration.smallPetNameFont
    tempLabel.text = "X"
    tempLabel.sizeToFit()
    
    let cellHeight = ceil(cellWidth + tempLabel.frame.size.height)
    cellSize = CGSize(width: cellWidth, height: cellHeight)
    
    cellCornerRadius = cellWidth / CGFloat(6.4)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // была нажата кнопка "Сортировать"
  func sort(sender: UIButton) {
    if sortedAZ {
      pets.sortInPlace(sortedByNameDESC)
      sortedAZ = false
    } else {
      pets.sortInPlace(sortedByNameASC)
      sortedAZ = true
    }
    
    collectionView.performBatchUpdates({
      self.collectionView.reloadSections(NSIndexSet(index: 0))
      }, completion: nil)
  }
  
  // сортируем питомцев по имени в восходящем порядке
  func sortedByNameASC(lh: Pet, rh: Pet) -> Bool {
    return lh.name.localizedStandardCompare(rh.name) == .OrderedAscending
  }
  // в нисходящем порядке
  func sortedByNameDESC(lh: Pet, rh: Pet) -> Bool {
    return lh.name.localizedStandardCompare(rh.name) == .OrderedDescending
  }
  
  
  // была нажата кнопка "Добавить"
  func add(sender: UIButton) {
    print("add")
  }
  
  // заполняем таблицу с нуля
  // настраиваем внешний вид по инфо питомца и инициируем отображение расписания
  func fullyReloadPetCollection() {
    // настраиваем расположение кнопок и по необходимости выводим предупреждающие надписи
    if countAllPets(fromManagedContext: managedContext) == 0 {
      // не зарегестрировано ни одного питомца
      // прячем все кнопки с nav bar
      
      //fakeNavigationBar.hideAllButtons()
      
      
      // показываем предупреждение
      showWarningMessage("попробуйте сначала добавить хотя бы одного питомца")
      
    } else {
      reloadPetCollection()
    }
    
  }
  
  // загружаем только выбранных питомцев
  func reloadPetCollection(withNoFetchRequest noFetchRequest: Bool = false) {
    // прячем view с ошибкой
    hideWarningMessage()
    
    if !noFetchRequest {
      // загружаем питомцев
      pets = fetchAllPets(fromManagedContext: managedContext)
      for pet in pets {
        if let petImage = UIImage(named: pet.image) {
          croppedPetImages[pet.id] = cropCentralSquare(fromImage: petImage)
        }
      }
    }
    
    collectionView.reloadData()
  }
  
  // вырезаем центральный квадрат картинки
  func cropCentralSquare(fromImage image: UIImage) -> UIImage {
    let x = floor(image.size.width / 3)
    let y = floor(image.size.height / 3)
    let width = x
    let height = y
    
    let cropSquare = CGRectMake(x, y, width, height)
    let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare)
    
    if let imageRef = imageRef {
      let croppedImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
      return croppedImage
    } else {
      return image
    }
  }
  
  // показываем view с предупреждением
  func showWarningMessage(message: String) {
    warningLabel.text = message
  }
  
  // прячем view с предупреждением
  func hideWarningMessage() {
//    if tableView.hidden {
//      tableView.hidden = false
//    }
    warningLabel.text = ""
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
      cell.petName.textColor = UIColor.blackColor()
      
      return cell
    } else {
      return UICollectionViewCell()
    }
  }
  
}

extension PetsViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    print(indexPath.row)
    
  }
}

extension PetsViewController: UICollectionViewDelegateFlowLayout {
  
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

// обращения с CoreData
extension PetsViewController: ManagedObjectContextSettableAndLoadable {
  
  // устанавливаем ManagedObjectContext
  func setManagedObjectContext(managedContext: NSManagedObjectContext) {
    self.managedContext = managedContext
    // если view загружено, подгружаем в него данные
    if viewIsReadyToBeLoaded(withManagedContext: self.managedContext) {
      fullyReloadPetCollection()
    }
  }
  
  // проверяем, можно ли обновить view данными из managedContext
  func viewIsReadyToBeLoaded(withManagedContext managedContext: NSManagedObjectContext?) -> Bool {
    if self.isViewLoaded() && managedContext != nil && !self.viewWasLoadedWithManagedContext {
      self.viewWasLoadedWithManagedContext = true
      return true
    } else {
      return false
    }
  }
  
  // считаем общее число питомцев
  func countAllPets(fromManagedContext managedContext: NSManagedObjectContext) -> Int {
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    fetchRequest.resultType = .CountResultType
    
    do {
      if let results = try managedContext.executeFetchRequest(fetchRequest) as? [NSNumber] {
        if let count = results.first?.integerValue {
          return count
        } else {
          return 0
        }
      } else {
        return 0
      }
    } catch {
      print("Fetching error!")
      return 0
    }
  }
  
  // выбираем всех питомцев
  func fetchAllPets(fromManagedContext managedContext: NSManagedObjectContext) -> [Pet] {
    let fetchRequest = NSFetchRequest(entityName: Pet.entityName)
    
    do {
      if let results = try managedContext.executeFetchRequest(fetchRequest) as? [Pet] {
        return results.sort(sortedByNameASC)
      } else {
        return []
      }
    } catch {
      print("Fetching error!")
      return []
    }
  }
}


