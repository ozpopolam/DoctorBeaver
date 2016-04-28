//
//  TaskType.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 20.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import Foundation

enum TaskType: Int {
  
  case Pill = 0 // таблетка
  case Injection // укол
  case Drops // капли
  case Ointment // мазь
  case Mixture // микстура
  case Procedure // процедура
  case Vaccination // вакцина
  case Analysis // анализ
  case WormTreatment // от глистов
  case FleaTreatment // от блох
  case Grooming // внешний вид
  
  case Error = -1 // ошибка
  
  func toString() -> String {
    switch self {
    case Pill:
      return "Таблетка"
    case Injection:
      return "Укол"
    case Drops:
      return "Капли"
    case Ointment:
      return "Мазь"
    case Mixture:
      return "Микстура"
    case Procedure:
      return "Процедура"
    case Vaccination:
      return "Вакцина"
    case Analysis:
      return "Анализ"
    case WormTreatment:
      return "От глистов"
    case FleaTreatment:
      return "От блох"
    case Grooming:
      return "Внешний вид"
    case Error:
      return "Ошибка"
    }
  }
  
  // имя иконки лечения по типу лечения
  func iconName() -> String {
    var name: String
    switch self {
    case .Pill:
      name = "pill"
    case .Injection:
      name = "injection"
    case .Drops:
      name = "drops"
    case Ointment:
      name = "ointment"
    case Mixture:
      name = "mixture"
    case Procedure:
      name = "procedure"
    case Vaccination:
      name = "vaccination"
    case Analysis:
      name = "analysis"
    case WormTreatment:
      name = "wormTreatment"
    case FleaTreatment:
      name = "fleaTreatment"
    case Grooming:
      name = "grooming"
    default:
      name = "error"
    }
    return name
  }
  
  func doseUnit() -> String {
    switch self {
    case Pill:
      return "табл."
    case Injection, Mixture:
      return "мл."
    case Drops:
      return "капл."
    case Ointment, Procedure, Vaccination, Analysis, WormTreatment, FleaTreatment, Grooming, Error:
      return ""
    }
  }
  
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
  
  
  
  
  func endInitialTitle(ofEndType type: Int) -> String {
    var title = ""
    if type == 0 {
      title = String(1) + " " + dayStringByIndex(1)
    } else if type == 1 {
      title = String(1) + " " + timeStringByIndex(1)
    }
    
    return title
  }
  
  

  
}


//switch self {
//case Pill:
//case Injection:
//case Drops:
//case Ointment:
//case Mixture:
//case Procedure:
//case Vaccination:
//case Analysis:
//case WormTreatment:
//case FleaTreatment:
//case Grooming:
//}