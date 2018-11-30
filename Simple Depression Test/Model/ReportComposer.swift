//
//  Report.swift
//  testExport
//
//  Created by Yu Zhang on 9/4/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
class ReportComposer: NSObject {
    
    var pdfFilename: String!
//    var name: String?
//    var date: String?
//    var scores: [Int]?
//    var totalScore: Int?
//    var result: String?
//    var htmlCode = ""
    let nameRS = "id=name"
    let dateRS = "<input type=date style=font-size:14pt id=date>"
    let totalRS = "max=27"
    
    override init() {
        super.init()
    }
    
    func renderReport(name: String, date: String, scores: [Int], total: Int, result: String) -> String {
        if let reportTemplate = Bundle.main.path(forResource: "report",ofType:"html") {
        do {
            var htmlStr = try String(contentsOfFile: reportTemplate)
            htmlStr = htmlStr.replacingOccurrences(of:nameRS, with: nameRS+" value = \(name)")
            if date != "" {
            htmlStr = htmlStr.replacingOccurrences(of:dateRS, with: date)
            }
            var i = 0
                for n in scores {
                    htmlStr = htmlStr.replacingOccurrences(of:"myCheck\(i)\(n)", with:"myCheck\(i)\(n)"+" checked")
                    i = i + 1
                }

            htmlStr = htmlStr.replacingOccurrences(of: totalRS, with:totalRS + " value=\(total)")
            
            if result != "" {
            htmlStr = htmlStr.replacingOccurrences(of:"<INPUT TYPE=text id=result style=\"width:100%\">", with:"<font color=\"red\">\(result.localized)</font>")
            }
            htmlStr = htmlStr.replacingOccurrences(of: "image001", with: "\(NSTemporaryDirectory())/image001")
            
            htmlStr = htmlStr.replacingOccurrences(of: "image002", with: "\(NSTemporaryDirectory())/image002")

            
            return htmlStr
            }
                
                
        catch{
            print("unable to open the template")
            print(error)
        }
    }
        return ""
}
    
    func createPDF(html: String, filename: String, formatter: UIViewPrintFormatter){
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x:0,y:0,width:612,height:792)
        let printable = page.insetBy(dx:30, dy:30)
        render.setValue(NSValue(cgRect:page),forKey: "paperRect")
        render.setValue(NSValue(cgRect:printable),forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        print(render.numberOfPages)

        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext()
        let path = "\(NSTemporaryDirectory())\(filename).pdf"
        pdfFilename = path
        pdfData.write(toFile: path, atomically: true)
        print(path)
    }
    
//
//    func exportHTMLContentToPDF(HTMLContent: String) {
//        let printPageRenderer = PrintPageRenderer()
//
//        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
//        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
//
//        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
//
//        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/reportPHQ-9.pdf"
//        pdfData?.write(toFile: pdfFilename!, atomically: true)
//
//        print(pdfFilename!)
//    }
//
//    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
//        let data = NSMutableData()
//
//        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
//
//        for i in 0..<printPageRenderer.numberOfPages {
//        UIGraphicsBeginPDFPage()
//        printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
//        }
//        UIGraphicsEndPDFContext()
//
//        return data
//    }
}
