//
//  CustomTabBarController.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/2/23.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = initialIndex
        
    }
    
}
