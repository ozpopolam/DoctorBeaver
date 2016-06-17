//
//  ScheduleViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 07.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit
import CoreData

class ScheduleViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: DecoratedNavigationBarView!
  
  @IBOutlet weak var petImageView: UIImageView!
  @IBOutlet weak var petBorderView: UIImageView!
  @IBOutlet weak var petNameLabel: UILabel!
  @IBOutlet weak var petsNamesText: UITextView!
  
  @IBOutlet weak var warningView: UIView!
  @IBOutlet weak var warningLabel: UILabel!
  
  @IBOutlet weak var calendarContainerView: UIView!
  @IBOutlet weak var tableContainerView: UIView!
  
  var petsRepository: PetsRepository!
  var viewWasLoadedWithUpToDatePetsRepository = false
  
  
  var calendarButton: UIButton!
  // дата для отображения расписания
  var date = NSDate()
  
  // питомцы, которые будут отражены в расписании
  var selectedPets = [Pet]()
  
  let filterSegueId = "filterSegue"

  override func viewDidLoad() {
    super.viewDidLoad()
    
    fakeNavigationBar.titleLabel.font = VisualConfiguration.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Расписание".uppercaseString
    
    // два варианта расположения кнопки календаря - слева
    fakeNavigationBar.setButtonImage("calendar", forButton: .Left, withTintColor: UIColor.fogColor())
    fakeNavigationBar.leftButton.addTarget(self, action: #selector(showCalendar(_:)), forControlEvents: .TouchUpInside)
    
    // справа от центра
    fakeNavigationBar.setButtonImage("calendar", forButton: .CenterRight, withTintColor: UIColor.fogColor())
    fakeNavigationBar.centerRightButton.addTarget(self, action: #selector(showCalendar(_:)), forControlEvents: .TouchUpInside)
    
    // кнопка фильтра
    fakeNavigationBar.setButtonImage("filter", forButton: .Right, withTintColor: UIColor.fogColor())
    fakeNavigationBar.rightButton.addTarget(self, action: #selector(showFilter(_:)), forControlEvents: .TouchUpInside)
    
    // поначалу прячем все кнопки
    fakeNavigationBar.hideAllButtons()
    
//    // проверяем, загружен ли контекст
//    if viewIsReadyToBeLoadedWithPetsRepository() {
//      fullyReloadSchedule()
////      // register ScheduleViewController as PetsRepository'observer
////      petsRepository.addObserver(self)
//    }
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем navigation bar
    navigationController?.navigationBarHidden = true
    
    if viewIsReadyToBeLoadedWithPetsRepository() {
      fullyReloadSchedule()
    }
  }
  
  // textView указывает на первую строку
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    petsNamesText.setContentOffset(CGPointZero, animated: false)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  deinit {
    petsRepository.removeObserver(self) // remove observer before deinitialization
  }
  
  func setPetsRepository(petsRepository: PetsRepository) {
    if self.petsRepository == nil {
      self.petsRepository = petsRepository
    }
    if viewIsReadyToBeLoadedWithPetsRepository() {
      fullyReloadSchedule()
    }
  }
  
  // проверяем, можно ли обновить view данными из managedContext
  func viewIsReadyToBeLoadedWithPetsRepository() -> Bool {
    if isViewLoaded() && petsRepository != nil && !viewWasLoadedWithUpToDatePetsRepository {
      viewWasLoadedWithUpToDatePetsRepository = true
      return true
    } else {
      return false
    }
  }

  // заполняем таблицу с нуля
  // настраиваем внешний вид по инфо питомца и инициируем отображение расписания
  func fullyReloadSchedule() {
    
    // настраиваем расположение кнопок и по необходимости выводим предупреждающие надписи
    if petsRepository.countAll(Pet.entityName) == 0 {
      // не зарегестрировано ни одного питомца
      // прячем все кнопки с nav bar
      fakeNavigationBar.hideAllButtons()
      
      // очищаем информацию о питомце
      emptyPetInfo()
      
      // показываем предупреждение
      showWarningMessage("попробуйте сначала добавить хотя бы одного питомца")
      
    } else {
      reloadSchedule()
    }
    
  }
  
  // загружаем только выбранных питомцев
  func reloadSchedule(withNoFetchRequest noFetchRequest: Bool = false) {
    
    // прячем view с ошибкой
    hideWarningMessage()
    
    if !noFetchRequest {
      // загружаем питомцев, которых отметил пользователь
      selectedPets = petsRepository.fetchAllSelectedPets()
    }
    
    if selectedPets.count == 0 {
      // ни одного питомца не было выбрано для отображения
      // оставляем только кнопку фильтра, расположенную справа
      fakeNavigationBar.showButton(.Right)
      fakeNavigationBar.hideButton(.CenterRight)
      fakeNavigationBar.hideButton(.Left)
      
      // очищаем информацию о питомце
      emptyPetInfo()
      
      // показываем предупреждение
      showWarningMessage("попробуйте сначала выбрать питомца")
      
    } else {
      if selectedPets.count == 1 {
        // питомец только один
        // распологаем кнопку календаря и показываем кнопку фильтра
        fakeNavigationBar.showButton(.Right)
        fakeNavigationBar.showButton(.CenterRight)
        calendarButton = fakeNavigationBar.centerRightButton
        fakeNavigationBar.hideButton(.Left)
        
        // показываем информацию о нем
        showPetInfo(selectedPets[0])
        
      } else {
        // много питомцев
        // распологаем кнопку календаря и показываем кнопку фильтра
        fakeNavigationBar.showButton(.Right)
        fakeNavigationBar.showButton(.Left)
        calendarButton = fakeNavigationBar.leftButton
        fakeNavigationBar.hideButton(.CenterRight)
        
        // показываем информацию о них
        showPetsInfo(selectedPets)
      }

      reloadScheduleTable(forDate: date)
    }
  }
  
  func reloadScheduleTable(forDate date: NSDate) {
    if let viewController = self.childViewControllers[1] as? ScheduleTableViewController {
      viewController.setSchedule(withPetsRepository: petsRepository, withPets: selectedPets, andDate: date)
    }
  }
  
  func updateCalendar(forDate date: NSDate) {
    if let viewController = self.childViewControllers[0] as? CalendarController {
      viewController.update(withDate: date)
    }
  }
  
  // показываем view с предупреждением
  func showWarningMessage(message: String) {
    calendarContainerView.hidden = true
    tableContainerView.hidden = true
    warningLabel.text = message
  }
  
  // прячем view с предупреждением
  func hideWarningMessage() {
    if calendarContainerView.hidden {
      calendarContainerView.hidden = false
    }
    if tableContainerView.hidden {
      tableContainerView.hidden = false
    }
    warningLabel.text = ""
  }
  
  // очищаем информацию о питомце
  func emptyPetInfo() {
    petNameLabel.hidden = true
    petsNamesText.hidden = true
    setPetImageWithBorder(nil)
  }
  
  // показываем информацию о питомце
  func showPetInfo(pet: Pet) {
    petNameLabel.hidden = false
    petNameLabel.text = pet.name
    setPetImageWithBorder(pet.image)
    
    petsNamesText.hidden = true
  }
  
  // показываем информацию о нескольких питомцах
  func showPetsInfo(pets: [Pet]) {
    // убираем картинку с питомцем
    setPetImageWithBorder(nil)
    
    // формируем строку с запятыми и пробелами
    var petsNames = ""
    for ind in 0..<pets.count {
      petsNames += pets[ind].name
      if ind != pets.count  - 1 {
        petsNames += ", "
      }
    }
    petsNamesText.hidden = false
    petsNamesText.text = petsNames
    petsNamesText.font = VisualConfiguration.petNameFont
    petsNamesText.textAlignment = .Center
    
    petNameLabel.hidden = true
    
  }
  
  // устанавливаем картинку питомца и добавляем рамку
  func setPetImageWithBorder(image: UIImage?) {
    if let image = image {
      // есть изображение - устанавливаем его
      
      petImageView.image = image
      petImageView.layer.cornerRadius = petImageView.frame.size.width / VisualConfiguration.cornerProportion
      petImageView.clipsToBounds = true
      
      petBorderView.layer.cornerRadius = petBorderView.frame.size.width / VisualConfiguration.cornerProportion
      petBorderView.hidden = false
      
    } else {
      // изображения нет
      petImageView.image = nil
      petBorderView.hidden = true
    }
    
  }
  
  // была нажата кнопка "Календарь"
  func showCalendar(sender: UIButton) {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let cpc = storyboard.instantiateViewControllerWithIdentifier("CalendarPopoverController") as? CalendarPopoverController {
      cpc.modalPresentationStyle = .Popover
      
      cpc.delegate = self
      cpc.date = date
      
      if let popoverController = cpc.popoverPresentationController {
        popoverController.delegate = self
        popoverController.sourceView = calendarButton.superview
        popoverController.backgroundColor = UIColor.whiteColor()
        
        let shiftedY: CGFloat = calendarButton.frame.origin.y - calendarButton.frame.size.height / 4
        let frame = CGRect(x: calendarButton.frame.origin.x, y: shiftedY, width: calendarButton.frame.size.width, height: calendarButton.frame.size.height)
        popoverController.sourceRect = frame
      }
      
      presentViewController(cpc, animated: true, completion: nil)
      
      var width = view.frame.width
      if let facw = cpc.activeWidth {
        if facw < width {
          width = facw
        }
      }
      var height = view.frame.height
      if let fach = cpc.activeHeight {
        if fach < height {
          height = fach
        }
      }
      
      cpc.preferredContentSize = CGSize(width: width, height: height)
      
    }
    
  }
  
  // была нажата кнопка "Фильтр"
  func showFilter(sender: UIButton) {
    performSegueWithIdentifier(filterSegueId, sender: self)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == filterSegueId {
      if let destinationVC = segue.destinationViewController as? FilterViewController {
        destinationVC.delegate = self
        destinationVC.setPetsRepository(petsRepository)
      }
    }
  }
  
}

extension ScheduleViewController: PetsRepositoryStateObserver {
  func petsRepositoryDidChange(repository: PetsRepositoryStateSubject) {
    viewWasLoadedWithUpToDatePetsRepository = false
  }
}

// высплывающий календарь
extension ScheduleViewController: UIPopoverPresentationControllerDelegate {
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
    
    if let cpc = popoverPresentationController.presentedViewController as? CalendarPopoverController {
      let selectedDate = cpc.datePicker.date
      reloadScheduleTable(ForNewSelectedDate: selectedDate)
    }
  }
  
  func reloadScheduleTable(ForNewSelectedDate selectedDate: NSDate) {
    if DateHelper.calendar.compareDate(date, toDate: selectedDate, toUnitGranularity: .Day) != .OrderedSame {
      date = selectedDate
      updateCalendar(forDate: date)
      reloadScheduleTable(forDate: selectedDate)
    }
  }
  
}

// дата из календаря
extension ScheduleViewController: CalendarPopoverControllerDelegate {
  func calendar(cpc: CalendarPopoverController, didPickDate date: NSDate) {
    dismissViewControllerAnimated(true, completion: nil)
    reloadScheduleTable(ForNewSelectedDate: date)
  }
  
  func calendarDidCancel(cpc: CalendarPopoverController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// фильтрация питомцев по выбранности
extension ScheduleViewController: FilterDelegate {
  func filter(flt: FilterViewController, didPickPets pets: [Pet]) {
    dismissViewControllerAnimated(true, completion: nil)
    
    // питомцы, отмеченные галочкой для показа
    selectedPets = pets
    reloadSchedule(withNoFetchRequest: true)
  }
  
  func filterDidCancel(flt: FilterViewController) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}