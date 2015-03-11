//
//  ViewController.swift
//  Must Do
//
//  Created by Christopher Dumas on 3/2/15.
//  Copyright (c) 2015 TitoniumWorks. All rights reserved.
//

import UIKit
import CoreData

class TodoU {
  let Normal = 1
  let Urgent = 2
  let Low = 0
}

let todoUrgency = TodoU()

@objc(TodoItem)
class TodoItem: NSManagedObject {
  @NSManaged var text: String
  @NSManaged var shouldBeDoneBy: NSDate?
  @NSManaged var urgency: String
  @NSManaged var completed: Bool
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, TableViewCellDelegate {

  required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }
  
  var todoItems = [TodoItem]()
  
  var currentTodoItem: TodoItem? = nil
  
  var changeCanceled = false
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var textFeild: UITextField!
  
  @IBAction func exportTodoList(sender: AnyObject) {
    let textListOfTodo = todoItems.map({ "\((self.todoItems as NSArray).indexOfObject($0)). \($0.urgency): \($0.text)" })
    let activityVC = UIActivityViewController(activityItems: ["\n".join(textListOfTodo)], applicationActivities: nil)
    
    self.presentViewController(activityVC, animated: true, completion: nil)
  }
  
  @IBAction func deleteAllCheckmarkedTodos(sender: AnyObject) {
    tableView.beginUpdates()
    self.todoItems = self.todoItems.filter {
      let res = !$0.completed
      let idx = NSIndexPath(forRow: (self.todoItems as NSArray).indexOfObject($0), inSection: 0)
      if !res {
        self.tableView.deleteRowsAtIndexPaths([idx], withRowAnimation: .Left)
        self.managedObjectContext?.deleteObject($0)
      }
      return res
    }
    tableView.endUpdates()
    var error: NSError?
    
    managedObjectContext?.save(&error)
  }
  
  let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
  
  var changedTodo: TodoItem? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var addStatusBar = UIView()
    addStatusBar.frame = CGRectMake(0, 0, 400, 20);
    addStatusBar.backgroundColor = UIColor(red: 41/255.0, green: 79/255.0, blue: 109/255.0, alpha: 1)
    self.view.addSubview(addStatusBar)
    
    //let managedObjectContext = (UIApplication.sharedApplication().delegate! as AppDelegate).managedObjectContext
    tableView.dataSource = self
    tableView.delegate = self
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    textFeild.delegate = self
    textFeild.becomeFirstResponder()
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    // Load possiblly saved todo data
    let fetchRequest = NSFetchRequest(entityName: "TodoItem")
    
    // Execute the fetch request, and cast the results to an array of LogItem objects
    if let fetchResults = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as? [TodoItem] {
      self.todoItems = fetchResults
    }
    
    tableView.beginUpdates()
    self.todoItems.sort {
      var one = 0
      var two = 0
      if $0.urgency == "Low" {
        one = 0
      } else if $0.urgency == "Normal" {
        one = 1
      } else if $0.urgency == "Urgent" {
        one = 2
      } else {
        one = 0
      }
      
      if $1.urgency == "Low" {
        two = 0
      } else if $1.urgency == "Normal" {
        two = 1
      } else if $1.urgency == "Urgent" {
        two = 2
      } else {
        two = 0
      }
      return one < two
    }
    self.todoItems = self.todoItems.reverse()
    tableView.reloadData()
    tableView.endUpdates()
  }
  
  func performSegue() {
    self.performSegueWithIdentifier("leftSegue", sender: self)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let theDestination = (segue.destinationViewController as SettingsViewController)
    theDestination.todoItem = self.currentTodoItem!
    theDestination.prevousView = self
    var error: NSError?
    
    managedObjectContext?.save(&error)
  }
  
  // MARK: - Table view data source
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return todoItems.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell:GestureTableViewCell = GestureTableViewCell(style: .Subtitle, reuseIdentifier: "cell")
    var ti = todoItems[indexPath.row]
    
    if let cti = self.changedTodo {
      if !self.changeCanceled && ti.text == cti.text {
        ti = cti
        var error: NSError?
        
        managedObjectContext?.save(&error)
      }
    }
    
    cell.textLabel?.text = ti.text
    cell.textLabel?.font = UIFont (name: "RobotoCondensed-Bold", size: 17)
    cell.detailTextLabel?.font = UIFont (name: "RobotoCondensed-Regular", size: 10)
    cell.detailTextLabel?.text = ti.urgency
    
    if ti.completed {
      cell.accessoryType = .Checkmark
      cell.backgroundColor = UIColor.clearColor()
    } else {
      cell.accessoryType = .DisclosureIndicator
    }
    cell.delegate = self
    cell.todoItem = ti
    cell.itemCompleteLayer.hidden = !cell.todoItem!.completed
    tableView.clipsToBounds = false
    
    return cell
  }

  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    currentTodoItem = todoItems[indexPath.row]
    performSegue()
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    tableView.beginUpdates()
    var mdi: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("TodoItem", inManagedObjectContext: self.managedObjectContext!)
    var tdi = mdi as TodoItem
    tdi.text = textField.text!
    tdi.urgency = "Normal"
    tdi.completed = false
    tdi.shouldBeDoneBy = nil
    todoItems.insert(tdi, atIndex: 0)
    self.todoItems.sort {
      var one = 0
      var two = 0
      if $0.urgency == "Low" {
        one = 0
      } else if $0.urgency == "Normal" {
        one = 1
      } else if $0.urgency == "Urgent" {
        one = 2
      } else {
        one = 0
      }
      
      if $1.urgency == "Low" {
        two = 0
      } else if $1.urgency == "Normal" {
        two = 1
      } else if $1.urgency == "Urgent" {
        two = 2
      } else {
        two = 0
      }
      return one < two
    }
    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: (todoItems as NSArray).indexOfObject(tdi), inSection: 0)], withRowAnimation: .Right)
    //tableView.reloadData()
    tableView.endUpdates()
    textFeild.text! = ""
    var error: NSError?
    
    managedObjectContext?.save(&error)
    return false
  }
  
  func todoItemDeleted(todoItem: TodoItem) {
    let index = (todoItems as NSArray).indexOfObject(todoItem)
    if index == NSNotFound { return }
    
    // could removeAtIndex in the loop but keep it here for when indexOfObject works
    todoItems.removeAtIndex(index)
    
    // use the UITableView to animate the removal of this row
    tableView.beginUpdates()
    let indexPathForRow = NSIndexPath(forRow: index, inSection: 0)
    tableView.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: .Left)
    managedObjectContext?.deleteObject(todoItem as NSManagedObject)
    tableView.endUpdates()
    println("Deleted")
  }
  func todoItemChecked(todoItem: TodoItem) {
    var error: NSError?
    
    managedObjectContext?.save(&error)
  }
}

