//
//  JobTableViewController.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 4/27/22.
//

import UIKit
import MapKit
import CoreLocation
import GooglePlaces
import Contacts

class JobTableViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    
    
    var imagePickerController = UIImagePickerController()
    var job: Job!
    let regionDistance: CLLocationDistance = 50_000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if job == nil {
            job = Job()
        }
        
        job.loadImage {
            self.photoImageView.image = self.job.appImage
        }
        
        imagePickerController.delegate = self
        
        let region = MKCoordinateRegion(center: job.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
        updateUserInterface()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(job)
        mapView.setCenter(job.coordinate, animated: true)
    }
    
    func updateUserInterface() {
        titleTextField.text = job.jobTitle
        descriptionTextField.text = job.jobDescription
        emailTextField.text = job.email
        phoneTextField.text = job.phoneNumber
        priceTextField.text = job.priceOffered
        nameTextField.text = job.name
        updateMap()
    }
    
    
    func updateFromUserInterface() {
        job.jobTitle = titleTextField.text ?? ""
        job.jobDescription = descriptionTextField.text ?? ""
        job.email = emailTextField.text ?? ""
        job.phoneNumber = phoneTextField.text ?? ""
        job.priceOffered = priceTextField.text ?? ""
        job.name = nameTextField.text ?? ""
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            self.job.saveData { success in
                self.saveBarButton.title = "Done"
                self.navigationController?.setToolbarHidden(true, animated: true)
                if segueIdentifier == "AddReview" {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                } else {
                    self.cameraOrLibraryAlert()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        job.saveData { success in
            if success {
                self.job.saveImage { success in
                    if !success {
                        print("warning could not save image")
                    }
                    self.leaveViewController()
                }
            } else {
                print("Error: Couldn't leave this view controller because data wasn't saved")
            }
        }
        
    }
    
    
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
    
    if job.documentID == "" {
        cameraOrLibraryAlert()
    } else {
        cameraOrLibraryAlert()
        saveCancelAlert(title: "This Venue has not been saved", message: "You must save this venue before you can review it ", segueIdentifier:"AddPhoto")
    }
}



@IBAction func findLocationButtonPressed(_ sender: UIBarButtonItem) {
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    // Display the autocomplete view controller.
    present(autocompleteController, animated: true, completion: nil)
}


    




}

extension JobTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        updateFromUserInterface()
        job.coordinate = place.coordinate
        updateUserInterface()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}



extension JobTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        
        
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            job.appImage = editedImage
            
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            job.appImage = originalImage
            
        }
//        photo?.image = imagecollection.imageView?.image ?? UIImage()
        dismiss(animated: true) {
            self.photoImageView.image = self.job.appImage
        }
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func accessPhotoLibrary() {
        
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    
    func accessCamera(){
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imagePickerController.sourceType = .camera
            
            present(imagePickerController, animated: true, completion: nil)
            
        } else {
            
            self.showAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
            
        }
        
    }
    
    func cameraOrLibraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessPhotoLibrary()
            
            
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alertController.addAction(photoLibraryAction)
        
        alertController.addAction(cameraAction)
        
        alertController.addAction(cancelAction)
        
        
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}
