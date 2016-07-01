//
//  PetBasicValues.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 16.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation
import RealmSwift

class PetBasicValues: Object {
  
  dynamic var basicName = ""
  dynamic var namePlaceholder = ""
  dynamic var separator = ""
  
  dynamic var sectionTitles = ""
  dynamic var selectedTitle = ""
  dynamic var selectedForInitialization = true
  
  let pets = LinkingObjects(fromType: Pet.self, property: "basicValues")
}
