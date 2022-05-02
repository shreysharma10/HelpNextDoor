//
//  User.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 5/2/22.
//


//
//  SnackUser.swift
//  Snacktacular
//
//  Created by Shrey Sharma on 4/25/22.
//

import Foundation
import Firebase

class HelpUser {
    var email: String
    var displayName: String
    var userSince: Date
    var documentID: String
    var dictionary: [String: Any] {
        let timeIntervalDate = userSince.timeIntervalSince1970
        return ["email":email, "displayName": displayName, "userSince": timeIntervalDate ]
    }
    
    init(email:String, displayName: String, userSince: Date, documentID: String) {
        self.email = email
        self.displayName = displayName
        self.userSince = userSince
        self.documentID = documentID
    }
    
    convenience init(user: User) {
        let email = user.email ?? ""
        let displayName = user.displayName ?? ""
        self.init(email:email, displayName: displayName, userSince: Date(), documentID: user.uid)
    }
    
    convenience init(dictionary: [String: Any]) {
        let email = dictionary["email"] as! String ?? ""
        let displayName = dictionary["displayName"] as! String ?? ""
        let timeIntervalDate = dictionary["userSince"] as! TimeInterval?  ?? TimeInterval()
        let userSince = Date(timeIntervalSince1970: timeIntervalDate)


        self.init(email:email, displayName: displayName, userSince: userSince, documentID: "")
    
    }
    
    
    func saveIfNewUser(completion : @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(documentID)
        userRef.getDocument { document, error in
            guard error == nil else {
                print("Error cannot access document for user")
                return completion(false)
            }
            guard document?.exists == false else {
                print("already exists")
                return completion(true)
            }
            
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(self.documentID).setData(dataToSave) { error in
                guard error == nil else {
                    print("Error could not save data")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
    
    
    
    
    
}
