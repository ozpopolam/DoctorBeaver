 //
 //  TabBarController.swift
 //  DoctorBeaver
 //
 //  Created by Anastasia Stepanova-Kolupakhina on 08.02.16.
 //  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 class TabBarController: UITabBarController {
  
  var petsRepository: PetsRepository!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureView()
    
    if false {
      _helperDeleteAllData()
      let firstLaunch = true
      if firstLaunch {
        preparePetsRepositoryForUse()
      }
      populateManagedObjectContextWithJsonPetData()
    }
    
    // начинаем со вкладки расписания
    self.selectedIndex = 1
    delegate = self
    tabBarController(self, didSelectViewController: viewControllers![selectedIndex])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func configureView() {
    UITabBar.appearance().barTintColor = UIColor.lightOrangeColor()
    
    let tabBarAppearance = UITabBarItem.appearance()
    if let font = UIFont(name: "GillSans", size: 10.0) {
      tabBarAppearance.setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
    }
    
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState: .Normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState: .Selected)
    
    
    let tabBarIconSize = CGSize(width: 25, height: 25)
    let tabBatTitles = ["Звери", "Расписание", "Поиск"]
    
    let imagesNames = ["pets", "schedule", "search"]
    var tabBarImages = [UIImage]()
    
    for imageName in imagesNames {
      if let image = UIImage(named: imageName) {
        let scaledImage = image.ofSize(tabBarIconSize)
        tabBarImages.append(scaledImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
      }
    }
    
    let selectedImagesNames = ["petsSelected", "scheduleSelected", "searchSelected"]
    var tabBarSelectedImages = [UIImage]()
    
    for selectImageName in selectedImagesNames {
      if let image = UIImage(named: selectImageName) {
        let scaledImage = image.ofSize(tabBarIconSize)
        tabBarSelectedImages.append(scaledImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
      }
    }
    
    if let tabBarItems = tabBar.items {
      for i in 0..<tabBarItems.count {
        tabBarItems[i].title = tabBatTitles[i].uppercaseString
        tabBarItems[i].image = tabBarImages[i]
        tabBarItems[i].selectedImage = tabBarSelectedImages[i]
      }
    }
  }
  
  func preparePetsRepositoryForUse() -> Bool {
    let jsonBasicValuesParser = JsonTaskPrimaryValuesParser(forPetsRepository: petsRepository)
    return jsonBasicValuesParser.populateRepositoryWithBasicValues(withFileName: "RuBasicValues", andType: "json")
  }
  
  func _helperDeleteAllData() {
    petsRepository.deleteAllObjects(forEntityName: Pet.entityName)
    petsRepository.deleteAllObjects(forEntityName: PetBasicValues.entityName)
    petsRepository.deleteAllObjects(forEntityName: TaskTypeItem.entityName)
    petsRepository.deleteAllObjects(forEntityName: TaskTypeItemBasicValues.entityName)
//    print(petsRepository.fetchAllObjects(forEntityName: Pet.entityName)?.count)
//    print(petsRepository.fetchAllObjects(forEntityName: TaskTypeItem.entityName)?.count)
//    print(petsRepository.fetchAllObjects(forEntityName: TaskTypeItemBasicValues.entityName)?.count)
  }
  
  func populateManagedObjectContextWithJsonPetData() {
    let jsonPetParser = JsonPetsParser(forPetsRepository: petsRepository, withFileName: "RuPets", andType: "json")
      jsonPetParser.populateManagedObjectContextWithJsonPetData()
  }
  
 }
 
 extension TabBarController: UITabBarControllerDelegate {
  
  func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    if let viewControllers = tabBarController.viewControllers {
      if viewController == viewControllers[2] {
        return false
      }
    }
    return true
  }
  
  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    
    
    if let viewController = viewController as? UINavigationController {
      if let destinationVC = viewController.viewControllers.first as? PetsRepositorySettable {
        destinationVC.petsRepository = petsRepository
      }
    }
    
    
    
    // ScheduleViewController is inside UINavigationController
    if let viewController = viewController as? UINavigationController {
      
      if let destinationVC = viewController.viewControllers.first as? ScheduleViewController {
        destinationVC.setPetsRepository(petsRepository)
      }
    }
    
  }
 }
 
extension TabBarController: PetsRepositorySettable {
  func setPetsRepository(petsRepository: PetsRepository) {
    self.petsRepository = petsRepository
  }
}
 
 
 
