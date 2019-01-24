//
//  ViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 4/21/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData
//protocol UserDelegate: AnyObject {
//    func userReady(name: String)
//}
class QuestionViewController: UIViewController, DataDelegate {
    func passResult(user: String) {
        cUser = user
    }
    //set 10 questions into array
    var allquestions: [String] = []
    var totalScore = 0
    var questionNum = 0
    var result = ""
    var severity = ""
    var cUser = ""
    var scores: [Int] = [] //a parallel array stores scores Array(repeating: 0, count: 10)
    var isButtonPressed: [Bool] = []    //Array(repeating: false, count: 10)
    weak var dataDelegate: DataDelegate?
    var isFirstTimeUser: Any?
    var questionArray: [String] = []
    var questionSet = "phq9"
    var lastScores: [Int]?
    var lastTotal: Int?

    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var qNum: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    @IBAction func unwindSegueToTest(unwindSegue: UIStoryboardSegue){
        print("welcome to testView")
    }
    
    fileprivate func setAppearance() {
        titleLabel.font = Settings.textFont
        titleLabel.textColor = Settings.textColor
        titleLabel.backgroundColor = Settings.bgColorForTextField
        questionLabel.font = Settings.textFont
        questionLabel.textColor = Settings.textColor
        questionLabel.backgroundColor = Settings.bgColorForTextField
        qNum.textColor = Settings.textColor
        qNum.font = Settings.textFont
        userName.textColor = Settings.textColor
        userName.font = Settings.textFont
        view.backgroundColor = Settings.colorForHeadView
        
        button1.titleLabel?.font = Settings.textFont
        button2.titleLabel?.font = Settings.textFont
        button3.titleLabel?.font = Settings.textFont
        button4.titleLabel?.font = Settings.textFont

    }
    
    fileprivate func setBackGroundImage() {
        if let bgImageView = view.viewWithTag(100) {
            bgImageView.removeFromSuperview()
            print("remove success")
        }
        if let backGroundImage = Settings.bgImage {
            let bgImageView = UIImageView(frame: view.frame)
            bgImageView.tag = 100
            bgImageView.image = backGroundImage
            bgImageView.contentMode = .scaleAspectFill
            view.addSubview(bgImageView)
            bgImageView.translatesAutoresizingMaskIntoConstraints = false
            let views = ["view": bgImageView]
            let hConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", metrics: nil, views: views)
            let vConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", metrics: nil, views: views)
            let allConstraints = hConstraint + vConstraint
            NSLayoutConstraint.activate(allConstraints)
            view.sendSubviewToBack(bgImageView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        questionArray = QuestionBank.questionArray
        questionSet = Settings.questionSet
        allquestions = QuestionBank.questions
        let countOFQuestions = allquestions.count
        scores = Array(repeating: 0, count: countOFQuestions)
        isButtonPressed = Array(repeating: false, count: countOFQuestions)
        setBackGroundImage()
        let userVC = tabBarController?.viewControllers?[0] as! UserViewController
        cUser = userVC.currentUser
        userName.text = cUser
        setAppearance()
        startOver()
        isFirstTimeUser = UserDefaults.standard.value(forKey: cUser)
        if isFirstTimeUser == nil {
            alertNote()
        } else {
            fetchLastData()
        }
        print("questionView.cUser:\(cUser)")
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//            NotificationCenter.default.removeObserver(self)
            cUser = ""
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        setQuestionNum()
        //add swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

    }

    fileprivate func fetchLastData() {
        let context = AppDelegate.viewContext
        let request: NSFetchRequest = DataStored.fetchRequest()
        request.predicate = NSPredicate(format: "userName = %@", cUser)
        request.fetchLimit = 1
        do {
            let fetchResult = try context.fetch(request)
            if fetchResult.isEmpty == false {
            lastScores = fetchResult[0].value(forKey: "scores") as? [Int]
            lastTotal = fetchResult[0].value(forKey: "totalScore") as? Int
            }
        } catch {
            print("there is a error: \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            back()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            print("Swipe Left")
            next()
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        print("\(questionNum): \(sender.tag)")
        UIView.performWithoutAnimation {
            sender.setTitle(sender.currentTitle!+"⭕️".localized, for: .normal)
        }
        UIView.animate(withDuration: 0.1, delay: 0.3, options: .allowAnimatedContent, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.view.layoutIfNeeded()
        }) { finished in
                sender.transform = CGAffineTransform.identity
                self.scores[self.questionNum] = sender.tag
                self.isButtonPressed[self.questionNum] = true
                self.next()
            }
    }
    
    //assign the result based on scores
    fileprivate func calculatePhq9() {
        totalScore = 0
        for i in 0...allquestions.count - 2 {
            totalScore += scores[i]
        }
        switch totalScore  {
        case 0:
            severity = "no depression".localized
        case 1...4:
            severity = "minimal depression".localized
        case 5...9:
            severity = "mild depression".localized
        case 10...14:
            severity = "moderate depression".localized
        case 15...19:
            severity = "moderately severe depression".localized
        case 20...27:
            severity = "severe depression".localized
            
        default:
            print("out of range error")
        }
        var countDSM5 = 0
        var count = 0
        for i in 0...7 {
            if scores[i] > 1 {
                count += 1
            }
        }
        for i in 0...7 {
            if scores[i] == 3 {
                countDSM5 += 1
            }
        }

        if scores[8] > 0 {
            count = count + 1
            countDSM5 += 1
        }
        if countDSM5 > 4 && scores[9]>0 && (scores[0] == 3 || scores[1] == 3) {
            result = "Major Depressive Disorder".localized + "(according to DSM-5)".localized
        }
        else if count > 4 && scores[9]>0 && (scores[0] > 1 || scores[1] > 1) {
            result = "Major Depressive Disorder".localized + "(*)"
        }
        else if count>1 && scores[9]>0 && count<5 && (scores[0] > 1 || scores[1] > 1) {
            result = "other Depressive Disorder".localized
        }
        else if scores[9]==0 && totalScore>0 {
            result = "depressive symptoms but have no effect on your daily life and normal functioning".localized
        }
            
        else if totalScore == 0 {
            result = "no depression".localized
        }
        else {
            result = "depressive symptoms but cannot be confirmed as depressive disorder at this point".localized
            
        }
        if isFirstTimeUser == nil {
            result = "Your probably have ".localized + result.localized + " with severity score of ".localized + "\(totalScore)/27 " + "as ".localized + severity + ".".localized
        } else {
            result = "Your probably have ".localized + severity + " with severity score of ".localized + "\(totalScore)/27"
        }
        if totalScore >= 10 && (isFirstTimeUser == nil) {
            result = result + "\n" + "A full clinical assessment is recommended.".localized
        }
        
        if scores[8] > 0  && (isFirstTimeUser == nil) {
            result = result + "\n" + "(For initial patient with suicide or self-injury risk, you need to see a doctor as soon as possible)".localized
        }
        
        if let lastSuicideScore = lastScores?[8], scores[8] > lastSuicideScore {
            result = result + "\n" + "(The result indicates your suicide risk increased. Regardless of your total score, you should see a doctor as soon as possible)".localized
        }
    }
    
    fileprivate func calculateGad7() {
        totalScore = 0
        for i in 0...allquestions.count - 2 {
            totalScore += scores[i]
        }
        switch totalScore  {
        case 0...4:
            severity = "no anxiety".localized
        case 5...9:
            severity = "mild anxiety".localized
        case 10...14:
            severity = "moderate anxiety".localized
        case 15...21:
            severity = "severe anxiety".localized
        default:
            print("out of range error")
        }
        if totalScore > 7 && scores[7] > 0 {
            result = "Your probably have generalized anxiety disorder".localized + "(*)" + " with severity score of ".localized + "\(totalScore)/21" + " as " + severity + ".".localized + "\n" + "To determine the presence and type of anxiety disorder, further assessment by a mental health professional is recommended.".localized
        }
        if totalScore > 9 && scores[7] > 0 {
            result = "Your probably have generalized anxiety disorder".localized + " with severity as " + severity + ".".localized + "\n" + "To determine the presence and type of anxiety disorder, further assessment by a mental health professional is recommended.".localized
        } else {
            result = "You may experience ".localized + severity + ".".localized
            
        }
    }
    
    func checkScores() {
        if questionSet == "phq9" {
            calculatePhq9()
        } else if questionSet == "gad7" {
            calculateGad7()
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        next()
    }
    @IBAction func backButton(_ sender: UIButton) {
        back()
    }
    
    func next() {
        if questionNum < allquestions.count - 1 {
            progressUpdate()
            questionNum += 1
            questionLabel.text = allquestions[questionNum]
            changeTitle()
//            progressBar.progress += Float(1/allquestions.count)
            setQuestionNum()
        }
        else {
            progressUpdate()
            checkScores()
            let alert = UIAlertController(title: "Result".localized, message: result, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Restart".localized, style: .default, handler: { (UIAlertAction) in self.startOver()}))
            alert.addAction(UIAlertAction(title: "Save".localized, style: .default, handler: { (UIAlertAction) in
                UserDefaults.standard.set(true, forKey: self.cUser)
                self.goResultView()}))
            present(alert,animated: true, completion: nil)
        }
    }
    
    func back() {
        if questionNum > 0 {
            questionNum -= 1
            progressUpdate()
            questionLabel.text = allquestions[questionNum]
            changeTitle()
            setQuestionNum()

        } else {
            progressBar.progress = 0.0
            let alert = UIAlertController(title: "Warning⚠️".localized, message: "Your result will be lost. Still want to quit?".localized, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue".localized, style: .default, handler: { (UIAlertAction) in
                self.performSegue(withIdentifier: "unwindSegueToUserView", sender: self) 
            }))
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))
            present(alert,animated: true, completion: nil)
        }
    }
    
    func startOver() {
        questionNum = 0
        totalScore = 0
        lastTotal = nil
        lastScores = nil
        fetchLastData()
        scores = Array(repeating:0, count:allquestions.count)
        isButtonPressed = Array(repeating: false, count: allquestions.count)
        questionLabel.text = allquestions[questionNum]
        changeTitle()
        progressBar.progress = 0.0
        setQuestionNum()
        titleLabel.text = "Over the last 2 weeks, how often have you been bothered by any of the following problems?".localized
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultViewController
        {
            let vc = segue.destination as? ResultViewController
            dataDelegate = vc
            dataDelegate?.passResult(user: cUser)
            let context = AppDelegate.viewContext
            switch Settings.questionSet {
            case "phq9":
                let saveData = DataStored(context: context)
                saveData.saveData(totalScore, scores, result, cUser)
            case "gad7":
                let saveData = DataStoredGad7(context: context)
                saveData.saveData(totalScore, scores, result, cUser)
            default: break
            }
        }
    }
    func goResultView() {
        performSegue(withIdentifier: "unwindToResultView",
                     sender: self)
    }
    
    func alertNote() {
        var alertMessage: String = ""
        switch Settings.questionSet {
        case "phq9":
            alertMessage = "Since the questionnaire relies on patient self-report, all responses should be verified by the clinician, and a definitive diagnosis is made on clinical grounds taking into account how well the patient understood the questionnaire, as well as other relevant information from the patient. Diagnoses of Major Depressive Disorder or Other Depressive Disorder also require impairment of social, occupational, or other important areas of functioning (Question #10) and ruling out normal bereavement, a history of a Manic Episode (Bipolar Disorder), and a physical disorder, medication, or other drug as the biological cause of the depressive symptoms.".localized
        case "gad7":
            alertMessage = "GAD-7 is a sensitive self-administrated test to assess generalized anxiety disorder(GAD), normally used in outpatient and primary care settings for referral to psychiatrist pending outcome. However, it cannot be used as replacement for clinical assessment and additional evaluation should be used to confirm a diagnosis of GAD.".localized
        default:
            break
        }
        print("alert note!")
        let note = UIAlertController(title: "Hi, ".localized+"\(cUser)"+" , Note!".localized, message: alertMessage, preferredStyle: .alert)
        note.addAction(UIAlertAction(title: "Continue".localized, style: .default, handler: nil))
        if presentedViewController == nil {
        self.present(note, animated: true, completion: nil)
        }
    }
    
    
    func changeTitle() {
        UIView.setAnimationsEnabled(false)
        if questionNum == allquestions.count - 1 {
            button1.setTitle("Not difficult at all".localized,for:UIControl.State.normal)
            button2.setTitle("Somewhat difficult".localized,for:UIControl.State.normal)
            button3.setTitle("Very difficult".localized,for:UIControl.State.normal)
            button4.setTitle("Extremely difficult".localized,for:UIControl.State.normal)
            
            var strProblems = ""
            for n in 0...allquestions.count - 2 {
                    if scores[n] > 0 {
                        strProblems += "\(questionArray[n]); "
                        titleLabel.text = strProblems
                    }
            }
        }
            
        else {
            button1.setTitle("Not at all".localized,for:UIControl.State.normal)
            button2.setTitle("Several days".localized,for:UIControl.State.normal)
            button3.setTitle("More than half the days".localized,for:UIControl.State.normal)
            button4.setTitle("Nearly every day".localized,for:UIControl.State.normal)
        }

        //mark the button that already pressed
        let buttonNum = scores[questionNum]
        let buttons = [button1, button2, button3, button4]
        if isButtonPressed[questionNum] {
            buttons[buttonNum]?.setTitle((buttons[buttonNum]?.currentTitle)! + "⭕️".localized, for: UIControl.State.normal)
        }
        UIView.setAnimationsEnabled(true)

    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    func progressUpdate() {
        progressBar.progress = Float(questionNum+1)/Float(allquestions.count)

    }
    
    //set question label text
    func setQuestionNum() {
        qNum.text = "question: ".localized + "\(questionNum + 1)/\(allquestions.count)"
    }
    

}

