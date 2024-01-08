//
//  LoginViewController.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/28/23.
//

import UIKit
import FirebaseAuth
import RealmSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        //Hide error label
        errorLabel.alpha = 0
        
        //Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }
    
    func validateFields() -> String? {
        
        //Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        return nil
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        //Validate the text fields
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            //Create cleaned versions of the text fields
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { result, err in
                if err != nil {
                    //Couldn't sign in
                    self.errorLabel.text = err!.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    self.transitionToHome()
                }
            }
            
        }
        
        
    }
    
    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: Constants.Storyboard.mainTabBar) as? UITabBarController {
            navigationController?.pushViewController(tabBarController, animated: true)
            navigationController?.navigationBar.isHidden = true
        }
        beginSession()
    }
    
    func beginSession() {
        let config = Realm.Configuration(schemaVersion: 2)
        let realm = try! Realm(configuration: config)
        
        let objectsToDelete = realm.objects(Session.self)
        
        
        //Finding current time and end time
        let startTimeString = getCurrentDateTime()
        let endTimeString = timeOneHourLater(from: startTimeString)
        
        //Creating Session object
        let session = Session()
        session.sessionLength = "60"
        session.startTime = startTimeString
        session.endTime = endTimeString ?? "00:00"
        
        try! realm.write {
            realm.delete(objectsToDelete)
            realm.add(session)
        }
    }
    
    func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm" // Updated date format
        
        let currentDateTime = dateFormatter.string(from: Date())
        
        return currentDateTime
    }

    func timeOneHourLater(from timeString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm" // Updated date format
        
        // Parse the provided timeString into a Date
        if let parsedTime = dateFormatter.date(from: timeString) {
            // Calculate the time one hour later
            let oneHourLater = Calendar.current.date(byAdding: .hour, value: 1, to: parsedTime)
            
            // Check if oneHourLater is not nil and format it as MM-dd-yyyy HH:mm
            if let oneHourLater = oneHourLater {
                return dateFormatter.string(from: oneHourLater)
            }
        }
        
        return nil // Return nil if the timeString couldn't be parsed
    }
    
}
