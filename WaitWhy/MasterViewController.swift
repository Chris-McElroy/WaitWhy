//
//  MasterViewController.swift
//  WaitWhy
//
//  Created by 4 on 12/5/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import UIKit

import Firebase
import FirebaseUI

class MasterViewController: UITableViewController, FUIAuthDelegate {
    
    var authUI: FUIAuth? = nil
    var currentUID: String? = nil
    
    var AnswerViewController: ShowQuestionController? = nil
    var questions = [Question]()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // navigationItem.leftBarButtonItem = editButtonItem

        // let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        // navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            AnswerViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ShowQuestionController
        }
        
        ref = Database.database().reference()
        
//        ref.observe(.value, with: { snapshot in
//            print(snapshot.value as Any)
//        })
        
        ref.observe(.value, with: { snapshot in
            var newQuestions = [Question]()
            let numQuestions = snapshot.childSnapshot(forPath: "questions").childrenCount
            for i in 0...(numQuestions-1) {
                let newQuestion = Question(snapshot: snapshot, key: Int(i))
                newQuestions.append(newQuestion)
            }
            self.questions = newQuestions
            self.sortQuestions()
        })
        
        authUI = FUIAuth.defaultAuthUI()!
        authUI?.delegate = self
        
        let providers: [FUIAuthProvider] = [ FUIGoogleAuth() ]
        self.authUI?.providers = providers
        
        currentUID = Auth.auth().currentUser?.uid
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        sortQuestions()
    }

    @objc
    func insertNewQuestion(_ newQuestionText: String) {
        currentUID = Auth.auth().currentUser?.uid
        let questionKey = questions.count
        let newQuestion = Question(newKey: questionKey, newText: newQuestionText, newUID: currentUID!)
        questions.insert(newQuestion, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        sortQuestions()
        
        self.ref.child("/questions/\(questionKey)").setValue(["text": newQuestionText, "uid": currentUID!])
    }
    
    func sortQuestions() {
        let L : Int = questions.count
        if (L > 1) {
            for i in 0...(L-2) {
                for j in (i+1)...(L-1) {
                    if (questions[i].getScore() < questions[j].getScore()) {
                        let temp = questions[i]
                        questions[i] = questions[j]
                        questions[j] = temp
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
//    func loadData() {
//        ref.child("questions").child("1").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let username = value?["username"] as? String ?? ""
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuestion" {
            if let indexPath = tableView.indexPathForSelectedRow {
                currentUID = Auth.auth().currentUser?.uid
                let question = questions[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! ShowQuestionController
                controller.key = question.key
                controller.uid = currentUID
                controller.mvc = self
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "addingQuestion" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddQuestionController
            controller.mvc = self
        }
        if segue.identifier == "alreadyLoggedIn" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AccountInfoController
            currentUID = Auth.auth().currentUser?.uid
            controller.userEmail = Auth.auth().currentUser?.email
            controller.mvc = self
            controller.uid = currentUID
            controller.userScore = getUserScore()
            controller.topQuestion = getTopQuestion()
            controller.topAnswer = getTopAnswer()
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell

        let question = questions[indexPath.row]
        cell.question!.text = question.text
        cell.score!.text = String(question.getScore())
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            questions.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    
    @IBAction func accountPressed(_ sender: Any) {
        let user = Auth.auth().currentUser
        if (user == nil) {
            presentLogin()
        } else {
            self.performSegue(withIdentifier: "alreadyLoggedIn", sender: nil)
        }
    }
    
    func signUserOut() {
        do {
            try self.authUI?.signOut()
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
    }
    
    @IBAction func pressedAddQuestion(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "addingQuestion", sender: nil)
        } else {
            let alertTitle = "Not Logged In"
            let alertText = "Only users can add questions and answers to WaitWhy."
            let alertController = UIAlertController(title: alertTitle, message: alertText, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)
            
            let loginAction = UIAlertAction(title: "Log In", style: .default) { (action) in
                self.presentLogin()
            }
            alertController.addAction(loginAction)
            alertController.preferredAction = loginAction
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentLogin() {
        if let authViewController = self.authUI?.authViewController() {
            self.present(authViewController, animated: true)
        }
    }
    
    func getUserScore() -> Int {
        var score = 0
        for question in questions {
            if question.uid == currentUID {
                score += question.getScore()
            }
            for answer in question.answers {
                if answer.uid == currentUID {
                    score += answer.getScore()
                }
            }
        }
        return score
    }
    
    func getTopQuestion() -> Question! {
        var currentTopScore = 0
        var currentTopQuestion: Question! = nil
        for question in questions {
            if question.uid == currentUID {
                if currentTopQuestion == nil {
                    currentTopScore = question.getScore()
                    currentTopQuestion = question
                } else if currentTopScore < question.getScore() {
                    currentTopScore = question.getScore()
                    currentTopQuestion = question
                }
            }
        }
        return currentTopQuestion
    }
    
    func getTopAnswer() -> Answer! {
        var currentTopScore = 0
        var currentTopAnswer: Answer! = nil
        for question in questions {
            for answer in question.answers {
                if answer.uid == currentUID {
                    if currentTopAnswer == nil {
                        currentTopScore = answer.getScore()
                        currentTopAnswer = answer
                    } else if currentTopScore < answer.getScore() {
                        currentTopScore = answer.getScore()
                        currentTopAnswer = answer
                    }
                }
            }
        }
        return currentTopAnswer
    }

}
