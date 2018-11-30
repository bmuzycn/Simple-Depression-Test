//
//  ReportVC.swift
//  testExport
//
//  Created by Yu Zhang on 9/4/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import MessageUI

protocol ReportDelegate: AnyObject {
    func passResult(user: String, scores: [Int], total: Int, result: String, date: String)
    }
class ReportVC: UIViewController, MFMailComposeViewControllerDelegate{
    var scores = [Int]()
    var total = 0
    var date = ""
    var result = ""
    var str = ""
    var user = ""
    @IBOutlet weak var webViewContainer: UIView!
    var reportView: WKWebView!
    weak var dataDelegate: DataDelegate?
    var reportComposer: ReportComposer!
    var htmlReport = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reportComposer = ReportComposer()
        htmlReport = reportComposer.renderReport(name: user, date: date, scores: scores, total: total, result: result)
        
        let path = Bundle.main.bundlePath
        let url = URL(fileURLWithPath: path)
        reportView.loadHTMLString(htmlReport, baseURL: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        //load reportView
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.reportView = WKWebView (frame: customFrame , configuration: webConfiguration)
        reportView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(reportView)
        reportView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        reportView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        reportView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        reportView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        reportView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
//        reportView.uiDelegate = self
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            print("Swipe Right")
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultViewController
        {
            let vc = segue.destination as? ResultViewController
            self.dataDelegate = vc
            self.dataDelegate?.passResult(user: user)
            FileManager.default.clearTmpDirectory()

        }
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        FileManager.default.clearTmpDirectory()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveToPDF(_ sender: Any) {
        reportComposer.createPDF(html: htmlReport, filename: "reportPHQ-9", formatter: reportView.viewPrintFormatter())
        showOptionsAlert()
    }
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Hi!", message: "Your report has been successfully printed to a PDF file.\n\nWhat do you want to do now?", preferredStyle: UIAlertController.Style.alert)
        
        let actionSave = UIAlertAction(title: "Save pdf", style: UIAlertAction.Style.default) { (action) in
            if let filename = self.reportComposer.pdfFilename{
                print(filename)
                
                let path = URL(fileURLWithPath: filename)
                
                let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
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
                    self.present(vc, animated: true, completion: nil)
                    if let popOver = vc.popoverPresentationController {
                        popOver.sourceView = self.view
                        //popOver.sourceRect =
                        //popOver.barButtonItem
                    }
                }
            }
        
        let actionEmail = UIAlertAction(title: "Send by Email", style: UIAlertAction.Style.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nothing", style: UIAlertAction.Style.default) { (action) in
            
        }
        
        alertController.addAction(actionSave)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("report of PHQ-9")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: reportComposer.pdfFilename!)!as Data, mimeType: "application/pdf", fileName: "reportPHQ-9")
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func infoButton(_ sender: Any) {
        let infoNote = UIAlertController(title: "About Simple Depression Test", message:"Version 1.2 \n By Yu Zhang\n\n\nLast updated on 11/29/2018:\n- New button animation was added.\n- Swipe gestures were enabled.\n- Fixed some minor bugs.\n\nThanks to Daniel Cohen Gindi & Philipp Jahoda for their powerful CHARTS 3.0.\n\nFor more information: https://timyuzhang.com/ ", preferredStyle: UIAlertController.Style.alert)
        infoNote.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(infoNote, animated: true, completion: nil)
    }
}

extension ReportVC: ReportDelegate {
    func passResult(user: String, scores: [Int], total: Int, result: String, date: String) {
        self.user = user
        self.scores = scores
        self.total = total
        self.result = result
        self.date = date
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
            print(error)
            //catch the error somehow
        }
    }
}
