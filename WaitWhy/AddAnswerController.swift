//
//  AddAnswerController.swift
//  WaitWhy
//
//  Created by 4 on 12/20/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import Foundation

import UIKit

class AddAnswerController: UIViewController {
    
    @IBOutlet weak var answerView: UITextView!
    // answer view
    var sqc:ShowQuestionController?
    
    let impact = UIImpactFeedbackGenerator(style: .medium)
    
    func configureView() {
        // Update the user interface for the detail item.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    @IBAction func submitted(_ sender: Any) {
        impact.impactOccurred()
        if let answerText = answerView.text {
            sqc?.insertNewAnswer(answerText)
            answerView.text = ""
        }
    }
    
}
