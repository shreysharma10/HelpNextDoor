//
//  SelectionViewController.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 4/26/22.
//

import UIKit

class SelectionViewController: UIViewController {
    @IBOutlet weak var helperButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func helperButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowList", sender: nil)
    }
    
    @IBAction func userButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowUser", sender: nil)
    }
    
        
}
