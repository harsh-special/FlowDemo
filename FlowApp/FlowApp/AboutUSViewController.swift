//
//  AboutUSViewController.swift
//  FlowApp
//
//  Created by Parth Adroja on 22/01/17.
//  Copyright © 2017 Parth Adroja. All rights reserved.
//

import UIKit

class AboutUSViewController: UIViewController {
    
    @IBOutlet weak var IBlblTitle: UILabel!
    @IBOutlet weak var IBtxtDescription: UITextView!
    
    var isFrom = 1
    //0 = disclaimerText 1 = About US
    
    let aboutUSText = "THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT "
    let disclaimerText = "THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT THIS IS TESTING TEXT "

    override func viewDidLoad() {
        super.viewDidLoad()
        if isFrom == 0 {
            IBlblTitle.text = "Disclaimer"
            IBtxtDescription.text = disclaimerText
        } else {
            IBlblTitle.text = "About US"
            IBtxtDescription.text = aboutUSText
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func IBbtnCloseTap(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
