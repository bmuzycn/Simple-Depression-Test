//
//  ResultViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/20/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import Charts

class ResultViewController: UIViewController, DataDelegate, ChartViewDelegate {

    var currentUser: String = ""
    
    var scores = [Int]() //for total scores
    var result = ""
    var results = Array<String>()
    var dateArray = [String]()
    var date = ""
    var scoreArray = [[Int]]() //for scores of each question
    var scoreArrayNum = 0
    var numberOfFetch = 0
    var flag = true
    @IBAction func unwindSegueToResultView(unwindSegue: UIStoryboardSegue) {
        print("Welcome back to resultView")
    }
    @IBOutlet weak var menuView: UIStackView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var last25: UIButton!
    @IBOutlet weak var next25: UIButton!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    @IBOutlet weak var lineView: LineChartView!
    @IBOutlet weak var radarView: RadarChartView!
    @IBOutlet weak var barView: BarChartView!
    
    
    weak var reportDelegate: ReportDelegate?
    let phqArray = ["Anhedonia".localized,"Low Mood".localized,"Insomnia".localized,"Fatigue".localized,"Appetite".localized,"Worthlessness".localized,"Concentration".localized,"Movement".localized,"Suicide".localized,"Social".localized]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //create a interactive chart delegate
        self.barView.delegate = self
        self.radarView.delegate = self
        
        menuView.isHidden = true
        //create a instance of dataStored and fetch data from coredata
        print("cuser@:\(self.currentUser)")
        
        let context = AppDelegate.viewContext
        let data = DataStored(context: context)
        data.fetchData(currentUser,numberOfFetch)
        flag = data.flag
        if data.count == 0 {
            scores.removeAll()
            dateArray.removeAll()
            scoreArray.removeAll()
            radarView.clear()
            //set bar chart
            barView.clear()
            lineView.isHidden = true
            //set line chart
            lineView.clear()
        }else {
            
            //set vars for receiving data
            scores = data.totalArray
            dateArray = data.dateArray
            scoreArray = data.scoresArray
            results = data.resultArray
            
            //set radar chart
            scoreArrayNum = scoreArray.count - 1
            dateLabel.text = " Your Score:".localized + String(scores[scoreArrayNum])
            radarView.setRadarData(phqArray, scoreArray[scoreArrayNum], "PHQ-9")
            
            
            //set bar chart
            barView.setBarChartData(xValues: dateArray, yValues: scores, label: "Scores Records")
            lineView.isHidden = true
            //long press gesture
            let longPressgesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected(gesture:)))
            longPressgesture.allowableMovement = 50
            barView.addGestureRecognizer(longPressgesture)
            
            //set line chart
            lineView.setLineChartData(xValues: dateArray, yValues: scores, label: "Scores Records")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userVC = tabBarController?.viewControllers?[0] as! UserViewController
        currentUser = userVC.currentUser
        
        //add receiver to NotificationCenter
        NotificationCenter.default.addObserver(forName: NSNotification.Name("cUser"), object: nil, queue: OperationQueue.main) { (notification) in
            self.currentUser = notification.userInfo?["user"] as? String ?? ""
            print("user@:\(self.currentUser)")
        }
        

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
//            dismiss(animated: true, completion: nil)
            performSegue(withIdentifier: "unwindSegueToUserView", sender: self)
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            saveImage()

            performSegue(withIdentifier: "toReport", sender: self)

            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ReportVC
        {
            let vc = segue.destination as? ReportVC
            self.reportDelegate = vc
            if scoreArray.count > 0 {
            self.reportDelegate?.passResult(user: currentUser, scores: scoreArray[scoreArrayNum], total: scores[scoreArrayNum], result: results[scoreArrayNum], date: dateArray[scoreArrayNum])
            
            FileManager.default.clearTmpDirectory()
            print("directory was cleared")
            saveImage()
                
            //add notificationCenter
            NotificationCenter.default.post(name: NSNotification.Name("passData"), object: self)
                
            }
        }
    }
    //MARK: save images
    func saveImage() {
        if !scores.isEmpty {
        if lineView.isHidden == true{
            let _ = barView.save(to: "\(NSTemporaryDirectory())/image002.png", format: ChartViewBase.ImageFormat.png, compressionQuality: 1.0)
            print("barchart was saved")
        }else{
            let _ = lineView.save(to: "\(NSTemporaryDirectory())/image002.png", format: ChartViewBase.ImageFormat.png, compressionQuality: 1.0)
            print("linechart was saved")

        }
        
        let _ = radarView.save(to: "\(NSTemporaryDirectory())/image001.png", format: ChartViewBase.ImageFormat.png, compressionQuality: 1.0)
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        performSegue(withIdentifier: "unwindSegueToTest", sender: self)
//        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        menuView.isHidden = !menuView.isHidden
    }
    
    @IBAction func dismissMenu(_ sender: Any) {
        menuView.isHidden = true
    }
    
    //Go to reportView
    @IBAction func goToReportView(_ sender: Any) {
        performSegue(withIdentifier: "toReport", sender: self)
//        NotificationCenter.default.post(name: NSNotification.Name("passData"), object: self)
//        saveImage()
//        tabBarController?.selectedIndex = 3

    }
    
    
    //save to csv file
    @IBAction func saveCsv(_ sender: Any) {
        saveCsv()
    }
    func  saveCsv() {
        let dateSave = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: dateSave)
        var str = ""
        print(scores.count)
        
        //load data to string
        for i in 0..<scores.count {
            let date = dateArray[i]

            str.append("name: \(currentUser),date:\(date)\n")
            var n = 0
            for score in scoreArray[i] {
                str.append("question\(n+1),\(score)\n")
                n = n + 1
            }
            str.append("total,\(scores[i])\n\n")
        }
        
        let fileName = "\(dateString).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        //write data using string.write
        
        do {
            try str.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            vc.excludedActivityTypes = [
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.postToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.postToTwitter,
                UIActivity.ActivityType.postToFacebook,
                UIActivity.ActivityType.openInIBooks
            ]
            present(vc, animated: true, completion: nil)
            if let popOver = vc.popoverPresentationController {
                popOver.sourceView = self.view
                //popOver.sourceRect =
                //popOver.barButtonItem
            }
        } catch {
            print(error)
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
   //buttons for radarchart
    @IBAction func prevButton(_ sender: UIButton) {
        if scoreArrayNum > 0 {
            scoreArrayNum -= 1
            radarView.setRadarData(phqArray, scoreArray[scoreArrayNum], "PHQ-9")
            nextButton.isHidden = false
            dateLabel.text = "\(dateArray[scoreArrayNum])" + " Score:" + "\(scores[scoreArrayNum])"

        }else{
            prevButton.isHidden = true
            nextButton.isHidden = false
        }
        
    }
    
    
    @IBAction func nextButton(_ sender: UIButton) {
        if scoreArrayNum < scoreArray.count - 1 {
            scoreArrayNum += 1
            radarView.setRadarData(phqArray, scoreArray[scoreArrayNum], "PHQ-9")
            prevButton.isHidden = false
            dateLabel.text = "\(dateArray[scoreArrayNum]) Score:\(scores[scoreArrayNum])"
        }
        else {
            nextButton.isHidden = true
            prevButton.isHidden = false
            
        }
    }
    
    //buttons for barchart
    @IBAction func lastViewButton(_ sender: UIButton) {

        if flag == false {
            last25.isHidden = true
            next25.isHidden = false
        } else {
            numberOfFetch += 1
            viewDidLoad()
            next25.isHidden = false
        }
    }
    
    @IBAction func nextViewButton(_ sender: UIButton) {
        if numberOfFetch >= 1 {
            numberOfFetch -= 1
            viewDidLoad()
            last25.isHidden = false
        }
        else {
            next25.isHidden = true
            last25.isHidden = false
        }
        
    }
    
    @IBAction func switchButton(_ sender: UISegmentedControl) {
        switch segControl.selectedSegmentIndex{
        case 0:
            lineView.isHidden = true
            barView.isHidden = false
        case 1:
            barView.isHidden = true
            lineView.isHidden = false
            
        default:
            break;
        }
        saveImage()
    }
    
    // add long press gesture
@objc func longPressDetected(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.barView)
            let h = self.barView.getHighlightByTouchPoint(point)
            self.barView.highlightValue(x: (h?.x)!, dataSetIndex: (h?.dataSetIndex)!, stackIndex: (h?.stackIndex)!)
//            print("gesture detected \(h?.x)")
            if let xVal = h?.x {
            //create a instance of dataStored and fetch data from coredata
                    let context = AppDelegate.viewContext
                    let data = DataStored(context: context)
                    let alert = UIAlertController(title: "⚠️"+"Delete Data".localized, message: "Warning! Data cannot be recoverd after delete.".localized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive, handler:{(UIAlertAction) in data.deleteData(self.currentUser, self.numberOfFetch, Int(xVal))
                            self.viewDidLoad()
                        } ))
                        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))
                        self.present(alert, animated: true, completion: nil)
            
    }
    }
    }

    
    
    // User delegate
    func passResult(user :String) {
        currentUser = user        
    }
    
    //MARK: ChartViewDelegate
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected y=\(entry.y) x=\(entry.x)")

        scoreArrayNum = Int(entry.x)
        radarView.setRadarData(phqArray, scoreArray[scoreArrayNum], "PHQ-9")
        dateLabel.text = "\(dateArray[scoreArrayNum])"+" Your Score:".localized+"\(scores[scoreArrayNum])"
        
        //add notificationCenter
        NotificationCenter.default.post(name: NSNotification.Name("passData"), object: self)
        saveImage()
            
    }

}
extension LineChartView {

    private class LineChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if Int(value) >= 0 && Int(value) < labels.count {
                return labels[Int(value)]
            }else {
                return ""
            }
        }

        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    func setColor(_ value: Int) -> UIColor{
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

    func setLineChartData(xValues: [String], yValues: [Int], label: String) {
        var dataEntries: [ChartDataEntry] = []
        var colorArray = [UIColor]()
        for i in 0..<yValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(yValues[i]))
            dataEntries.append(dataEntry)
            colorArray.append(setColor(yValues[i]))

        }

        let chartDataSet = LineChartDataSet(values: dataEntries, label: label)
        chartDataSet.circleHoleRadius = 0
        chartDataSet.circleRadius = 6
        chartDataSet.circleColors = colorArray
//        chartDataSet.colors = colorArray
        let chartData = LineChartData(dataSet: chartDataSet)
        //to format xAxis
        let chartFormatter = LineChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        //to format yAxis
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        self.chartDescription?.text = "Severe 21-27\nModerate severe 16-20\nMild moderate 10-15\nMild 5-9\nMinimal 1-4".localized
        self.data = chartData
    }
}

extension BarChartView {

    private class BarChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            if Int(value) >= 0 && Int(value) < labels.count {
                return labels[Int(value)]
            }else {
                return ""
            }
        }

        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    func setColor(_ value: Int) -> UIColor{

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
    func setBarChartData(xValues: [String], yValues: [Int], label: String) {
        var dataEntries: [BarChartDataEntry] = []
        var colorArray = [UIColor]()
        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(yValues[i]))
            dataEntries.append(dataEntry)
            colorArray.append(setColor(yValues[i]))
        }

        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        chartDataSet.colors = colorArray
        let chartData = BarChartData(dataSet: chartDataSet)
        //to format xAxis
        let chartFormatter = BarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        //to format yAxis
        let yAxis = YAxis()
        yAxis.granularityEnabled = true
        yAxis.granularity = 1.0
        yAxis.axisMinimum = 0.0
        yAxis.axisMaximum = 27
        yAxis.axisRange = 27
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        //set barView
//        self.setVisibleYRangeMaximum(Double(27), axis: .left)
//        self.setVisibleYRangeMinimum(Double(0), axis: .left)
//        self.setVisibleYRange(minYRange: 1, maxYRange: 27, axis: .left)
        self.chartDescription?.text = ""
        self.animate(xAxisDuration: 2, yAxisDuration: 0.5)
        self.data = chartData
        self.setVisibleXRangeMinimum(5.0)
        self.xAxis.granularityEnabled = true
        
    }


    
}



extension RadarChartView {

    private class RadarChartFormatter: NSObject, IAxisValueFormatter {

        var labels: [String] = []

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let index = Int(value)
            if index < labels.count && index >= 0 {
                return labels[index]
            } else {
                return ""
                
            }
        }
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }

    func setColor(_ value: Int) -> UIColor{
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
    
    func setRadarData(_ xValues: [String],_ yValues: [Int],_ label: String) {

        var dataEntries: [RadarChartDataEntry] = Array()
        var totalScore = 0
        for i in 0...9 {
            let dataEntry = RadarChartDataEntry(value: Double(yValues[i]))
            dataEntries.append(dataEntry)
        }
        for i in 0...8 {
            totalScore += yValues[i]
        }
        
        let chartDataSet = RadarChartDataSet(values: dataEntries, label: label)
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = setColor(totalScore)
        chartDataSet.drawValuesEnabled = false
        let chartData = RadarChartData(dataSet: chartDataSet)


        let chartFormatter = RadarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.chartDescription?.text = ""
        self.yAxis.axisMinimum = 0
        self.yAxis.axisMaximum = 2
        self.yAxis.axisRange = 3
        self.yAxis.axisMaxLabels = 4
        self.yAxis.granularityEnabled = true
        self.yAxis.granularity = 1
        self.legend.enabled = false
        self.yAxis.gridAntialiasEnabled = true
        self.animate(xAxisDuration: 1, yAxisDuration: 0.2)
        self.data = chartData
    }
}
