//
//  TaskTypeItemBasicValues+CoreDataProperties.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.05.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TaskTypeItemBasicValues {

    @NSManaged var taskNamePlaceholder: String?
    @NSManaged var startDateTitle: String?
    @NSManaged var daysOptions: String?
    @NSManaged var timesOptions: String?
    @NSManaged var endDaysOrTimes: String?
    @NSManaged var typeItem: NSSet?

}
