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
  
  var managedContext: NSManagedObjectContext!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("It's starter")
    
    // настраиваем внешний вид Tab Bar
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

    populateManagedObjectContextWithJsonPetData()
    
    // начинаем со вкладки расписания
    self.selectedIndex = 1
    delegate = self
    tabBarController(self, didSelectViewController: viewControllers![selectedIndex])
  }
  
  func pmt(task: Task) {
    
    var s: String = ""
    for mft in task.minutesForTimes {
      s += " "
      
      let h = mft / 60
      if h < 10 {
        s += "0"
      }
      s += "\(h):"
      
      let m = mft % 60
      if m < 10 {
        s += "0"
      }
      s += "\(m)"
    }
    print("   timesPerDay: \(task.timesPerDay)")
    print("   minutesForTimes: [" + s + " ]")
    print("")
    
  }
  
  func pdt(task: Task) {
    
    var s: String = ""
    for dose in task.doseForTimes {
      s += " "
      
      s += "\(dose)"
    }
    print("   timesPerDay: \(task.timesPerDay)")
    print("   doseForTimes: [" + s + " ]")
    print("")
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func populateManagedObjectContextWithJsonPetData(doItNow: Bool = true) {
    if doItNow {
      let jsonPetParser = JsonPetParser(withFileName: "Pets", andType: "json")
      jsonPetParser.populateManagedObjectContextWithJsonPetData(managedContext)
    }
  }
  
 }
 
 extension TabBarController: UITabBarControllerDelegate {
  func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    
    // "Расписание" внутри UINavigationController
    if let viewController = viewController as? UINavigationController {
      
      if let destinationVC = viewController.viewControllers.first as? ManagedObjectContextSettableAndLoadable {
        destinationVC.setManagedObjectContext(managedContext)
      }
    } else {
      if let viewController = viewController as? ManagedObjectContextSettable {
        viewController.setManagedObjectContext(managedContext)
      }
    }
    
  }
 }
 
 // обращения с CoreData
 extension TabBarController: ManagedObjectContextSettable {
  // устанавливаем ManagedObjectContext
  func setManagedObjectContext(managedContext: NSManagedObjectContext) {
    self.managedContext = managedContext
  }
 }
 
 
 
