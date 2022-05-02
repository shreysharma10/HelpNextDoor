//
//  User.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 4/26/22.
//

import Foundation
import Firebase
import MapKit
import CoreLocation

class Job: NSObject, MKAnnotation {
    var jobTitle: String
    var name: String
    var email: String
    var jobDescription: String
    var coordinate: CLLocationCoordinate2D
    var appImage: UIImage
    var appImageUUID: String
    var priceOffered: String
    var phoneNumber: String
    var postingUserID: String
    var documentID: String
    var date: Date
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        return name
    }
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["jobTitle": jobTitle, "email": email, "jobDescription": jobDescription, "longitude": longitude, "latitude": latitude, "priceOffered": priceOffered, "phoneNumber": phoneNumber, "postingUserID": postingUserID, "documentID": documentID, "name": name, "appImageUUID": appImageUUID, "date": timeIntervalDate]
    }

    init(jobTitle: String, email: String, jobDescription: String, coordinate: CLLocationCoordinate2D, phoneNumber: String, postingUserID: String, priceOffered: String, documentID: String, name: String, appImage:UIImage, appImageUUID:String, date: Date) {
        self.jobTitle = jobTitle
        self.email = email
        self.jobDescription = jobDescription
        self.coordinate = coordinate
        self.priceOffered = priceOffered
        self.phoneNumber = phoneNumber
        self.postingUserID = postingUserID
        self.documentID = documentID
        self.name = name
        self.appImage = appImage
        self.appImageUUID = appImageUUID
        self.date = date
    }
    
    convenience init(dictionary: [String: Any]) {
        let jobTitle = dictionary["jobTitle"] as! String? ?? ""
        let email = dictionary["email"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let priceOffered = dictionary["priceOffered"] as! String? ?? ""
        let phoneNumber = dictionary["phoneNumber"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        let documentID = dictionary["documentID"] as! String? ?? ""
        let jobDescription = dictionary["jobDescription"] as! String? ?? ""
        let name = dictionary["name"] as! String? ?? ""
        let appImageUUID = dictionary["appImageUUID"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(jobTitle: jobTitle , email: email, jobDescription: jobDescription, coordinate: coordinate, phoneNumber: phoneNumber, postingUserID: postingUserID, priceOffered: priceOffered, documentID: "", name: name, appImage: UIImage(), appImageUUID: appImageUUID, date: date)
    }
    
     override convenience init() {
         self.init(jobTitle: "", email: "", jobDescription: "", coordinate: CLLocationCoordinate2D(), phoneNumber: "", postingUserID: "", priceOffered: "", documentID: "", name: "", appImage: UIImage(), appImageUUID: "", date: Date())
    }
    
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("jobs").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("jobs").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Spot’s documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
    func saveImage(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        // convert app image to data type
        guard let imageToSave = self.appImage.jpegData(compressionQuality: 0.5) else {
            print("produced an nil cannot convert image")
            return completed(false)
        }
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        if appImageUUID == "" {
            // create uuid
            appImageUUID = UUID().uuidString
        }
        // create ref to upload storage with the uuid created
        let storageRef = storage.reference().child(documentID).child(self.appImageUUID)
        let uploadTask = storageRef.putData(imageToSave, metadata: uploadMetaData) { metadata, error in
            guard error == nil else {
                print("ERROR: DURING .PUTDATA STORAGE UPLOAD FOR REF")
                return completed(false)
            }
            print("upload worked")
        }
        uploadTask.observe(.success) { snapshot in
            //create the dictionary representing the data we want to save
            let dataToSave = self.dictionary
            let ref = db.collection("jobs").document(self.documentID)
            ref.setData(dataToSave) { error in
                if let error = error {
                    print("ERROR: SAVING DOCUMENT")
                    completed(false)
                } else {
                    print("document updated")
                    completed(true)
                }
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("ERROR UPLOADING TASK")
            }
            return completed(false)
        }
    }
    
    func loadImage(completed: @escaping () -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(self.documentID).child(self.appImageUUID)
        // 5B
        storageRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            guard error == nil else {
                print("ERROR: COULD NOT LOAD IMAGE FROM BUCKET")
                return completed()
            }
            guard let downloadedImage = UIImage(data: data!) else {
                print("ERROR: COULD NOT convert data to  IMAGE FROM BUCKET")
                return completed()
            }
            self.appImage = downloadedImage
            completed()
        }
        
    }
    
    func loadData(completed: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("jobs").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("error adding snapshot listener")
                return completed()
            }
            for document in querySnapshot!.documents {
                let job = Job(dictionary: document.data())
                job.documentID = document.documentID
            }
            completed()
        }
    }
}
    




