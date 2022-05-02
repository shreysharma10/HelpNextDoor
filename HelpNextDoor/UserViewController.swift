//
//  UserViewController.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 4/30/22.
//

import UIKit
private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()
class UserViewController: UIViewController {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var newjob: Job!
    var jobs: Jobs!
    var newArray: [Job] = []
    var helpUser: HelpUser!
    var helpUsers: HelpUsers!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        jobs = Jobs()
        newjob = Job()
        helpUsers = HelpUsers()
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        helpUsers.loadData {
            for helpUser in self.helpUsers.userArray {
                self.jobs.loadData {
                    for njob in self.jobs.jobArray {
                        if njob.email == helpUser.email {
                            self.newArray.append(njob)
                            self.phoneLabel.text = njob.phoneNumber
                            self.emailLabel.text = njob.email
                            self.nameLabel.text = njob.name
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
        

    }
}




extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewTableViewCell
        cell.job = newArray[indexPath.row]
        return cell
    }
    
    
}
