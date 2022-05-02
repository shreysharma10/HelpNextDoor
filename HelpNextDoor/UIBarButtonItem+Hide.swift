//
//  UIBarButtonItem+Hide.swift
//  HelpNextDoor
//
//  Created by Shrey Sharma on 5/2/22.
//

import Foundation


import UIKit

extension UIBarButtonItem {
    func hide() {
        self.isEnabled = false
        self.tintColor = .clear
    }
}
