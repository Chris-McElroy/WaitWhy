//
//  AccountInfoController.swift
//  WaitWhy
//
//  Created by 4 on 12/22/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import Foundation

import UIKit

import Firebase

class AccountInfoController: UIViewController {
    
    var userEmail: String?
    var userScore: Int?
    var mvc: MasterViewController?
    var uid: String!
    var topQuestion: Question?
    var topAnswer: Answer?
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var question: UITextView!
    @IBOutlet weak var answer: UITextView!
    
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    func configureView() {
        // Update the user interface for the detail item.
        email.text = userEmail
        score.text = String(userScore!)
        
        if topQuestion == nil {
            question.text = "No questions submitted!"
        } else {
            question.text = topQuestion!.text
        }
       
        if topAnswer == nil {
            answer.text = "No answers submitted!"
        } else {
            answer.text = topAnswer!.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    @IBAction func pressedSignOut(_ sender: Any) {
        mvc?.signUserOut()
        self.performSegue(withIdentifier: "justLoggedOut", sender: nil)
    }
    
}
