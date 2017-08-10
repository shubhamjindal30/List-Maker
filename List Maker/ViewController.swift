//
//  ViewController.swift
//  List Maker
//
//  Created by Shubham Jindal on 13/04/17.
//  Copyright © 2017 sjc. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //Setting the IBOutlet for the table view
  @IBOutlet weak var tableView: UITableView!
    //Creating an array named items in which data will be stored
  var items: [NSManagedObject] = []

    //Implementing the view did load function
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "List Maker"
    tableView.register(UITableViewCell.self,
                       forCellReuseIdentifier: "Cell")
  }

    //Setting the action for logout button
    @IBAction func logOutAction(_ sender: Any) {
        UdacityClient.sharedInstance().endUserSession { (success, error) in
            if success {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(error!)
            }
        }
        
    }
    
    //Method to show alerts
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //Implementing the view will disappear function
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
    do {
      items = try managedContext.fetch(fetchRequest)
    } catch let error as NSError {
        showAlert("Could not fetch. \(error), \(error.userInfo)")
    }
  }

    //Method to add a new item to the list
  @IBAction func addName(_ sender: UIBarButtonItem) {

    let alert = UIAlertController(title: "New Item",
                                  message: "Add a new item",
                                  preferredStyle: .alert)

    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in

      guard let textField = alert.textFields?.first,
        let nameToSave = textField.text else {
          return
      }

      self.save(name: nameToSave)
      self.tableView.reloadData()
    }

    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)

    alert.addTextField()

    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert, animated: true)
  }

  func save(name: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }

    let managedContext = appDelegate.persistentContainer.viewContext

    let entity = NSEntityDescription.entity(forEntityName: "Item",
                                            in: managedContext)!

    let person = NSManagedObject(entity: entity,
                                 insertInto: managedContext)

    person.setValue(name, forKeyPath: "name")

    do {
      try managedContext.save()
      items.append(person)
    } catch let error as NSError {
      showAlert("Could not save. \(error), \(error.userInfo)")
    }
  }
}



// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let person = items[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                             for: indexPath)
    cell.textLabel?.text = person.value(forKeyPath: "name") as? String
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let managedContext = appDelegate.persistentContainer.viewContext

    if(editingStyle==UITableViewCellEditingStyle.delete) {
        
        managedContext.delete(items[indexPath.row])
        self.items.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        do {
            try managedContext.save()
        } catch let error as NSError {
            showAlert("Could not save. \(error), \(error.userInfo)")
        }
    }
  }

  
}
