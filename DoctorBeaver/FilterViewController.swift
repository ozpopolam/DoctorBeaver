//
//  FilterViewController.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 11.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol FilterViewControllerDelegate {
  func filter(picker: FilterViewController, didPickPets pets: [Pet])
}

class FilterViewController: UIViewController {
  
  @IBOutlet weak var fakeNavigationBar: FakeNavigationBarView!
  var pets = [Pet]()
  var delegate: FilterViewControllerDelegate?

  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
    
    
    
  }
  
  func configureView() {
    let vsCnfg = VisualConfiguration()
    fakeNavigationBar.titleLabel.font = vsCnfg.navigationBarFont
    fakeNavigationBar.titleLabel.text = "Фильтр".uppercaseString
    
    fakeNavigationBar.setButtonIcon("cancel", forButton: .Left, ofState: .Normal)
    fakeNavigationBar.setButtonIcon("cancelHighlighted", forButton: .Left, ofState: .Highlighted)
    fakeNavigationBar.leftButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
    
    fakeNavigationBar.setButtonIcon("done", forButton: .Right, ofState: .Normal)
    fakeNavigationBar.setButtonIcon("doneHighlighted", forButton: .Right, ofState: .Highlighted)
    fakeNavigationBar.rightButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
  }
  
  
  func done(sender: UIButton) {
    delegate?.filter(self, didPickPets: pets)
  }
  
  func cancel(sender: UIButton) {
    navigationController?.popViewControllerAnimated(true)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    // прячем Navigation Bar
    navigationController?.navigationBarHidden = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
}

extension FilterViewController: UITableViewDataSource {
  
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("filterCell", forIndexPath: indexPath) as? FilterCell {
      let pet = pets[indexPath.row]
      cell.petImageView.image = UIImage(named: pet.image)
      cell.petNameLabel.text = pet.name
      cell.remainTasksLabel.text = "0 активных заданий"
      cell.checkmarkImageView.hidden = !pet.selected
      cell.selectView.hidden = pet.selected
      
      return cell
    
    }
    return UITableViewCell()
  }
}

extension FilterViewController: UITableViewDelegate {
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    if let cell = cell as? FilterCell {
      let pet = pets[indexPath.row]
      pet.selected = !pet.selected
      
      cell.checkmarkImageView.hidden = !pet.selected
      cell.selectView.hidden = pet.selected
    }
  }
  
}
