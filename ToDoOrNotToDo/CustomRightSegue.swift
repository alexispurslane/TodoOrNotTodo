//
//  CustomRightSegue.swift
//  ToDoOrNotToDo
//
//  Created by Christopher Dumas on 3/6/15.
//  Copyright (c) 2015 TitoniumWorks. All rights reserved.
//

import UIKit

class CustomRightSegue: UIStoryboardSegue {
  override func perform() {
    let transition = CATransition()
    transition.duration = 0.3;
    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    self.sourceViewController.view??.window?.layer.addAnimation(transition, forKey: "slideBack")
    
    self.sourceViewController.presentViewController(self.destinationViewController as UIViewController, animated: false, completion: nil)
  }
}
