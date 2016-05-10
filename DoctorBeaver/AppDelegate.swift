//
//  AppDelegate.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 06.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

// обращения с CoreData
protocol ManagedObjectContextSettable: class {
  // устанавливаем ManagedObjectContext
  var managedContext: NSManagedObjectContext! { get set }
  func setManagedObjectContext(managedContext: NSManagedObjectContext)
}

protocol ManagedObjectContextSettableAndLoadable: ManagedObjectContextSettable {
  // проверяем, можно ли обновить view данными из managedContext
  var viewWasLoadedWithManagedContext: Bool { get set }
  func viewIsReadyToBeLoaded(withManagedContext managedContext: NSManagedObjectContext?) -> Bool
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  lazy var coreDataStack = CoreDataStack()
  
  let petsRepository = PetsRepository(withModelName: "DoctorBeaver")
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    if let viewController = window!.rootViewController as? ManagedObjectContextSettable {
      viewController.setManagedObjectContext(coreDataStack.context)
    }
    
    if let viewController = window!.rootViewController as? TabBarController {
      viewController.petsRepository = petsRepository
    }
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //coreDataStack.context.saveOrRollback()
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //coreDataStack.context.saveOrRollback()
  }
  
}



