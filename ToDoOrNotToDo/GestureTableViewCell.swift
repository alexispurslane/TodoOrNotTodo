//
//  GestureTableViewCell.swift
//  ToDoOrNotToDo
//
//  Created by Christopher Dumas on 3/2/15.
//  Copyright (c) 2015 TitoniumWorks. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
  // indicates that the given item has been deleted
  func todoItemDeleted(todoItem: TodoItem)
  func todoItemChecked(todoItem: TodoItem)
}

class GestureTableViewCell: UITableViewCell {
  
  var originalCenter = CGPoint()
  var deleteOnDragRelease = false, completeOnDragRelease = false, deleting = false, completing = false
  var delegate: TableViewCellDelegate?
  var todoItem: TodoItem?
  let itemCompleteLayer = CALayer()
  let itemDeleteLayer = CALayer()
  let itemDefaultLayer = CALayer()
  
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    // ensure the gradient layer occupies the full bounds
    itemDeleteLayer.frame = bounds
    itemCompleteLayer.frame = bounds
    itemDefaultLayer.frame = bounds
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.backgroundColor = UIColor(red: 73/255, green: 109/255, blue: 137/255, alpha: 1)
    
    itemCompleteLayer = CALayer(layer: layer)
    itemCompleteLayer.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.0,
      alpha: 0.8).CGColor
    itemCompleteLayer.hidden = true
    layer.insertSublayer(itemCompleteLayer, atIndex: 0)
    
    itemDeleteLayer = CALayer(layer: layer)
    itemDeleteLayer.backgroundColor = UIColor(red: 0.7, green: 0.0, blue: 0.0,
      alpha: 0.8).CGColor
    itemDeleteLayer.hidden = true
    layer.insertSublayer(itemDeleteLayer, atIndex: 0)
    
    var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
    recognizer.delegate = self
    addGestureRecognizer(recognizer)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  //MARK: - horizontal pan gesture methods UIColor(red: 73, green: 109, blue: 137, alpha: 1)
  func handlePan(recognizer: UIPanGestureRecognizer) {
    // 1
    if recognizer.state == .Began {
      // when the gesture begins, record the current center location
      originalCenter = center
    }
    // 2
    if recognizer.state == .Changed {
      let translation = recognizer.translationInView(self)
      center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
      // has the user dragged the item far enough to initiate a delete/complete?
      deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
      deleting = frame.origin.x < -frame.size.width / 2.0
      completing = frame.origin.x > frame.size.width / 2.0 || self.todoItem!.completed
      completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
      itemCompleteLayer.hidden = !completing
      itemDeleteLayer.hidden = !deleting
      self.backgroundColor = UIColor.clearColor()
    }
    // 3
    if recognizer.state == .Ended {
      itemDeleteLayer.hidden = true
      // the frame this cell had before user dragged it
      let originalFrame = CGRect(x: 0, y: frame.origin.y,
        width: bounds.size.width, height: bounds.size.height)
      if deleteOnDragRelease {
        if delegate != nil && todoItem != nil {
          // notify the delegate that this item should be deleted
          delegate!.todoItemDeleted(todoItem!)
        }
      } else if completeOnDragRelease {
        println("Completed!!")
        if todoItem != nil {
          todoItem!.completed = true
          delegate!.todoItemChecked(todoItem!)
        }
        self.accessoryType = .Checkmark
        itemCompleteLayer.hidden = false
        UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
      } else {
        // if the item is not being deleted, snap back to the original location
        self.backgroundColor = UIColor(red: 73/255, green: 109/255, blue: 137/255, alpha: 1)
        UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
      }
    }
  }
  
  override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translationInView(superview!)
      if fabs(translation.x) > fabs(translation.y) {
        return true
      }
      return false
    }
    return false
  }
}
