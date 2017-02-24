import UIKit
import SwiftyJSON
import MessageUI
import SimplePDF
import SideMenu
import Foundation
import M13Checkbox
import DLRadioButton

class ViewController: UIViewController {

    @IBOutlet weak var IBbtnYes: UIButton!
    @IBOutlet weak var IBbtnNo: UIButton!
    @IBOutlet weak var IBtxtQuestions: UITextView!
    @IBOutlet weak var IBviewDecision: UIView!
    
    @IBOutlet weak var IBviewQuestionaire: UIView!
    @IBOutlet weak var IBviewOptionsContainer:UIView!
    @IBOutlet weak var IBtxtQuestTitle: UITextView!
    
    @IBOutlet weak var IBviewInformative: UIView!
    @IBOutlet weak var IBtxtInfoTitle: UITextView!
    

    var troubleShootParser = GCGModesParser()
    var arrPreviousOptionSelected: [String] = []
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
        troubleShootParser.resetAllArrays()
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
        if troubleShootParser.currentStepType == "redRectangle" {
            let result = troubleShootParser.validateQustionnaire()
            if result.success {
                troubleShootParser.moveToStepChoice(choiceText: result.optionID!)
                setDataToView()
            } else {
                showAlert(title: "", message: result.title!)
            }
        } else {
            if let optionSelected = troubleShootParser.arrOctagonSelected.first {
                let result = troubleShootParser.validateOptionsForOctagon(optionSelected: optionSelected)
                if result.success {
                    troubleShootParser.moveToStepChoice(choiceText: optionSelected)
                } else {
                    showAlert(title: "Sorry", message: result.title!)
                }
                setDataToView()
            }
        }
        
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
    
    //Initialize Parser with data
    func loadParser() {
        troubleShootParser.SetData(data: (dicMode["Mode2"] as! [String : Any]))
    }
}

extension ViewController {
    
    //Set Json Data to View and save data
    func getActualTextForJson(title: String) -> String {
        var actualString = ConstantsDict[title] ?? title
        if actualString == "" {
            actualString = title
        }
        return actualString
    }
    
    // Every time we go to next flow we call to set the data from new toPoint
    func setDataToView() {
        if troubleShootParser.currentStepType == "diamond" {
            showHideViews(showViews: [IBviewDecision], hideViews: [IBviewQuestionaire, IBviewInformative])
            IBtxtQuestions.text = getActualTextForJson(title: troubleShootParser.currentStepText)
        } else if troubleShootParser.currentStepType == "redRectangle" {
            showHideViews(showViews: [IBviewQuestionaire], hideViews: [IBviewDecision, IBviewInformative])
            IBtxtQuestTitle.text = getActualTextForJson(title: troubleShootParser.currentStepText)
            setupOptionsInQuestionaireView(type: troubleShootParser.currentStepType)
        } else if troubleShootParser.currentStepType == "oval" {
            showHideViews(showViews: [IBviewInformative], hideViews: [IBviewDecision, IBviewQuestionaire])
            IBtxtInfoTitle.text = getActualTextForJson(title: troubleShootParser.currentStepText)
        } else if troubleShootParser.currentStepType == "yellowHexa" {
            if troubleShootParser.dicCurrentState["hasChoice"] as! String == "yes" {
                showHideViews(showViews: [IBviewQuestionaire], hideViews: [IBviewDecision, IBviewInformative])
                IBtxtQuestTitle.text = getActualTextForJson(title: troubleShootParser.currentStepText)
                setupOptionsInQuestionaireView(type: troubleShootParser.currentStepType)
            } else {
                showHideViews(showViews: [IBviewInformative], hideViews: [IBviewDecision, IBviewQuestionaire])
                IBtxtInfoTitle.text = getActualTextForJson(title: troubleShootParser.currentStepText)
            }
        } else if troubleShootParser.currentStepType == "octagon" {
            showHideViews(showViews: [IBviewQuestionaire], hideViews: [IBviewDecision, IBviewInformative])
            IBtxtQuestTitle.text = getActualTextForJson(title: troubleShootParser.currentStepText)
            setupOptionsInQuestionaireView(type: troubleShootParser.currentStepType)
        }
    }
    
    func setupOptionsInQuestionaireView(type: String) {
        for subView in IBviewOptionsContainer.subviews {
            subView.removeFromSuperview()
        }
        let options = troubleShootParser.choices
        if let firstOptionValue = troubleShootParser.choices.first as? [String : String] {
            var otherButtons : [OptionsButton] = []
            let firstFrame = CGRect(x: 20, y: 8, width: UIScreen.main.bounds.width - 20, height: 44)
            let firstRadioBtn = createRadioButton(firstFrame, buttonObject: firstOptionValue, color: UIColor.blue);
            for i in 1..<options.count {
                if let optionValue = troubleShootParser.choices[i] as? [String : String] {
                    let frame = CGRect(x: firstFrame.minX, y: (firstFrame.maxY + 6) + 50 * CGFloat(i - 1), width: firstFrame.width, height: firstFrame.height)
                    let radioButton = createRadioButton(frame, buttonObject: optionValue, color: UIColor.blue);
                    otherButtons.append(radioButton)
                }
            }
            firstRadioBtn.otherButtons = otherButtons
            if type == "redRectangle" {
                firstRadioBtn.isMultipleSelectionEnabled = true
                firstRadioBtn.isIconSquare = true
                for button in otherButtons {
                    button.isMultipleSelectionEnabled = true
                    button.isIconSquare = true
                }
            }

        }
    }
    
    func createRadioButton(_ frame : CGRect, buttonObject : [String : String], color : UIColor) -> OptionsButton {
        let radioButton = OptionsButton(frame: frame)
        radioButton.titleLabel!.font = UIFont.systemFont(ofSize: 17)
        radioButton.buttonOptionID = buttonObject["id"]!
        radioButton.setTitle(buttonObject["title"]!, for: UIControlState())
        radioButton.setTitleColor(color, for: UIControlState())
        radioButton.iconColor = color
        radioButton.indicatorColor = color
        radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left;
        radioButton.addTarget(self, action: #selector(logSelectedButton), for: UIControlEvents.touchUpInside)
        IBviewOptionsContainer.addSubview(radioButton)
        return radioButton;
    }
    
    // Call everytime when a radio or checkbox is selected
    func logSelectedButton(_ radioButton : OptionsButton) {
        if (radioButton.isMultipleSelectionEnabled) {
            troubleShootParser.arrQuestionaireSelected.removeAll()
            troubleShootParser.dicStateMode.removeValue(forKey: "Option1")
            troubleShootParser.dicStateMode.removeValue(forKey: "Option2")
            troubleShootParser.dicStateMode.removeValue(forKey: "Option3")
            troubleShootParser.dicStateMode.removeValue(forKey: "Option4")
            troubleShootParser.dicStateMode.removeValue(forKey: "Option5")
            for button in radioButton.selectedButtons() as! [OptionsButton] {
                troubleShootParser.arrQuestionaireSelected.append(button.buttonOptionID)
                troubleShootParser.dicStateMode[button.buttonOptionID] = "yes"
                print(String(format: "%@ is selected.\n", button.titleLabel!.text!));
            }
        } else {
            
            troubleShootParser.arrOctagonSelected.removeAll()
            if let removePreviousElement = arrPreviousOptionSelected.first {
                troubleShootParser.dicStateMode.removeValue(forKey: removePreviousElement)
            }
            arrPreviousOptionSelected.removeAll()
            troubleShootParser.arrOctagonSelected.append(radioButton.buttonOptionID)
            troubleShootParser.dicStateMode[radioButton.buttonOptionID] = "yes"
            arrPreviousOptionSelected.append(radioButton.buttonOptionID)
            print(String(format: "%@ is selected.\n", radioButton.selected()!.titleLabel!.text!));
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
        
    func showAlert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController {

    func createPDFWithData(dataArr: [[String : String]]) {
        
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize)
        for text in dataArr {
            for (key,value) in text {
                let question = ConstantsDict[key]
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
        let sendMailErrorAlert = UIAlertView(title: "EXIT", message: "", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
