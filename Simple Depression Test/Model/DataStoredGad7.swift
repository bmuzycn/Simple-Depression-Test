//
//  DataStoredGad7.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/22/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//


import UIKit
import CoreData

class DataStoredGad7: NSManagedObject {
    var scoresArray = [[Int]]()
    var resultArray = [String]()
    var dateArray = [String]()
    var totalArray = [Int]()
    var flag = Bool() //to see if the data size >fetchLimit
    var userflag = false
    var count = Int()
    static var fetchLimit = 15
    let context = AppDelegate.viewContext

    func saveData(_ totalScore: Int, _ scores: [Int],_ result: String,_ user: String){
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
        let newData = DataStoredGad7(context: existUser.managedObjectContext!)
        newData.totalScore = Int16(totalScore)
        newData.scores = scores
        newData.result = result
        newData.userName = user
        newData.dateTime = Date()
        existUser.userID = user //assign existUser a new userID
        existUser.addToDataGad7(newData)
        do {
            try context.save()
            print("save successively")
        }catch {
            print(error)
        }
    }
    
    //return last fetchLimit records
    func fetchData(_ user: String,_ n: Int ) {
        let request = NSFetchRequest<DataStoredGad7>(entityName: "DataStoredGad7")
        request.predicate = NSPredicate(format: "userName = %@", user)
        var startNum = 0
        var endNum = 0
        do {
            let data = try context.fetch(request)
            self.count = data.count
            if self.count != 0 {
                if data.count - DataStoredGad7.fetchLimit*n == 0 {
                    startNum = 0
                    endNum = DataStoredGad7.fetchLimit - 1
                    flag = false
                }
                else if (data.count - DataStoredGad7.fetchLimit*n) > 0 && (data.count - DataStoredGad7.fetchLimit*n) <= DataStoredGad7.fetchLimit  {
                    startNum = 0
                    endNum = data.count - DataStoredGad7.fetchLimit*n - 1
                    flag = false
                }else if (data.count - DataStoredGad7.fetchLimit*n) > DataStored.fetchLimit {
                    startNum = data.count - DataStoredGad7.fetchLimit*(n+1)
                    endNum = data.count - DataStoredGad7.fetchLimit*n - 1
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
        let request = NSFetchRequest<DataStoredGad7>(entityName: "DataStored")
        request.predicate = NSPredicate(format: "userName = %@", user)
        do {
            let data = try context.fetch(request)
            if data.count == 0 {
                self.count = 0
            } else if data.count - DataStoredGad7.fetchLimit*n < DataStoredGad7.fetchLimit {
                print("data\(x) will be deleted")
                context.delete(data[x])
            }else {
                print("data\(data.count-DataStoredGad7.fetchLimit*(n+1)+x) will be deleted")
                
                context.delete(data[data.count-DataStoredGad7.fetchLimit*(n+1)+x])
            }
            try context.save()
            
        } catch {
            fatalError("Could not delete.\(error)")
        }
    }
}



