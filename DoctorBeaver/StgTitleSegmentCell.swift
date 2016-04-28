//
//  SettingTitleSegmentCell.swift
//  DoctorBeaver
//
//  Created by Anastasia Stepanova-Kolupakhina on 29.02.16.
//  Copyright © 2016 Anastasia Stepanova-Kolupakhina. All rights reserved.
//

import UIKit

protocol DoubleOptionSegmControlDelegate: class {
  func segmControl(sgCtrl: UISegmentedControl, didSelectSegment segment: Int)
}

class StgTitleSegmentCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var hideShowSgCtrl: HideShowSegmentedControl!
  
  weak var delegate: DoubleOptionSegmControlDelegate?
  
  var firstOption: Bool {
    get {
      return hideShowSgCtrl.selectedSegmentIndex == 0
    }
  }
  
  var secondOption: Bool {
    get {
      return hideShowSgCtrl.selectedSegmentIndex == 1
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    hideShowSgCtrl.setTitleTextAttributes([NSFontAttributeName: VisualConfiguration.segmentFont], forState: .Normal)
    hideShowSgCtrl.tintColor = VisualConfiguration.segmentTintColor
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func configure(withValues values: [String], andSelectedSegment index: Int) {
    if hideShowSgCtrl.numberOfSegments == values.count {
      for ind in 0..<values.count {
        hideShowSgCtrl.setTitle(values[ind], forSegmentAtIndex: ind)
      }
    }
    hideShowSgCtrl.selectedSegmentIndex = index
  }
  
  @IBAction func selectSegment(sender: UISegmentedControl) {
    delegate?.segmControl(sender, didSelectSegment: sender.selectedSegmentIndex)
  }
  
}
