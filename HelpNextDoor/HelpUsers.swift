//
//  HelpUsers.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 5/2/22.
//

//
//  SnackUsers.swift
//  Snacktacular
//
//  Created by Shrey Sharma on 4/25/22.
//

import Foundation
import Firebase


class HelpUsers {
    var userArray: [HelpUser] = []
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("error adding snapshot listener")
                return completed()
            }
            self.userArray = []
            for document in querySnapshot!.documents {
                let helpUser = HelpUser(dictionary: document.data())
                helpUser.documentID = document.documentID
                self.userArray.append(helpUser)
            }
            completed()
        }
    }
}
