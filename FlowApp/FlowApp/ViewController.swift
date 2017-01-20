//
//  ViewController.swift
//  FlowApp
//
//  Created by Parth Adroja on 10/12/16.
//  Copyright © 2016 Parth Adroja. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var IBlblQuestions: UILabel!
    @IBOutlet weak var IBbtnYes: UIButton!
    @IBOutlet weak var IBbtnNo: UIButton!
    
    var modesJson: JSON?
    var nextPoint: String? {
        didSet {
            IBlblQuestions.text = modesJson![nextPoint!]["text"].stringValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContentsFromJsonFile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func IBbtnYesTap(_ sender: UIButton) {
        if let toPoint = nextPoint {
            goToNextPointOnYes(toPoint: toPoint)
        }
    }
    
    @IBAction func IBbtnNoTap(_ sender: UIButton) {
        if let toPoint = nextPoint {
             goToNextPointOnNo(toPoint: toPoint)
        }
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
    
    //Set Json Data to View
    func setDataToView() {
        IBlblQuestions.text = modesJson!["Start"]["text"].stringValue
        nextPoint = modesJson!["Start"]["toPoint"].stringValue
    }
    
    func goToNextPointOnYes(toPoint: String) {
        nextPoint = modesJson![toPoint]["Yes"]["toPoint"].stringValue
        print(nextPoint!)
    }
    
    func goToNextPointOnNo(toPoint: String) {
        nextPoint = modesJson![toPoint]["No"]["toPoint"].stringValue
        print(nextPoint!)
    }
    
}
