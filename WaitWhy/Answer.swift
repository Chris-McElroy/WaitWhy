//
//  Answer.swift
//  WaitWhy
//
//  Created by 4 on 12/20/18.
//  Copyright © 2018 Christopher S. McElroy. All rights reserved.
//

import Foundation

import Firebase

class Answer {
    let key: Int
    let text: String
    let uid: String
    var votesFor = [String]()
    var votesAgainst = [String]()
    
    init(newKey: Int, newText: String, newUID: String) {
        self.key = newKey
        self.text = newText
        self.uid = newUID
    }
    
    init(snapshot: DataSnapshot) {
        self.key = Int(snapshot.key)!
        self.text = snapshot.childSnapshot(forPath: "text").value as! String
        self.uid = snapshot.childSnapshot(forPath: "uid").value as! String
        
        // get votes on answer
        let votersSnapshot = snapshot.childSnapshot(forPath: "voters")
        for voterSnapshot in votersSnapshot.children {
            if let vs = voterSnapshot as? DataSnapshot {
                if vs.value as! Int == 1 {
                    self.votesFor.append(vs.key)
                } else {
                    self.votesAgainst.append(vs.key)
                }
            }
        }
    }
    
    func getScore() -> Int {
        return votesFor.count - votesAgainst.count
    }
}
