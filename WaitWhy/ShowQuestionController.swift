//
//  ShowQuestionController.swift
//  WaitWhy
//
//  Created by 4 on 12/5/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import UIKit

import Firebase

class ShowQuestionController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var questionView: UITextView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    var ref: DatabaseReference!
    var key: Int!
    var mvc: MasterViewController!
    var chosenQuestion: Question!
    
    var uid: String!
    
    func configureView() {
        // Update the user interface for the detail item.
        if let question = chosenQuestion {
            questionView.text = question.text
            scoreLabel.text = String(question.getScore())
        }
        sortAnswers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        
        ref = Database.database().reference()
        
        ref.observe(.value, with: { snapshot in
            self.chosenQuestion = Question(snapshot: snapshot, key: self.key)
            self.configureView()
        })
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "AnswerCell") as! AnswerCell
        if let answer = chosenQuestion?.answers[indexPath.row] {
            cell.answer?.text = answer.text
            cell.score?.text = String(answer.getScore())
        } else {
            cell.answer?.text = "Error"
            cell.score?.text = "0"
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let question = chosenQuestion {
                return question.answers.count
        }
        return 0
    }
    
    @IBAction func upVoted(_ sender: Any) {
        // let them know they tapped
        impact.impactOccurred()
        
        // check that they're logged in
        if let user = Auth.auth().currentUser {
            if let question = chosenQuestion {
                // make it's not their answer
                if question.uid != user.uid  {
                    self.ref.child("questions/\(question.key)/voters/\(user.uid)").setValue(1)
                }
            }
        }
    }
    
    @IBAction func downVoted(_ sender: Any) {
        // let them know they tapped
        impact.impactOccurred()
        
        // check that they're logged in
        if let user = Auth.auth().currentUser {
            if let question = chosenQuestion {
                // make it's not their answer
                if question.uid != user.uid  {
                    self.ref.child("questions/\(question.key)/voters/\(user.uid)").setValue(-1)
                }
            }
        }
    }
    
    @objc
    func insertNewAnswer(_ newAnswerText: String) {
        if let question = chosenQuestion {
            let answerKey = question.answers.count
            let newAnswer = Answer(newKey: answerKey, newText: newAnswerText, newUID: uid)
            question.answers.insert(newAnswer, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            sortAnswers()
            self.ref.child("answers/\(question.key)/\(answerKey)").setValue(["text": newAnswerText, "uid": uid])
        }
    }
    
    func sortAnswers() {
        if let question = chosenQuestion {
            let L : Int = question.answers.count
            if (L > 1) {
                for i in 0...(L-2) {
                    for j in (i+1)...(L-1) {
                        if (question.answers[i].getScore() < question.answers[j].getScore()) {
                            let temp = question.answers[i]
                            question.answers[i] = question.answers[j]
                            question.answers[j] = temp
                        }
                    }
                }
            }
            tableView?.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnswer" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let question = chosenQuestion {
                    let answer = question.answers[indexPath.row]
                    let controller = (segue.destination as! UINavigationController).topViewController as! ShowAnswerController
                    controller.questionKey = question.key
                    controller.answerKey = answer.key
                }
            }
        }
        if segue.identifier == "addingAnswer" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddAnswerController
            controller.sqc = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        super.viewWillAppear(animated)
        configureView()
    }
    
    @IBAction func pressedAddAnswer(_ sender: Any) {
        let user = Auth.auth().currentUser
        if (user == nil) {
            let alertTitle = "Not Logged In"
            let alertText = "Only users can add questions and answers to WaitWhy."
            let alertController = UIAlertController(title: alertTitle, message: alertText, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)
            
            let loginAction = UIAlertAction(title: "Log In", style: .default) { (action) in
                self.mvc.presentLogin()
            }
            alertController.addAction(loginAction)
            alertController.preferredAction = loginAction
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "addingAnswer", sender: nil)
        }
    }
    
    
}
