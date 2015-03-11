//
//  SettingsViewController.swift
//  ToDoOrNotToDo
//
//  Created by Christopher Dumas on 3/2/15.
//  Copyright (c) 2015 TitoniumWorks. All rights reserved.
//

import UIKit
struct TodoItemStruct {
  var text = ""
  var urgency = "Normal"
  var shouldBeDoneBy: NSDate? = nil
  var completed = false
}
class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
  @IBOutlet weak var navigationBar: UINavigationBar!
  var prevousView: UIViewController = UIViewController()
  @IBOutlet weak var urgencyPicker: UIPickerView!
  var pickerData = ["Low", "Normal", "Urgent", "Unknown"]
  @IBOutlet weak var datePicker: UIDatePicker!
  var canceled = false
  
  @IBOutlet weak var cancelButton: UIBarButtonItem!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @IBAction func goBack(sender: AnyObject) {
    self.todoItem!.urgency = self.bufferTodoItemStruct!.urgency
    self.todoItem!.shouldBeDoneBy = self.bufferTodoItemStruct!.shouldBeDoneBy
    performSegue()
  }
  @IBAction func cancelBack(sender: AnyObject) {
    self.canceled = true
    performSegue()
  }
  
  var todoItem: TodoItem? = nil
  var bufferTodoItemStruct: TodoItemStruct? = TodoItemStruct()
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let theDestination = (segue.destinationViewController as ViewController)
    theDestination.changedTodo = self.todoItem
    theDestination.changeCanceled = self.canceled
  }
  
  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, todoItem: TodoItem) {
    self.todoItem = todoItem
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  
  func performSegue() {
    self.performSegueWithIdentifier("rightSegue", sender: self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var addStatusBar = UIView()
    addStatusBar.frame = CGRectMake(0, 0, 400, 20);
    addStatusBar.backgroundColor = UIColor(red: 41/255.0, green: 79/255.0, blue: 109/255.0, alpha: 1)
    self.view.addSubview(addStatusBar)
    let str = "\(self.todoItem!.text)"
    self.navigationBar?.topItem?.title = str;
    self.navigationBar?.titleTextAttributes = [
      NSFontAttributeName: UIFont(name: "RobotoCondensed-Bold", size: 24)!
    ]
    self.doneButton.setTitleTextAttributes([
      NSFontAttributeName: UIFont(name: "RobotoCondensed-Regular", size: 16)!
    ], forState: .Normal)
    self.cancelButton.setTitleTextAttributes([
      NSFontAttributeName: UIFont(name: "RobotoCondensed-Regular", size: 16)!
    ], forState: .Normal)
    self.urgencyPicker?.dataSource = self;
    self.urgencyPicker?.delegate = self;
    self.urgencyPicker.selectRow(find(self.pickerData, self.todoItem!.urgency)!, inComponent: 0, animated: true)
    datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    datePicker.setDate(NSDate(), animated: true)
    
    // Do any additional setup after loading the view.
  }
  
  func datePickerChanged(datePicker: UIDatePicker) {
    self.bufferTodoItemStruct!.shouldBeDoneBy = datePicker.date
    var localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertBody = self.todoItem!.text
    localNotification.fireDate = self.todoItem!.shouldBeDoneBy
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return pickerData[row]
  }
  
  func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
    var pickerLabel = UILabel()
    pickerLabel.textColor = UIColor.blackColor()
    pickerLabel.text = pickerData[row]
    pickerLabel.font = UIFont(name: "RobotoCondensed-Regular", size: 20)
    pickerLabel.textAlignment = NSTextAlignment.Center
    return pickerLabel
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.bufferTodoItemStruct?.urgency = pickerData[row]
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  var localNotification:UILocalNotification = UILocalNotification()
  localNotification.alertAction = self.todoItem!.text
  localNotification.alertBody = self.todoItem!.urgency
  localNotification.fireDate = self.todoItem.shouldBeDoneBy!
  UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  */
  
}
