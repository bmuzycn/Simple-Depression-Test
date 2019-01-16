//
//  RVController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/1/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData

struct Record {
    let date: String
    let totalScore: Int
    let dateTime : Date
}
struct Expandabe {
    var isExpanded: Bool
    var records: [Record]
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let fetchLimit = DataStored.fetchLimit
    var interactor:Interactor? = nil
    var menuActionDelegate:MenuActionDelegate? = nil
    var scoresArray = [[Int]]()
    var resultArray = [String]()
    var dateArray = [String]()
    var totalArray = [Int]()
    var currentUser = ""
    
    var records = [Record]() //unsorted from fetch results
    var groupRecords = [String:[Record]]()
    var expandableRecords = [Expandabe]() //sorted results

    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBAction func handleGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .left)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func closeMenu(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func delay(seconds: Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true){
            self.delay(seconds: 0.5){
                self.menuActionDelegate?.reopenMenu()
            }
        }
    }
    //Mark: sortting data method need to be improved
    fileprivate func sortData() {
        groupRecords = Dictionary(grouping: records) { (element) -> String in
            return element.date
        }
        
        // provide a sorting for your keys somehow
        let sortedKeys = groupRecords.keys.sorted(by:>)
        sortedKeys.forEach { (key) in
            let values = groupRecords[key]?.sorted(by: {$0.dateTime > $1.dateTime})
            let recordForExpandable = Expandabe(isExpanded: false, records: values ?? [])
            expandableRecords.append(recordForExpandable)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //add receiver to NotificationCenter
        NotificationCenter.default.addObserver(forName: NSNotification.Name("cUser"), object: nil, queue: OperationQueue.main) { (notification) in
            self.currentUser = notification.userInfo?["user"] as? String ?? ""
            print("user@:\(self.currentUser)")
        }
        fetchData(currentUser)
        setLabel()
        sortData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbView.delegate = self
        tbView.dataSource = self
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        tbView.backgroundColor = Settings.bgColorForMenuView

    }
    
    func setLabel() {
        let title = "\(currentUser)"+"'s Records".localized
        let leftBarButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(dismissMenu))
        let rightBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(dismissMenu))

        titleBar.topItem?.setLeftBarButton(leftBarButton, animated: false)
        titleBar.topItem?.setRightBarButton(rightBarButton, animated: false)
    }

    @objc func dismissMenu() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }


    //Mark: get the user's records
    func fetchData(_ user: String) {
        records.removeAll()
        resultArray.removeAll()
        dateArray.removeAll()
        scoresArray.removeAll()
        totalArray.removeAll()
        expandableRecords.removeAll()
        groupRecords.removeAll()
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<DataStored>(entityName: "DataStored")
        request.predicate = NSPredicate(format: "userName = %@", user)
        do {
            let data = try context.fetch(request)
            for item in data{
                resultArray.append(item.value(forKey: "result")! as! String)
                let date = item.value(forKey: "dateTime") as! Date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
//                formatter.timeZone = TimeZone(abbreviation: "UTC")
                let strDate = formatter.string(from: date)
                dateArray.append(strDate)
                let totalScore = item.value(forKey: "totalScore") as! Int
                let record = Record(date: strDate, totalScore: totalScore, dateTime: date)
                records.append(record)
                scoresArray.append(item.value(forKey: "scores") as! [Int])
                totalArray.append(item.value(forKey: "totalScore") as! Int)
                }
        }
        catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
    }
    //delete data
    func deleteData(_ user: String, _ x: Int) {
        let context = AppDelegate.viewContext
        let request = NSFetchRequest<DataStored>(entityName: "DataStored")
        request.predicate = NSPredicate(format: "userName = %@", user)
        do {
            let data = try context.fetch(request)
                print("data\(x) will be deleted")
                context.delete(data[x])
            try context.save()
            
        } catch {
            fatalError("Could not delete.\(error)")
        }
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return expandableRecords.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if expandableRecords[section].isExpanded == true {
        return expandableRecords[section].records.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    //Mark: define vars to be passed to ReportVC
    var scoresSelected = [Int]()
    var totalScore = 0
    var dateSelected = ""
    var resultSelected = ""
    var indexForFetch = 0

    // MARK: - Table view delegate
    
    //Todo: Method after a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        var index = indexPath.row
        for row in 0..<indexPath.section {
            index += expandableRecords[row].records.count
        }
        indexForFetch = index
        let indexSelected = records.count - index - 1
        scoresSelected = scoresArray[indexSelected]
        totalScore = totalArray[indexSelected]
        dateSelected = dateArray[indexSelected]
        resultSelected = resultArray[indexSelected]
        performSegue(withIdentifier: "unwindToChartView", sender: self)

}
    
//    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        var index = indexPath.row
//        for row in 0..<indexPath.section {
//            index += expandableRecords[row].records.count
//        }
//        indexForFetch = index
//        let indexSelected = dateArray.count - index - 1
//        scoresSelected = scoresArray[indexSelected]
//        totalScore = totalArray[indexSelected]
//        dateSelected = dateArray[indexSelected]
//        resultSelected = resultArray[indexSelected]
//        performSegue(withIdentifier: "unwindToChartView", sender: self)
//    }

    //method to delete a row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //get index from 2d array
        var index = indexPath.row
        for row in 0..<indexPath.section {
            index += expandableRecords[row].records.count
        }
        let indexSelected = dateArray.count - index - 1
        
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "⚠️"+"Delete Data".localized, message: "Warning! Data cannot be recoverd after delete.".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler:{(UIAlertAction) in
                self.expandableRecords[indexPath.section].records.remove(at: indexPath.row)

                self.deleteData(self.currentUser, indexSelected)
                self.fetchData(self.currentUser)
                self.sortData()
                if self.expandableRecords.indices.contains(indexPath.section){
                self.expandableRecords[indexPath.section].isExpanded = true
                }
                tableView.reloadData()

            } ))
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let totalScore = expandableRecords[indexPath.section].records[indexPath.row].totalScore
        let timeStamp = expandableRecords[indexPath.section].records[indexPath.row].dateTime
        let formatter = DateFormatter()
        formatter.dateFormat = "'@' h:mm a"
        let timeRecord = formatter.string(from: timeStamp)
        let scoreColor = setColor(totalScore)
        let bgColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let yourScore = NSMutableAttributedString(string: "Your score:".localized + " \(totalScore) ")
        yourScore.addAttributes([NSAttributedString.Key.foregroundColor: scoreColor, NSAttributedString.Key.backgroundColor: bgColor], range: NSRange(location: 12, length: 2))
        cell.textLabel?.attributedText = yourScore
        cell.detailTextLabel?.text = timeRecord
        cell.backgroundColor = bgColor
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let button = UIButton(type: .system)
        button.tag = section
        button.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        //set button title
        if let record = expandableRecords[section].records.first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
            let dateString = dateFormatter.string(from: record.dateTime)
            let attriTitle = NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)])
            button.setAttributedTitle(attriTitle, for: .normal)
            button.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        return button
    }
    
    @objc func buttonPressed(button: UIButton){
        let section = button.tag
        
        // we'll try to close the section first by deleting the rows
        var indexPaths = [IndexPath]()
        for row in expandableRecords[section].records.indices {
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        
        let isExpanded = expandableRecords[section].isExpanded
        expandableRecords[section].isExpanded = !isExpanded
        
        button.backgroundColor = isExpanded ? tbView.backgroundColor : #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 0.5)
        
        if isExpanded {
            tbView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tbView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "unwindToChartView" {
            let chartVC = segue.destination as! ResultViewController
            chartVC.isDataSentFromRecordsMenu = true
            chartVC.radarView.setRadarData(chartVC.phqArray, scoresSelected, "PHQ-9")
            chartVC.dateLabel.text = dateSelected + "\n" + " Your Score:".localized + String(totalScore)
            chartVC.date = dateSelected
            chartVC.result = resultSelected
            chartVC.scores = scoresSelected
            chartVC.totalScore = totalScore
            chartVC.numberOfFetch = max(Int(floor(Float(indexForFetch/fetchLimit))) , 0)
            let xValue = (records.count - fetchLimit*chartVC.numberOfFetch!) < fetchLimit ? Double(records.count - indexForFetch - 1) : Double(fetchLimit - (indexForFetch - fetchLimit*chartVC.numberOfFetch!) - 1)
            chartVC.barView.highlightValue(x: xValue, dataSetIndex: 0, stackIndex: 0)
            
        }
    }

}

extension MenuViewController {
    fileprivate func setColor(_ value: Int) -> UIColor{
        
        if(value < 5){
            return UIColor.green
        }
        else if(value < 10){
            return UIColor.yellow
        }
        else if(value < 15){
            return UIColor.orange
        }
        else if(value < 20){
            return UIColor.red
        }
        else { //In case anything goes wrong
            return UIColor.purple
        }
    }
    
    //Set seperator for sections
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        let separatorView = UIView(frame: CGRect(x: tableView.separatorInset.left, y: footerView.frame.height, width: tableView.frame.width - tableView.separatorInset.right, height: 1))
        separatorView.backgroundColor = UIColor.separatorColor
        footerView.addSubview(separatorView)
        return footerView
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}



extension UIColor {
    class var separatorColor: UIColor {
        return UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
    }
}
