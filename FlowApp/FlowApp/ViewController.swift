//
//  ViewController.swift
//  FlowApp
//
//  Created by Parth Adroja on 10/12/16.
//  Copyright © 2016 Parth Adroja. All rights reserved.
//

import UIKit
import SwiftyJSON
import MessageUI
import SimplePDF
import SideMenu

class ViewController: UIViewController {

    @IBOutlet weak var IBlblQuestions: UILabel!
    @IBOutlet weak var IBbtnYes: UIButton!
    @IBOutlet weak var IBbtnNo: UIButton!
    
    var arrSavedStateDict = [[String: String]]()
    var modesJson: JSON?
    var nextPoint: String? {
        didSet {
            IBlblQuestions.text = modesJson![nextPoint!]["text"].stringValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.menuFadeStatusBar = false
        getContentsFromJsonFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func IBbtnYesTap(_ sender: UIButton) {
        if let toPoint = nextPoint {
            goToNextPointOnYes(toPoint: toPoint)
            saveDataForPdf(key: IBlblQuestions.text!, value: "YES")
        }
    }
    
    @IBAction func IBbtnNoTap(_ sender: UIButton) {
        if let toPoint = nextPoint {
            goToNextPointOnNo(toPoint: toPoint)
            saveDataForPdf(key: IBlblQuestions.text!, value: "NO")
        }
    }
    
    @IBAction func IBbtnResetTap(_ sender: UIButton) {
        arrSavedStateDict.removeAll()
        getContentsFromJsonFile()
    }
}

extension ViewController {

    //Read Json File
    func getContentsFromJsonFile() {
        let path = Bundle.main.path(forResource: "Modes", ofType: "json")
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!), options: Data.ReadingOptions.dataReadingMapped)
        modesJson = JSON(data: jsonData)
        if modesJson != nil {
            print(modesJson!)
            setDataToView()
        }
    }
}

extension ViewController {
    
    //Set Json Data to View and save data
    func setDataToView() {
        IBlblQuestions.text = modesJson!["Start"]["text"].stringValue
        nextPoint = modesJson!["Start"]["toPoint"].stringValue
    }
    
    func goToNextPointOnYes(toPoint: String) {
        nextPoint = modesJson![toPoint]["Yes"]["toPoint"].stringValue
    }
    
    func goToNextPointOnNo(toPoint: String) {
        nextPoint = modesJson![toPoint]["No"]["toPoint"].stringValue
    }
    
    func saveDataForPdf(key: String, value: String) {
        let dataDict = [key: value]
        arrSavedStateDict.append(dataDict)
//        createPDFWithData(dataArr: arrSavedStateDict)
    }
}

extension ViewController {

    func createPDFWithData(dataArr: [[String : String]]) {
        
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize)
        for text in dataArr {
            for (key,value) in text {
                let question = key
                let answer = value
                pdf.addText("\(question)")
                pdf.addText(" \(answer)")
            }
        }
        
        if let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let fileName = "flow.pdf"
            let documentsFileName = docDir + "/" + fileName
            let pdfData = pdf.generatePDFdata()
            do {
                try pdfData.write(to: URL(fileURLWithPath: documentsFileName), options: .atomic)
                print("\nThe generated pdf can be found at:")
                print("\n\t\(documentsFileName)\n")
            } catch {
                print(error)
            }
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["parth.adroja.sa@gmail.com"])
        mailComposerVC.setSubject("Sending you an pdf file...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pdfFileName = documentsPath.appending("/flow.pdf")
        let fileData = NSData(contentsOfFile: pdfFileName)
        mailComposerVC.addAttachmentData(fileData as! Data, mimeType: "application/pdf ", fileName: "flow")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
