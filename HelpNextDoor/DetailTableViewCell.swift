//
//  DetailTableViewCell.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 4/29/22.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var postedOnLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var currentLocation: CLLocation!
    

    var job: Job! {
        didSet {
            self.titleLabel.text = job.jobTitle
            self.postedOnLabel.text = "posted: \(dateFormatter.string(from: job.date))"
            guard let currentLocation = currentLocation else {
                distanceLabel.text = "Distance: -.-"
                return
                
            }
            let distanceInMeters = job.location.distance(from: currentLocation)
            let distanceInMiles = ((distanceInMeters * 0.00062317) * 10).rounded() / 10
            self.distanceLabel.text = "Distance: \(distanceInMiles) miles"
        }
    }
}
