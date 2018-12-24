//
//  ShowAnswerController.swift
//  WaitWhy
//
//  Created by 4 on 12/21/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import Foundation

import UIKit

import Firebase

class ShowAnswerController: UIViewController {
    
    var questionKey: Int!
    var answerKey: Int!
    var ref: DatabaseReference!
    var uid: String!
    
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    @IBOutlet weak var questionText: UITextView!
    
    @IBOutlet weak var answerText: UITextView!
    
    @IBOutlet weak var questionScore: UILabel!
    
    @IBOutlet weak var answerScore: UILabel!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let question = chosenQuestion {
            if let qtext = questionText {
                qtext.text = question.text
            }
            if let qscore = questionScore {
                qscore.text = String(question.getScore())
            }
        }
        if let answer = chosenAnswer {
            if let atext = answerText {
                atext.text = answer.text
            }
            if let ascore = answerScore {
                ascore.text = String(answer.getScore())
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        
        ref.observe(.value, with: { snapshot in
            self.chosenQuestion = Question(snapshot: snapshot, key: self.questionKey)
            self.chosenAnswer = self.chosenQuestion?.answers[self.answerKey]
            self.configureView()
        })
    }
    
    var chosenQuestion: Question? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    var chosenAnswer: Answer? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    @IBAction func upVoted(_ sender: Any) {
        // let them know they tapped
        impact.impactOccurred()
        
        // check that they're logged in
        if let user = Auth.auth().currentUser {
            if let answer = chosenAnswer {
                // make it's not their answer
                if answer.uid != user.uid  {
                    self.ref.child("answers/\(questionKey!)/\(answerKey!)/voters/\(user.uid)").setValue(1)
                }
            }
        }
    }
    
    @IBAction func downVoted(_ sender: Any) {
        // let them know they tapped
        impact.impactOccurred()
        
        // check that they're logged in
        if let user = Auth.auth().currentUser {
            if let answer = chosenAnswer {
                // make it's not their answer
                if answer.uid != user.uid  {
                    self.ref.child("answers/\(questionKey!)/\(answerKey!)/voters/\(user.uid)").setValue(-1)
                }
            }
        }
    }
    
}
