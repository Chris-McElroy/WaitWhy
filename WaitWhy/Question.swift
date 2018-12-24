//
//  Question.swift
//  WaitWhy
//
//  Created by 4 on 12/20/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import Foundation

import Firebase

class Question {
    let key: Int
    let text: String
    let uid: String
    var votesFor = [String]()
    var votesAgainst = [String]()
    var answers = [Answer]()
    
    init(newKey: Int, newText: String, newUID: String) {
        self.key = newKey
        self.text = newText
        self.votesFor = []
        self.votesAgainst = []
        self.uid = newUID
    }
    
    init(snapshot: DataSnapshot, key: Int) {
        let questionSnapshot = snapshot.childSnapshot(forPath: "questions/\(key)")
        let answersSnapshot = snapshot.childSnapshot(forPath: "answers/\(key)")
        self.key = key
        self.text = questionSnapshot.childSnapshot(forPath: "text").value as! String
        self.uid = questionSnapshot.childSnapshot(forPath: "uid").value as! String
        
        // get votes on question
        let votersSnapshot = questionSnapshot.childSnapshot(forPath: "voters")
        for voterSnapshot in votersSnapshot.children {
            if let vs = voterSnapshot as? DataSnapshot {
                if vs.value as! Int == 1 {
                    self.votesFor.append(vs.key)
                } else {
                    self.votesAgainst.append(vs.key)
                }
            }
        }
        
        // get answers to question
        let numAnswers = answersSnapshot.childrenCount
        var newAnswers = [Answer]()
        if numAnswers > 0 {
            for i in 0...(numAnswers-1) {
                let newAnswer = Answer(snapshot: answersSnapshot.childSnapshot(forPath: String(i)))
                newAnswers.append(newAnswer)
            }
        }
        self.answers = newAnswers
    }
    
    func getScore() -> Int {
        return votesFor.count - votesAgainst.count
    }
    
}
