//
//  SignUpViewController.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/28/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RealmSwift

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
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
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    //Check the fields and validate that the data is correct. If everything is correct, this method returns nil. Otherwise, it returns the error message as a string.
    func validateFields() -> String? {
        
        //Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        //Check if email is valid
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !Utilities.isValidEmailAddr(strToValidate: cleanedEmail) {
            return "Please make sure your email address is valid."
        }
        
        //Check if password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if !Utilities.isPasswordValid(cleanedPassword) {
            //Password isn't secure
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        //Validate the fields
        let error = validateFields()
        
        if error != nil {
            //There was an error, show error message
            showError(error!)
        } else {
            //Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            //Create the user
            Auth.auth().createUser(withEmail: email, password: password) { result, err in
                //Check for errors
                if err != nil {
                    //There was an error creating the user
                    self.showError("Error creating user")
                } else {
                    //User was created successfully, now store the first name and last name
                    let db = Firestore.firestore()
                    
                    
                    let currentUser = Auth.auth().currentUser
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM d, YYYY"
                    let formattedDate = dateFormatter.string(from: Date())
                    
                    db.collection("users").document(currentUser!.uid).setData(["firstname": firstName, "lastname": lastName, "creationdate": formattedDate, "elapsedTimeBeforeNextPictureSession": "7", "dev": "false"]) { error in
                        if error != nil {
                            self.showError("Error saving user data")
                        }
                    }

                    //Transition to the home screen
                    self.transitionToHome()
                }
                
            }
            
            
        }
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name
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
