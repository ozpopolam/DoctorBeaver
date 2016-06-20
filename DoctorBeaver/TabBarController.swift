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
  let petsTabInd = 0 // tab with PetsViewController
  let scheduleTabInd = 1 // tab with ScheduleViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureTabBar() // set visual part
    
    if firstEverLaunch() {
      preparePetsRepositoryForUse()
      populateManagedObjectContextWithJsonPetData()
    }
    
    self.selectedIndex = scheduleTabInd // begin with schedule tab
    self.selectedIndex = petsTabInd // begin with pets tab
    delegate = self
    tabBarController(self, didSelectViewController: viewControllers![selectedIndex])
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func firstEverLaunch() -> Bool {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let key = "firstLaunchDidHappen"
    let firstLaunchDidHappen = defaults.boolForKey(key)
  
    if !firstLaunchDidHappen {
      defaults.setBool(true, forKey: key)
      print("firstLaunchEver")
      return true
    } else {
      print("notFirstLaunch")
      return false
    }
  }
  
  func configureTabBar() {
    UITabBar.appearance().barTintColor = VisualConfiguration.lightOrangeColor // tab bar background color
    
    // tab bar font
    let tabBarAppearance = UITabBarItem.appearance()
    let font = VisualConfiguration.tabBarFont
    tabBarAppearance.setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
    
    // tab bar font color
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: VisualConfiguration.darkGrayColor], forState: .Normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: VisualConfiguration.blackColor], forState: .Selected)
    
    let tabBatTitles = ["Звери", "Расписание"]
    
    // images for tab bar buttons' states
    let imagesNames = ["pets", "schedule"] // normal images
    var tabBarImages = [UIImage]()
    
    for imageName in imagesNames {
      if let image = UIImage(named: imageName) {
        let scaledImage = image.ofSize(VisualConfiguration.barIconSize)
        tabBarImages.append(scaledImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
      }
    }
    
    let selectedImagesNames = ["petsSelected", "scheduleSelected"] // selected images
    var tabBarSelectedImages = [UIImage]()
    
    for selectImageName in selectedImagesNames {
      if let image = UIImage(named: selectImageName) {
        let scaledImage = image.ofSize(VisualConfiguration.barIconSize)
        tabBarSelectedImages.append(scaledImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal))
      }
    }
    
    if let tabBarItems = tabBar.items { // append prepared images
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
}
 
extension TabBarController: UITabBarControllerDelegate {
  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    
    if let viewControllers = tabBarController.viewControllers {
      
      if viewController == viewControllers[petsTabInd] {
        // pets are about to be shown -> schedule should start observing repository's changing that can be made in pets
        
        if let navController = viewControllers[petsTabInd] as? UINavigationController, let destinationViewController = navController.viewControllers.first as? PetsViewController {
          destinationViewController.setPetsRepository(petsRepository)
        }
        
        if let navController = viewControllers[scheduleTabInd] as? UINavigationController, let destinationViewController = navController.viewControllers.first as? ScheduleViewController {
          petsRepository.addObserver(destinationViewController)
        }
        
      } else if viewController == viewControllers[scheduleTabInd] {
        // pets are about to be hidden -> schedule should stop observing repository's changing
        
        if let navController = viewControllers[scheduleTabInd] as? UINavigationController, let destinationViewController = navController.viewControllers.first as? ScheduleViewController {
          destinationViewController.setPetsRepository(petsRepository)
          petsRepository.removeObserver(destinationViewController)
        }
      }
    }
  }
}
 
extension TabBarController: PetsRepositorySettable {
  func setPetsRepository(petsRepository: PetsRepository) {
    self.petsRepository = petsRepository
  }
}

// MARK: _HELPERS
extension TabBarController {
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
 
