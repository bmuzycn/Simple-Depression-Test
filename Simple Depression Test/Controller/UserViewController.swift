//
//  UserViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData
class UserViewController: UIViewController, UITextFieldDelegate{
   
    var currentUser = ""
    var name: String?
    var users = [String]()
    var usersArray: [String] = ["default".localized]
    weak var userDelegate: UserDelegate?
    weak var dataDelegate: DataDelegate?
    var isNewUser = false
    

    
    @IBAction func unwindSegueToUserView(unwindSegue: UIStoryboardSegue) {
        print("Welcome back to userView")
    }

    
    @IBOutlet weak var userID: UITextField!
    @IBOutlet weak var usersView: UIPickerView! 
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetch data from CoreData
        fetchUsers()
        if !users.isEmpty{
            usersArray = users
        }
        //load pickerView
        usersView.dataSource = self
        usersView.delegate = self
        userID.delegate = self

        //add swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            performSegue(withIdentifier: "toChart", sender: nil)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            goQuestionView()

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultViewController
        {
            let vc = segue.destination as? ResultViewController
            dataDelegate = vc
            dataDelegate?.passResult(user: currentUser)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newUserButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "New User".localized, message: "Enter a name".localized, preferredStyle: .alert)
        alert.addTextField { (userID) in
            userID.text = "New User".localized
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self,unowned alert] (_) in
            let textField = alert.textFields![0]// Force unwrapping because we know it exists.
            self.userID.text = textField.text
            self.saveNewUser()
            if self.isNewUser {
                self.goQuestionView()
            }
            }))
        if let presented = self.presentedViewController {
            presented.removeFromParent()
        }
        if presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        }
        //        self.present(alert, animated: true, completion: nil)
    }
    
 
    @IBAction func addUser(_ sender: UIButton) {
        saveNewUser()
//        viewDidLoad()
        fetchUsers()
        if !users.isEmpty{
            usersArray = users
        }
//        usersView.dataSource = self
//        usersView.delegate = self
        usersView.reloadAllComponents()
    }
    
    func saveNewUser() {
        for name in users {
            if name == userID.text {
                userID.text = ""
                let alert = UIAlertController(title: "Note".localized, message: "User exists!".localized, preferredStyle: .alert)
                if let presented = self.presentedViewController {
                    presented.removeFromParent()
                }
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                }
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
                break
            }
            
        }
        if userID.text != "" {
            currentUser = userID.text!
            let context = AppDelegate.viewContext
            let newUser = User(context: context)
            newUser.fetchUser(user: currentUser)
            if newUser.userflag == true {
                let alert = UIAlertController(title: "Note".localized, message: "User exists!".localized, preferredStyle: .alert)
                if let presented = self.presentedViewController {
                    presented.removeFromParent()
                }
                if presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                }
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
            }else {
            isNewUser = true
            newUser.userID = currentUser
            do{
                try context.save()
                print("\(currentUser) saved")
                
            }catch let error as NSError {
                print("Could not save. \(error),\(error.userInfo)")
            }
            }
        }
            
        else {
            let alert = UIAlertController(title: "Note".localized, message: "Please input a user name".localized, preferredStyle: .alert)
            if let presented = self.presentedViewController {
                presented.removeFromParent()
            }
            if presentedViewController == nil {
                self.present(alert, animated: true, completion: nil)
            }
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil))
        }
    }
    
    @IBAction func selectButton(_ sender: Any) {
        goQuestionView()
    }

    @IBAction func deleteButton(_ sender: Any) {
        let alert = UIAlertController(title: "⚠️"+"Delete User".localized + ": \(currentUser)", message: "Warning! All the records under this user will be deleted.".localized, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler:{[unowned self](UIAlertAction) in self.deleteUser()} ))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteUser() {
        let context = AppDelegate.viewContext
        let user = User(context: context)
        user.deleteUsers(currentUser, context)
        print("deleted")
        viewDidLoad()
    }
    
    func goQuestionView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "questionView") as! ViewController
        self.present(vc, animated: true)
        
        //pass currentUser to vc
        userDelegate = vc
        userDelegate?.userReady(name: currentUser)
        }
    
    
    func fetchUsers() {
        users.removeAll()
        let managedContext = AppDelegate.viewContext
        let fetchRequest: NSFetchRequest = User.fetchRequest()
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            print(fetchedResults.count)
            if fetchedResults.count > 0{
                for item in fetchedResults {
                    if item.value(forKey: "userID") != nil {
                    users.append(item.value(forKey: "userID") as! String)
                }
                }
            }
            
        }catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        userID.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        return true
    }
}

extension UserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in usersView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return usersArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        currentUser = usersArray[row]
        self.dataDelegate?.passResult(user: currentUser)
        return usersArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentUser = usersArray[row]
    }
}
