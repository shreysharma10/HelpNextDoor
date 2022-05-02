//
//  Jobs.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 4/28/22.
//

import Foundation
import Firebase

class Jobs {
    var jobArray: [Job] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("jobs").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("error adding snapshot listener")
                return completed()
            }
            self.jobArray = []
            for document in querySnapshot!.documents {
                let job = Job(dictionary: document.data())
                job.documentID = document.documentID
                self.jobArray.append(job)
            }
            completed()
        }
    }
}
