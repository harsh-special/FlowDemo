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
import Foundation
import M13Checkbox

class ViewController: UIViewController {

    @IBOutlet weak var IBbtnYes: UIButton!
    @IBOutlet weak var IBbtnNo: UIButton!
    @IBOutlet weak var IBtxtQuestions: UITextView!
    @IBOutlet weak var IBviewDecision: UIView!
    
    @IBOutlet weak var IBviewQuestionaire: UIView!
    @IBOutlet weak var IBtxtQuestTitle: UITextView!
    @IBOutlet weak var IBQCheckBox1: M13Checkbox!
    @IBOutlet weak var IBQCheckBox2: M13Checkbox!
    @IBOutlet weak var IBQCheckBox3: M13Checkbox!
    @IBOutlet weak var IBQCheckBox4: M13Checkbox!
    @IBOutlet weak var IBQCheckBox5: M13Checkbox!
    
    @IBOutlet weak var IBviewInformative: UIView!
    @IBOutlet weak var IBtxtInfoTitle: UITextView!
    

    var arrSelectedAnswer = [String]()
    var troubleShootParser = GCGModesParser()
    var arrSavedStateDict = [[String: String]]()
    lazy var dicMode = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.menuFadeStatusBar = false
        getContentsFromJsonFile()

        troubleShootParser.onSuccessfulEnd = { [unowned self] in
            self.showSendMailErrorAlert()
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Global Methods -
    
    @IBAction func IBbtnResetTap(_ sender: UIButton) {
        resetDataArrays()
        getContentsFromJsonFile()
    }
    
    // MARK: - Decision Methods -
    
    @IBAction func IBbtnYesTap(_ sender: UIButton) {
        troubleShootParser.moveToStepYes()
        setDataToView()
    }
    
    @IBAction func IBbtnNoTap(_ sender: UIButton) {
        troubleShootParser.moveToStepNo()
        setDataToView()
    }
 
    // MARK: - Questionaire Methods -
    
    @IBAction func IBbtnNextTap(_ sender: UIButton) {
        arrSelectedAnswer.removeAll()
        if IBQCheckBox1.checkState == .checked {
            print("troubleShootParser.choices.first \(troubleShootParser.choices.first)")
            arrSelectedAnswer.append((troubleShootParser.choices.first?.keys.first)!)
        }
        if IBQCheckBox2.checkState == .checked {
            arrSelectedAnswer.append(troubleShootParser.choices[1].keys.first!)
        }
        if IBQCheckBox3.checkState == .checked {
            arrSelectedAnswer.append(troubleShootParser.choices[2].keys.first!)
        }
        if IBQCheckBox4.checkState == .checked {
            arrSelectedAnswer.append(troubleShootParser.choices[3].keys.first!)
        }
        if IBQCheckBox5.checkState == .checked {
            arrSelectedAnswer.append("PP5")
        }
        print(arrSelectedAnswer)
        troubleShootParser.moveToStepChoice(choiceText: arrSelectedAnswer.first!)
        setDataToView()
    }
    
    // MARK: - Informative Methods -

    @IBAction func IBbtnOkTap(_ sender: UIButton) {
        troubleShootParser.moveToStepOK()
        setDataToView()
    }
}



extension ViewController {

    //Read Json File and Parse
    func getContentsFromJsonFile() {
        let path = Bundle.main.path(forResource: "Modes", ofType: "json")
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: path!), options: Data.ReadingOptions.dataReadingMapped)
       // modesJson = JSON(data: jsonData)
        dicMode = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        loadParser()
        setDataToView()
    }
    
    func loadParser() {
        troubleShootParser.SetData(data: (dicMode["Mode2"] as! [String : Any]))
    }
}

extension ViewController {
    
    //Set Json Data to View and save data
    func getActualTextForJson(title: String) -> String {
        let actualString = Constants().value(forKey: title) as! String
        return actualString
    }
    
    func setDataToView() {
        if troubleShootParser.currentStepType == "diamond" {
            IBtxtQuestions.text = troubleShootParser.currentStepText
            showHideViews(showViews: [IBviewDecision], hideViews: [IBviewQuestionaire, IBviewInformative])
            IBtxtQuestions.text = troubleShootParser.currentStepText
        } else if troubleShootParser.currentStepType == "redRectangle" {
            showHideViews(showViews: [IBviewQuestionaire], hideViews: [IBviewDecision, IBviewInformative])
            IBQCheckBox1.checkState = .unchecked
            IBQCheckBox2.checkState = .unchecked
            IBQCheckBox3.checkState = .unchecked
            IBQCheckBox4.checkState = .unchecked
            IBQCheckBox5.checkState = .unchecked
            IBtxtQuestTitle.text = troubleShootParser.currentStepText
        } else if troubleShootParser.currentStepType == "oval" {
            showHideViews(showViews: [IBviewInformative], hideViews: [IBviewDecision, IBviewQuestionaire])
            IBtxtInfoTitle.text = troubleShootParser.currentStepText
        } else if troubleShootParser.currentStepType == "yellowHexa" {
            showHideViews(showViews: [IBviewQuestionaire], hideViews: [IBviewDecision, IBviewInformative])
            IBtxtQuestTitle.text = troubleShootParser.currentStepText
            IBQCheckBox1.checkState = .unchecked
            IBQCheckBox2.checkState = .unchecked
            IBQCheckBox3.checkState = .unchecked
            IBQCheckBox4.checkState = .unchecked
            IBQCheckBox5.checkState = .unchecked
        }
    }
    
    func showHideViews(showViews: [UIView], hideViews: [UIView]) {
        for showView in showViews {
            showView.isHidden = false
        }
        for hideView in hideViews {
            hideView.isHidden = true
        }
    }
    
    func resetDataArrays() {
        arrSavedStateDict.removeAll()
        arrSelectedAnswer.removeAll()
//        arrTrackAllEvents.removeAll()
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
