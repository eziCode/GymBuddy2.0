//
//  EntryViewController.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/28/23.
//

import UIKit
import RealmSwift

class EntryViewController: UIViewController {
    
    
    func isCurrentTimePastSessionEndTime() -> Bool {
        //Creating Realm instance
        let config = Realm.Configuration(schemaVersion: 2)
        let realm = try! Realm(configuration: config)
        
        //Accessing end time
        let sessionEndTime = realm.objects(Session.self)[0].endTime
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Set the format to "hr:min"
        
        // Get the current time
        let currentTime = Date()
        
        // Parse the target time string into a Date
        if let targetDate = dateFormatter.date(from: sessionEndTime) {
            // Compare the current time with the target time
            return currentTime > targetDate
        } else {
            // Handle invalid target time format
            print("Invalid target time format")
            return false
        }
    }
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }

    
    func setUpElements() {
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let currentTime = dateFormatter.string(from: Date())
        
        return currentTime
    }
    
}
