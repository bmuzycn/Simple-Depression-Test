//
//  ViewController.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 4/21/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
protocol UserDelegate: AnyObject {
    func userReady(name: String)
}
class ViewController: UIViewController, UserDelegate {
    //set 10 questions into array
    let allquestions = QuestionBank()
    var scores = Array(repeating: 0, count: 10) //a parallel array stores scores
    var totalScore = 0
    var questionNum = 0
    var result = ""
    var severity = ""
    var cUser = ""
    var isButtonPressed = Array(repeating: false, count: 10)
    weak var dataDelegate: DataDelegate?
    let phqArray = ["Anhedonia".localized,"Low Mood".localized,"Insomnia".localized,"Fatigue".localized,"Appetite".localized,"Worthlessness".localized,"Concentration".localized,"Movement".localized,"Suicide".localized]
    
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var questionLabel: UITextView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var qNum: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    var observer: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(forName: NSNotification.Name("cUser"), object: nil, queue: .main) { (notification) in
            let userVC = notification.object as! UserViewController
            self.cUser = userVC.currentUser
            self.userName.text = self.cUser
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setQuestionNum()
        //add swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)


        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startOver()
        alertNote()

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
//        sender.titleLabel?.text = sender.currentTitle!+"⭕️".localized
        UIView.performWithoutAnimation {
            sender.setTitle(sender.currentTitle!+"⭕️".localized, for: .normal)
        }
        UIView.animate(withDuration: 0.3, delay: 0.3, options: .allowAnimatedContent, animations: {
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
    func checkScores() {
        totalScore = 0
        for i in 0...8 {
            totalScore += scores[i]
        }
        var count = 0
        for i in 0...7 {
            if scores[i] > 1 {
                count += 1
            }
        }
        if scores[8] > 0 {
            count = count + 1
        }
        if count > 4 && scores[9]>0 && (scores[0] > 1 || scores[1] > 1) {
           result = "Major Depressive Disorder".localized
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
            result = "depressed mood but cannot be confirmed as depressive disorder at this point".localized
            
        }
        
        if scores[8] > 0 {
            result = result + "\n" + "(For initial patient with suicidal or self-injury risk, you need to see a doctor as soon as possible)".localized
        }
        
        switch totalScore  {
        case 0:
            severity = "Zero point".localized
        case 1...4:
            severity = "Minimal depression".localized
        case 5...9:
            severity = "Mild depression".localized
        case 10...14:
            severity = "Moderate depression".localized
        case 15...19:
            severity = "Moderate severe depression".localized
        case 20...27:
            severity = "Severe depression".localized

        default:
            print("")
        }
        

    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        next()
    }
    @IBAction func backButton(_ sender: UIButton) {
        back()
    }
    
    func next() {
        if questionNum < 9 {
            questionNum += 1
            questionLabel.text = allquestions.questions[questionNum]
            changeTitle()
//            progressUpdate()
            progressBar.progress += 0.1
            setQuestionNum()
            
        }
        else {

            progressBar.progress += 0.1

            checkScores()
            let alert = UIAlertController(title: "Result".localized, message: "Your probably have ".localized + result.localized + " with severity score of ".localized + "\(totalScore)/27 " + "as ".localized + severity + "\n\n"+"Depression Severity Reference:".localized+"\n" + "Severe 21-27\nModerate severe 16-20\nMild moderate 10-15\nMild 5-9\nMinimal 1-4".localized, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Restart".localized, style: .default, handler: { (UIAlertAction) in self.startOver()}))
            alert.addAction(UIAlertAction(title: "Save".localized, style: .default, handler: { (UIAlertAction) in self.goResultView()}))
            
            present(alert,animated: true, completion: nil)
            
        }
        
    }
    
    func back() {
        if questionNum > 0 {
            questionNum -= 1
            questionLabel.text = allquestions.questions[questionNum]
            changeTitle()
            progressBar.progress -= 0.1
            setQuestionNum()

        } else {
            let alert = UIAlertController(title: "Warning⚠️".localized, message: "Your result will be lost. Still want to quit?".localized, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue".localized, style: .default, handler: { (UIAlertAction) in self.dismiss(animated: true, completion: nil)}))
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler:nil))
            
            present(alert,animated: true, completion: nil)
            
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "userView") as! UserViewController
//            controller.userDelegate = self
//            self.present(controller, animated: true, completion: nil)
//

        }
    }
    
    func startOver() {
        questionNum = 0
        totalScore = 0
        scores = Array(repeating:0, count:10)
        isButtonPressed = Array(repeating: false, count: 10)
        questionLabel.text = allquestions.questions[questionNum]
        changeTitle()
        progressUpdate()
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
            let saveData = DataStored(context: context)
            saveData.saveData(totalScore, scores, result, cUser)
        }
    }
    func goResultView() {
        performSegue(withIdentifier: "toResultView",
                     sender: self)
    }
    
    func alertNote() {
        
        print("alert note!")
        let note = UIAlertController(title: "Hi, ".localized+"\(cUser)"+" , Note!".localized, message: "Since the questionnaire relies on patient self-report, all responses should be verified by the clinician, and a definitive diagnosis is made on clinical grounds taking into account how well the patient understood the questionnaire, as well as other relevant information from the patient. Diagnoses of Major Depressive Disorder or Other Depressive Disorder also require impairment of social, occupational, or other important areas of functioning (Question #10) and ruling out normal bereavement, a history of a Manic Episode (Bipolar Disorder), and a physical disorder, medication, or other drug as the biological cause of the depressive symptoms.".localized , preferredStyle: .alert)
        
        note.addAction(UIAlertAction(title: "Continue".localized, style: .default, handler: nil))

        if let presented = self.presentedViewController {
            presented.removeFromParent()
        }
        if presentedViewController == nil {
        self.present(note, animated: true, completion: nil)
        }
    }
    
    
    func changeTitle() {
        UIView.setAnimationsEnabled(false)
        if questionNum == 9 {
            button1.setTitle("Not difficult at all".localized,for:UIControl.State.normal)
            button2.setTitle("Somewhat difficult".localized,for:UIControl.State.normal)
            button3.setTitle("Very difficult".localized,for:UIControl.State.normal)
            button4.setTitle("Extremely difficult".localized,for:UIControl.State.normal)
            
            var strProblems = ""
            for n in 0...8 {
                    if scores[n] > 0 {
                        strProblems += "\(phqArray[n]); "
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
        progressBar.transform = CGAffineTransform(scaleX: 1.0, y: 2.0)
        progressBar.progress = Float(questionNum)/9.0
//        if questionNum == 0 {
//            progressBar.progress = 0.0
//
//        }
//        else if questionNum < 9 {
//            progressBar.progress += 0.1
//
//        }
//        else {
//            progressBar.progress = 1
//        }
    }
    
    //set question label text
    func setQuestionNum() {
        qNum.text = "question: ".localized + "\(questionNum + 1)/10"
    }
    
    
    //receive data from user delegate
    func userReady(name: String) {
        cUser = name
    }
}

