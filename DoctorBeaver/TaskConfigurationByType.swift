//
//  TaskConfigurationByType.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 01.04.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

class TaskConfigurationByType {
  let task: Task!
  
  init(task: Task) {
    self.task = task
  }
  
  // заголовки меню
  func sectionTitles() -> [String] {
    switch task.type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure:
      return ["", "Способ применения", "Длительность приема", "Особые указания"]
    case .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming:
      return ["", "", "Длительность приема", "Особые указания"]
    case .Error:
      return []
    }
  }
  
  // значения: раз в день
  func timesPerDayOptions() -> [String] {
    switch task.type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure:
      return ["1 раз", "2 раза", "3 раза", "4 раза", "5 раз", "6 раз"]
    case .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return []
    }
  }
  
  // время приема
  // заголовки
  func minutesForTimesTitle() -> String {
    switch task.type {
    case .Pill:
      return "Время приема"
    case .Injection:
      return "Время укола"
    case .Drops, .Ointment, .Mixture:
      return "Время лечения"
    case .Procedure:
      return "Время процедуры"
    case .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  // значения
  func minutesForTimesTitles() -> [String] {
    let minutesTitle = minutesForTimesTitle()
    if minutesTitle != "" {
      if task.timesPerDay == 1 {
        return ["Единственное"]
      } else {
        let adjectives = ["Первое", "Второе", "Третье", "Четвертое", "Пятое", "Шестое"]
        var titles: [String] = []
        for ind in 0..<task.timesPerDay {
          titles.append(adjectives[ind])
        }
        return titles
      }
    } else {
      return []
    }
  }
  
  
  // дозировка
  // заголовки
  func doseForTimesTitle() -> String {
    switch task.type {
    case .Pill, .Injection, .Drops, .Mixture:
      return "Дозировка"
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  // заголовки при нескольких вариантах дозировки
  func doseForTimesTitles() -> [String] {
    if task.timesPerDay == 1 {
      return ["Единственная"]
    } else {
      let adjectives = ["Первая", "Вторая", "Третья", "Четвертая", "Пятая", "Шестая"]
      var titles: [String] = []
      for ind in 0..<task.timesPerDay {
        titles.append(adjectives[ind])
      }
      return titles
    }
  }
  //значения
  func doseForTimesOptions() -> [[String]] {
    switch task.type {
    case .Pill:
      return [["", "1", "2", "3", "4", "5"],
        ["", "1/4", "1/3", "1/2", "2/3", "3/4"]]
    case .Injection:
      return [["", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
        ["", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9"]]
    case .Drops, .Mixture:
      var doses: [String] = []
      for i in 1...100 {
        doses.append(String(i))
      }
      return [doses]
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return []
    }
  }
  // для инициализации
  func doseForConfiguration() -> [String] {
    switch task.type {
    case .Pill:
      return ["1;"]
    case .Injection:
      return [";0.5"]
    case .Drops, .Mixture:
      return ["5"]
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return []
    }
  }
  // дозировка "1;1/4" -> ["1", "1/4"]
  func doseStringsFromDoseString(atIndex ind: Int = 0) -> [String] {
    switch task.type {
    case .Pill, .Injection:
      
      var str = ""
      var strs: [String] = []
      
      let doseForTimesCharacters = task.doseForTimes[ind].characters
      
      for d in doseForTimesCharacters {
        if d == task.doseSeparator {
          strs.append(str)
          str = ""
        } else {
          str += String(d)
        }
      }
      
      strs.append(str)
      return strs
      
    case .Drops, .Mixture:
      return [task.doseForTimes[ind]]
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return []
    }
  }
  // компонентная дозировка ["1", "1/4"] -> "1;1/4"
  func doseSeparatedString(fromStrings strings: [String]) -> String {
    switch task.type {
    case .Pill, .Injection:
      var ds = ""
      for ind in 0..<strings.count {
        if !strings[ind].isEmpty {
          if ind > 0 && !strings[ind - 1].isEmpty {
            ds.append(task.doseSeparator) // += String(task.doseSeparator)
          }
          ds += strings[ind]
        }
      }
      return ds
      
    case .Drops, .Mixture:
      return strings[0]
      
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  // печатная версия
  func doseString(atInd ind: Int = 0) -> String {
    switch task.type {
    case .Pill, .Injection:
      var ds = ""
      for s in task.doseForTimes[ind].characters {
        if s != task.doseSeparator {
          ds += String(s)
        } else {
          ds += " "
        }
      }
      return ds
      
    case .Drops, .Mixture:
      return task.doseForTimes[ind]
      
    case .Ointment, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  
  // особенности приема
  // заголовки
  func specialFeatureTitle() -> String {
    switch task.type {
    case .Pill, .Mixture:
      return "Когда принимать"
    case .Injection:
      return "Куда колоть"
    case .Drops:
      return "Куда капать"
    case .Ointment:
      return "Куда наносить"
    case .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  // значения
  func specialFeatureOptions() -> [String] {
    switch task.type {
    case .Pill, .Mixture:
      return ["до еды", "во время еды", "после еды", "независимо от еды"]
    case .Injection:
      return ["подкожно", "внутримышечно", "внутривенно"]
    case .Drops:
      return ["в уши", "в глаза", "в нос"]
    case .Ointment:
      return ["на кожу", "на раны", "на слизистые оболочки"]
    case .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return []
    }
  }
  // для инициализации
  func specialFeatureForConfiguration() -> String {
    switch task.type {
    case .Pill, .Mixture:
      return "независимо от еды"
    case .Injection:
      return "внутримышечно"
    case .Drops:
      return "в уши"
    case .Ointment:
      return "на кожу"
    case .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming, .Error:
      return ""
    }
  }
  
  // частота приема
  // заголовки
  func frequencySegmentTitles() -> [String] {
    return ["ежедневно", "периодически"]
  }
  // значения
  func frequencyOptions() -> [[String]] {
    switch task.type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure, .Vaccination, .WormTreatment, .FleaTreatment, .Grooming:
      var titles: [[String]] = [[], []]
      var title = ""
      
      for ind in 1...365 {
        title = String(ind) + " " + dayStringByIndex(ind)
        titles[0].append(title)
        titles[1].append("через " + title)
      }
      return titles
      
    case .Analysis, .Error:
      return []
    }
  }
  // число дней в читабельном формате
  func dayStringByIndex(index: Int) -> String {
    var divided = index
    if index > 100 {
      divided = divided % 100
    }
    
    if 11 <= divided && divided <= 19 {
      return "дней"
    }
    
    let remainder = index % 10
    switch remainder {
    case 1:
      return "день"
    case 2, 3, 4:
      return "дня"
    case 0, 5, 6, 7, 8, 9:
      return "дней"
    default:
      return ""
    }
  }
  
  // закончить
  // заголовки
  func endSegmentTitles() -> [String] {
    return ["через ? дней", "через ? раз", " в день "]
  }
  // значения
  func endOptions(byNewEndType endType: Task.EndType? = nil) -> [String] {
    switch task.type {
    case .Pill, .Injection, .Drops, .Ointment, .Mixture, .Procedure, .Vaccination, .Analysis, .WormTreatment, .FleaTreatment, .Grooming:
      
      var titles: [String] = []
      var title = ""
      
      var et: Task.EndType
      
      if let endType = endType {
        et = endType
      } else {
        et = task.endType
      }
      
      if et == .EndDays {
        for ind in 1...365 {
          title = String(ind) + " " + dayStringByIndex(ind)
          titles.append(title)
        }
        
      } else {
        for ind in 1...100 {
          title = String(ind) + " " + timeStringByIndex(ind)
          titles.append(title)
        }
        
      }
      return titles
    case .Error:
      return []
    }
  }
  // число раз в читабельном формате
  func timeStringByIndex(index: Int) -> String {
    var divided = index
    if index > 100 {
      divided = divided % 100
    }
    
    if 11 <= divided && divided <= 19 {
      return "раз"
    }
    
    let remainder = index % 10
    switch remainder {
    case 2, 3, 4:
      return "раза"
    case 0, 1, 5, 6, 7, 8, 9:
      return "раз"
    default:
      return ""
    }
  }
  
}
