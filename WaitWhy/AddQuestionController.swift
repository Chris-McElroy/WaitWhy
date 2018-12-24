//
//  AddQuestionController.swift
//  WaitWhy
//
//  Created by 4 on 12/18/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import Foundation

import UIKit

class AddQuestionController: UIViewController {

    @IBOutlet weak var questionView: UITextView!
    
    var mvc:MasterViewController?
    
    let impact = UIImpactFeedbackGenerator(style: .medium)
    
    func configureView() {
        // Update the user interface for the detail item.
        // questionView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    @IBAction func submitted(_ sender: Any) {
        impact.impactOccurred()
        if let questionText = questionView.text {
            mvc?.insertNewQuestion(questionText)
            questionView.text = ""
        }
    }
    
}
