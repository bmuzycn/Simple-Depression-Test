//
//  DataStored.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData

class DataStored: NSManagedObject {
    var scoresArray = [[Int]]()
    var resultArray = [String]()
    var dateArray = [String]()
    var totalArray = [Int]()
    var flag = Bool() //to see if the data size >fetchLimit
    var userflag = false
    var count = Int()
    static var fetchLimit = 15

    
    func saveData(_ totalScore: Int, _ scores: [Int],_ result: String,_ user: String){
        let context = AppDelegate.viewContext
        let request:NSFetchRequest = User.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", user)
        var existUser = User(context: context)

        do {
            let result = try context.fetch(request)
            for item in result {
                if item.userID == user {
                    userflag = true //exist user was found
                    existUser = item
                    break
                }
            }
        }catch {
            print(error)
        }
        let newData = DataStored(context: existUser.managedObjectContext!)
        newData.totalScore = Int16(totalScore)
        newData.scores = scores
        newData.result = result
        newData.userName = user
        newData.dateTime = Date()
        existUser.userID = user //assign existUser a new userID
        existUser.addToData(newData)
        do {
            try context.save()
            print("save successively")
        }catch {
            print(error)
        }
    }
    
    //return last fetchLimit records
    func fetchData(_ user: String,_ n: Int ) {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<DataStored>(entityName: "DataStored")
        request.predicate = NSPredicate(format: "userName = %@", user)
        var startNum = 0
        var endNum = 0
        do {
            let data = try context.fetch(request)
            self.count = data.count
            if self.count != 0 {
                if data.count - DataStored.fetchLimit*n == 0 {
                    startNum = 0
                    endNum = DataStored.fetchLimit - 1
                    flag = false
                }
                else if (data.count - DataStored.fetchLimit*n) > 0 && (data.count - DataStored.fetchLimit*n) <= DataStored.fetchLimit  {
                    startNum = 0
                    endNum = data.count - DataStored.fetchLimit*n - 1
                    flag = false
                }else if (data.count - DataStored.fetchLimit*n) > DataStored.fetchLimit {
                    startNum = data.count - DataStored.fetchLimit*(n+1)
                    endNum = data.count - DataStored.fetchLimit*n - 1
                    flag = true
                }
                else {
                    // pageUp is not allowed
                    flag = false
                }
                for index in startNum...endNum{
                    let item = data[index]
                    resultArray.append(item.value(forKey: "result")! as! String)
                    let date = item.value(forKey: "dateTime")
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M/dd/yy"
                    let strDate = formatter.string(from: date as! Date)
                    dateArray.append(strDate)
                    scoresArray.append(item.value(forKey: "scores") as! [Int])
                    totalArray.append(item.value(forKey: "totalScore") as! Int)
                }
            } else {
                print("data is empty!")
                flag = false

            }
            
        }
            catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
    }
    
    func deleteData(_ user: String, _ n: Int, _ x: Int) {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<DataStored>(entityName: "DataStored")
        request.predicate = NSPredicate(format: "userName = %@", user)
        do {
            let data = try context.fetch(request)
            if data.count == 0 {
                self.count = 0
            } else if data.count - DataStored.fetchLimit*n < DataStored.fetchLimit {
                print("data\(x) will be deleted")
                context.delete(data[x])
            }else {
                print("data\(data.count-DataStored.fetchLimit*(n+1)+x) will be deleted")

                context.delete(data[data.count-DataStored.fetchLimit*(n+1)+x])
            }
            try context.save()
            
        } catch {
            fatalError("Could not delete.\(error)")
        }
    }
}



