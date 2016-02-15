//
//  ScheduleViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 07.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController {
  
  
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  @IBOutlet weak var petImageView: UIImageView!
  @IBOutlet weak var petBorderView: UIImageView!
  @IBOutlet weak var petNameLabel: UILabel!
  @IBOutlet weak var petsNamesText: UITextView!
  @IBOutlet weak var noScheduleView: UIView!
  @IBOutlet weak var noScheduleLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  
  // все питомцы
  var pets = [Pet]()
  // питомцы, которые будут отражены в расписании
  var selectedPets = [Pet]()
  
  let segueFilter = "segueFilter"
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    testData()
    
    for pet in pets {
      // выбираем питомцев, которых будем отражать в расписании
      if pet.selected {
        selectedPets.append(pet)
      }
    }

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
  }
  
  // textView указывает на первую строку
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    petsNamesText.setContentOffset(CGPointZero, animated: false)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // настраиваем картинку питомца, имя, кнопку фильтра, подсказку по пустому расписанию
  func configureView() {
    
    fakeNavigationBar.setButtonIcon("filter", forButton: .Right, ofState: .Normal)
    fakeNavigationBar.setButtonIcon("filterHighlighted", forButton: .Right, ofState: .Highlighted)
    fakeNavigationBar.rightButton.addTarget(self, action: "showFilter:", forControlEvents: .TouchUpInside)
    
    let vsCnfg = VisualConfiguration()
    fakeNavigationBar.titleLabel.font = vsCnfg.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Расписание".uppercaseString
    
    if selectedPets.count == 0 {
      // ни одного питомца не было выбрано для отображения
      setPetImageWithBorder("noPet")
      petNameLabel.text = ""
      petsNamesText.text = ""
      
      // будем показывать view с предупреждением
      if noScheduleView.hidden == true {
        noScheduleView.hidden = false
      }
    } else {
      // выбран только один питомец для отображения расписания
      if selectedPets.count == 1 {
        setPetImageWithBorder(selectedPets[0].image)
        petsNamesText.text = ""
        petNameLabel.text = selectedPets[0].name
        
      } else {
        // нужно отразить несколько питомцев в расписании
        setPetImageWithBorder("manyPets")
        // формируем строку с запятыми и пробелами
        var petsNames = ""
        for ind in 0..<selectedPets.count {
          petsNames += selectedPets[ind].name
          if ind != selectedPets.count  - 1 {
            petsNames += ", "
          }
        }
        
        petNameLabel.text = ""
        petsNamesText.text = petsNames
        petsNamesText.textAlignment = .Center
        petsNamesText.font = UIFont(name: "Noteworthy-Light", size: 22.0)!
      }
      
      // прячем view с предупреждением
      if noScheduleView.hidden == false {
        noScheduleView.hidden = true
      }
    
    
   

      
//      if pets == nil {
//        // питомцев вообще нет
//        noScheduleLabel.text = "попробуйте сначала добавить питомца"
//        
//      } else {
//        // есть из кого выбирить
//        noScheduleLabel.text = "попробуйте сначала выбрать питомца"
//      }
    }
  }
  
  // картинка в белой рамке
  func setPetImageWithBorder(image: String) {
    
    if let image = UIImage(named: image) {
      petImageView.image = image
      petImageView.layer.cornerRadius = petImageView.frame.size.width / 2
      petImageView.clipsToBounds = true
      
      petBorderView.layer.cornerRadius = petBorderView.frame.size.width / 2
      petBorderView.clipsToBounds = true
    } else {
      petImageView.image = nil
      petBorderView.image = nil
    }
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == segueFilter {
      
      if let destination = segue.destinationViewController as? FilterViewController {
        destination.pets = pets
        destination.delegate = self
      }
      
    }
    
    if segue.identifier == "segueScheduleTableViewController" {
      if let view = segue.destinationViewController as? ScheduleTableViewController {
        view.pets = selectedPets
        
      }
    }
  }
  
  func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
  }
  

  
  
  
  // показываем filter view
  func showFilter(sender: UIButton) {
    performSegueWithIdentifier("segueFilter", sender: self)
  }
  

////////////////
  func testData() {
    pets = [Pet(withName: "Пёс", andWithImage: "dog")]
    pets.append(Pet(withName: "Кот", andWithImage: "cat"))
    
    var tasks = [Task]()
    tasks.append(Task(withName: "Дуовит", withIcon: "vitamin", withDescription: "1 таблетка", withTime: 2))
    tasks.append(Task(withName: "Ринза", withIcon: "pill", withDescription: "1/3 таблетки", withTime: 13))
    tasks.append(Task(withName: "Эвлар", withIcon: "vitamin", withDescription: "1/2 таблетки", withTime: 17))
    tasks.append(Task(withName: "Селмевит", withIcon: "vitamin", withDescription: "1 таблетка", withTime: 23))
    tasks.append(Task(withName: "Coldrex", withIcon: "pill", withDescription: "1 таблетка", withTime: 9))
    tasks.append(Task(withName: "Супрадин", withIcon: "vitamin", withDescription: "1/3 таблетки", withTime: 16))
    tasks.append(Task(withName: "Эргоферон", withIcon: "pill", withDescription: "1 таблетка", withTime: 17))
    tasks.append(Task(withName: "Колдакт", withIcon: "pill", withDescription: "1/2 таблетки", withTime: 11))
    tasks.append(Task(withName: "Дуовит2", withIcon: "vitamin", withDescription: "1 таблетка", withTime: 2))
    tasks.append(Task(withName: "Ринза2", withIcon: "pill", withDescription: "1/3 таблетки", withTime: 13))
    tasks.append(Task(withName: "Эвлар2", withIcon: "vitamin", withDescription: "1/2 таблетки", withTime: 17))
    
    for ind in 0..<tasks.count {
      if ind % 2 == 0 {
        pets[0].addNewTask(tasks[ind])
      } else {
        pets[1].addNewTask(tasks[ind])
      }
    }
    
  }
  
  func testData2(c: Int) {
//    let names = ["Пёс", "Собакевич", "Мяуч", "Зоя", "Курочка"]
//    switch c {
//    case 0: selectedPets = nil
//    pets = nil
//      
//    case 1: selectedPets = nil
//    pets = [Pet(withName: names[0], andWithImage: "dog1")]
//      
//    case 2: selectedPets = [Pet(withName: names[0], andWithImage: "dog1")]
//    default:
//      for ind in 0..<5 {
//        selectedPets?.append(Pet(withName: names[ind], andWithImage: "noPet"))
//      }
//    }
  }
  
}

extension ScheduleViewController: FilterViewControllerDelegate {
  func filter(picker: FilterViewController, didPickPets pets: [Pet]) {
    selectedPets = []
    for pet in pets {
      // выбираем питомцев, которых будем отражать в расписании
      if pet.selected {
        selectedPets.append(pet)
      }
    }
    if let scheduleTableViewController = self.childViewControllers[0] as? ScheduleTableViewController {
      scheduleTableViewController.pets = selectedPets
      scheduleTableViewController.reloadData()
    }
    

    configureView()
    
    navigationController?.popViewControllerAnimated(true) 
  }
}









