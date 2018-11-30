//
//  User.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData

class User: NSManagedObject {
    var userflag = false  //user not exists
    func fetchUser(user: String) {
        let context = AppDelegate.viewContext
        let request:NSFetchRequest = User.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", user)
        do {
            let result = try context.fetch(request)
            for item in result {
                if item.userID == user {
                    userflag = true //user exists
                    break
                    
                }
            }
        }catch {
            print(error)
        }
    }
    
//    var users: [String] = []
//    func saveUser(name: String){
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
//        let newUser = User(entity: entity, insertInto: managedContext)
//        newUser.setValue(name, forKey: "userID")
//        do{
//            try managedContext.save()
//            users.append(name)
//            print("\(name) saved")
//        }catch let error as NSError {
//            print("Could not save. \(error),\(error.userInfo)")
//
//        }
//    }
//     static func fetchUsers() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return
//        }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<User>(entityName: "User")
//        do {
//            let fetchedResults = try managedContext.fetch(fetchRequest)
//            for item in fetchedResults {
//                users.append(item.value(forKey: "userID")! as! String)
//            }
//            print(users)
//        } catch let error as NSError {
//            // something went wrong, print the error.
//            print(error.description)
//        }
//    }
    
    func deleteUsers(_ user: String,_ context: NSManagedObjectContext) {
        let request:NSFetchRequest = User.fetchRequest()
//
//        request.predicate = NSPredicate(format: "userID = %@", user)
        
        do {
            let results = try context.fetch(request)
            print(results.count)

            for item in results{
                if item.value(forKey: "userID") as? String == user || item.value(forKey: "userID") == nil {
                    context.delete(item)
                }
            }
            try context.save()
            
        }catch {
            fatalError("Could not delete.\(error)")
        }
        
        
    }
}
