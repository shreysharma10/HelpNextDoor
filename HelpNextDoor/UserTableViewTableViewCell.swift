//
//  UserTableViewTableViewCell.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 5/2/22.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class UserTableViewTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var job: Job! {
        didSet {
            self.nameLabel.text = job.jobTitle
            self.dateLabel.text = "Posted: \(dateFormatter.string(from: job.date))"
            
        }
    }
    

}
