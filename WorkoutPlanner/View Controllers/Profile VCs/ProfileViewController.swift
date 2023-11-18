//
//  ProfileViewController.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/29/23.
//

import UIKit
import AVFoundation
import FirebaseFirestore
import Firebase
import FirebaseStorage
import TOCropViewController

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var formattedDateText: String?
    var dateJoined: String?
    
    let profileInformationMenu = UIView()
    let enterNameField = UITextField()
    
    var settingsMenu = UIView()
    
    var dimmerTapGestureRecognizer: UITapGestureRecognizer?
    
    var daysInBetweenShootsTooLong = false
    
    var topAnchor: NSLayoutConstraint?
    
    @IBOutlet weak var photoLibraryOrCameraChoiceMenuTopAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var photoLibraryOrCameraChoiceMenu: UIView!
    
    @IBOutlet weak var userFullNameButton: UIButton!
    
    @IBOutlet var backgroundView: UIView!
    
    @IBAction func didTapProfileName(_ sender: Any) {
        controlMidWindowMenu(viewToControl: profileInformationMenu)
    }
    
    @IBAction func didTapProfileNameArrow(_ sender: Any) {
        controlMidWindowMenu(viewToControl: profileInformationMenu)
    }
    
    @IBOutlet var dimmerView: UIView!
    
    @IBOutlet weak var headerStackView: UIStackView!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    @IBAction func didTapPremiumSubscription(_ sender: Any) {
    }
    
    @IBAction func didTapSettings(_ sender: Any) {
        controlMidWindowMenu(viewToControl: settingsMenu)
    }
    
    var daysInBetweenShootsText: String?
    var daysInBetweenShootsTextField: UITextField = UITextField()
    
    var profilePicture = UIImage(named: "defaultProfilePicture")
    
    var newFirstName: String?
    var newLastName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            self.retrieveProflilePicture()
            self.fetchUserFirstAndLastName()
        }
        
        DispatchQueue.main.async{
            self.setUpElements()
        }
        enterNameField.delegate = self
        daysInBetweenShootsTextField.delegate = self
    }
    
    func configureProfileInformationMenu() {
        //Initializing Done Button and Cancel Button to pass into config func
        let doneButton = UIButton()
        doneButton.addTarget(self, action: #selector(handleDoneButtonLogicForProfileInformationMenu), for: .touchUpInside)
        let cancelButton = UIButton()
        cancelButton.addTarget(self, action: #selector(handleCancelButtonLogicForProfileInformationMenu), for: .touchUpInside)
        configMidWindowMenu(viewToAddWindowTo: backgroundView, newWindow: profileInformationMenu)
        configDoneButtonAndCancelButtonForMidWindowMenu(doneButtonToConfig: doneButton, cancelButtonToConfig: cancelButton, screen: profileInformationMenu)
        
        //Editing properties of enterNameTextField
        enterNameField.placeholder = "Enter name (optional)"
        enterNameField.layer.borderColor = UIColor(red: 234/255, green: 236/255, blue: 237/255, alpha: 1).cgColor
        enterNameField.layer.borderWidth = 2
        enterNameField.borderStyle = .roundedRect
        enterNameField.layer.cornerRadius = 5
        profileInformationMenu.addSubview(enterNameField)
        enterNameField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            enterNameField.topAnchor.constraint(equalTo: profileInformationMenu.topAnchor, constant: 45),
            enterNameField.leadingAnchor.constraint(equalTo: profileInformationMenu.leadingAnchor, constant: 16),
            enterNameField.trailingAnchor.constraint(equalTo: profileInformationMenu.trailingAnchor, constant: -16),
            enterNameField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        //Creating label that shows when user made account
        let labelShowingDateJoined = UILabel()
        retrieveDateJoinedFromFirebase { success in
            if success {
                self.formattedDateText = "Date joined: \(self.dateJoined!)"
            } else {
                self.formattedDateText = "No Date Found"
            }
            
            DispatchQueue.main.async {
                labelShowingDateJoined.text = self.formattedDateText
            }
            
        }
        //Editing labelShowingDateJoined properties
        labelShowingDateJoined.textColor = UIColor.black
        profileInformationMenu.addSubview(labelShowingDateJoined)
        labelShowingDateJoined.translatesAutoresizingMaskIntoConstraints = false
        labelShowingDateJoined.textAlignment = .center
        NSLayoutConstraint.activate([
            labelShowingDateJoined.bottomAnchor.constraint(equalTo: profileInformationMenu.bottomAnchor, constant: -16),
            labelShowingDateJoined.leadingAnchor.constraint(equalTo: profileInformationMenu.leadingAnchor, constant: 16),
            labelShowingDateJoined.trailingAnchor.constraint(equalTo: profileInformationMenu.trailingAnchor, constant: -16),
        ])
    }
    
    func configMidWindowMenu(viewToAddWindowTo: UIView, newWindow: UIView) {
        viewToAddWindowTo.addSubview(newWindow)
        newWindow.isHidden = true
        newWindow.layer.cornerRadius = 20
        newWindow.translatesAutoresizingMaskIntoConstraints = false
        newWindow.backgroundColor = UIColor(red: 234/255, green: 236/255, blue: 237/255, alpha: 1)
        NSLayoutConstraint.activate([
            newWindow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newWindow.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -((50/426)*view.frame.height/2)),
            newWindow.widthAnchor.constraint(equalToConstant: ((300/393)*view.frame.width)),
            newWindow.heightAnchor.constraint(equalToConstant: ((340/852)*view.frame.height))
        ])
    }
    
    func configDoneButtonAndCancelButtonForMidWindowMenu(doneButtonToConfig: UIButton, cancelButtonToConfig: UIButton, screen: UIView) {
        doneButtonToConfig.setTitle("Done", for: .normal)
        doneButtonToConfig.setTitleColor(.blue, for: .normal)
        screen.addSubview(doneButtonToConfig)
        doneButtonToConfig.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButtonToConfig.topAnchor.constraint(equalTo: screen.topAnchor, constant: 8),
            doneButtonToConfig.trailingAnchor.constraint(equalTo: screen.trailingAnchor, constant: -8),
            doneButtonToConfig.widthAnchor.constraint(equalToConstant: 50),
            doneButtonToConfig.heightAnchor.constraint(equalToConstant: 35)
        ])
        cancelButtonToConfig.setTitle("Cancel", for: .normal)
        cancelButtonToConfig.setTitleColor(.blue, for: .normal)
        screen.addSubview(cancelButtonToConfig)
        cancelButtonToConfig.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButtonToConfig.topAnchor.constraint(equalTo: screen.topAnchor, constant: 8),
            cancelButtonToConfig.leadingAnchor.constraint(equalTo: screen.leadingAnchor, constant: 8),
            cancelButtonToConfig.widthAnchor.constraint(equalToConstant: 75),
            cancelButtonToConfig.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    func configureSettingsMenu() {
        //Configuring Settings Menu Screen
        configMidWindowMenu(viewToAddWindowTo: backgroundView, newWindow: settingsMenu)
        let doneButton = UIButton()
        doneButton.addTarget(self, action: #selector(handleDoneButtonLogicForSettingsMenu), for: .touchUpInside)
        let cancelButton = UIButton()
        cancelButton.addTarget(self, action: #selector(handleCancelButtonLogicForSettingsMenu), for: .touchUpInside)
        configDoneButtonAndCancelButtonForMidWindowMenu(doneButtonToConfig: doneButton, cancelButtonToConfig: cancelButton, screen: settingsMenu)
        hideKeyboardWhenTappedAround()
        
        let daysBetweenLabel = UILabel()
        daysBetweenLabel.translatesAutoresizingMaskIntoConstraints = false
        daysBetweenLabel.text = "Days between shoots: "
        daysBetweenLabel.font = UIFont.systemFont(ofSize: 18.0)
        settingsMenu.addSubview(daysBetweenLabel)
        NSLayoutConstraint.activate([
            daysBetweenLabel.leadingAnchor.constraint(equalTo: settingsMenu.leadingAnchor, constant: 20),
            daysBetweenLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 20)
        ])
        
        daysInBetweenShootsTextField.placeholder = "i.e '3'"
        daysInBetweenShootsTextField.layer.borderColor = UIColor(red: 234/255, green: 236/255, blue: 237/255, alpha: 1).cgColor
        daysInBetweenShootsTextField.layer.borderWidth = 2
        daysInBetweenShootsTextField.borderStyle = .roundedRect
        daysInBetweenShootsTextField.layer.cornerRadius = 5
        settingsMenu.addSubview(daysInBetweenShootsTextField)
        daysInBetweenShootsTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysInBetweenShootsTextField.centerYAnchor.constraint(equalTo: daysBetweenLabel.centerYAnchor),
            daysInBetweenShootsTextField.leadingAnchor.constraint(equalTo: daysBetweenLabel.trailingAnchor, constant: 15),
            daysInBetweenShootsTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc func handleCancelButtonLogicForSettingsMenu() {
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmerView.alpha = 0
            self.settingsMenu.isHidden = true
            
            if #available(iOS 13.0, *) {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.backgroundColor = UIColor(red: 234/255, green: 236/255, blue: 237/255, alpha: 1)
                self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
            }
            
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func handleDoneButtonLogicForSettingsMenu() {
        //Trigger didEndEditing delegate function for text field
        daysInBetweenShootsTextField.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmerView.alpha = 0
            self.settingsMenu.isHidden = true
            self.view.layoutIfNeeded()
        })
        
        //Send time increment to server
        sendTimeBetweenShoots { success in
            if success {
                //Clear text field
                self.daysInBetweenShootsTextField.text = ""
            }
        }
    }
    
    func sendTimeBetweenShoots(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        guard daysInBetweenShootsText != nil else {
            completion(false)
            return
        }
        
        let _: Void = db.collection("users").document(currentUser!).updateData(["elapsedTimeBeforeNextPictureSession": daysInBetweenShootsText!]) { error in
            if error != nil {
                print("Could not update name fields")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func setUpElements() {
        profilePictureImageView.image = profilePicture
        profilePictureImageView.contentMode = .scaleAspectFill
        profilePictureImageView.roundCornerView(corners: [.allCorners], radius: profilePictureImageView.frame.width/2)
        configureProfileInformationMenu()
        profileInformationMenu.isHidden = true
        openPhotoFromLibraryOrCameraChoiceMenuOnTap()
        configureSettingsMenu()
        
        NSLayoutConstraint.activate([
            photoLibraryOrCameraChoiceMenu.heightAnchor.constraint(equalToConstant: ((128/852)*view.frame.height)),
        ])
    }
    
    func openPhotoFromLibraryOrCameraChoiceMenuOnTap() {
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentPhotoFromLibaryOrCameraChoiceMenu)))
    }
    
    func openCamera() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                present(imagePicker, animated: true, completion: nil)
            } else {
                // Device doesn't have a camera
                print("Camera not available.")
            }
        }
    
    @objc func presentPhotoFromLibaryOrCameraChoiceMenu() {
        //Creating menu
        let actionSheet = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)
        
        //Option 1: Photo Library
        let chooseFromPhotoLibrary = UIAlertAction(title: "Choose from photo library", style: .default) { (action) in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        //Option 2: Open camera to capture photo
        let takePhoto = UIAlertAction(title: "Take photo", style: .default) { (action) in
            self.openCamera()
        }
        
        //Add options to sheet and present on screen
        actionSheet.addAction(chooseFromPhotoLibrary)
        actionSheet.addAction(takePhoto)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func uploadImageToFirestoreDatabase(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        
        guard profilePicture != nil else {
            completion(false)
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageData = profilePicture!.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            completion(false)
            return
        }
        
        let path = "usersProfilePictures/\(currentUser!)ProfilePicture.jpg"
        let fileRef = storageRef.child(path)
        _ = fileRef.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                let db = Firestore.firestore()
                db.collection("users").document(currentUser!).updateData(["url": path]) { error in
                    if error != nil {
                        print("Could not find docmuent")
                    } else {
                        completion(true)
                    }
                }
                
            } else {
                completion(false)
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            dismiss(animated: true, completion: nil)

            if let image = info[.originalImage] as? UIImage {
                // Set the image to your UIImageView
                let fixedImage = image.fixOrientation()
                self.profilePicture = fixedImage.circularCrop(radius: 64)
                
                uploadImageToFirestoreDatabase { success in
                    if success {
                        self.retrieveProflilePicture()
                    } else {
                        print("Upload failed")
                    }
                }
            }
        }

        // Delegate method when the user cancels taking a picture
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    
    func retrieveProflilePicture() {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        db.collection("users").document(currentUser!).getDocument { snapshot, error in
            
            if error == nil && snapshot != nil {
                guard let path = snapshot!["url"] as? String else {return}
                
                let storageRef = Storage.storage().reference()
                let fileRef = storageRef.child(path)
                fileRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if error == nil && data != nil {
                        self.profilePictureImageView.image = UIImage(data: data!)
                    } else {
                        print("Error accessing data")
                    }
                }
            }
        }
    }
    
    func fetchUserFirstAndLastName() {
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(currentUser.uid)
            userRef.getDocument { document, error in
                if error == nil {
                    if let d = document, d.exists {
                        let firstname = d["firstname"] as? String ?? ""
                        let lastname = d["lastname"] as? String ?? ""
                        let fullName = "\(firstname) \(lastname)"
                        
                            // Update UI elements with user data
                        self.userFullNameButton.setTitle(fullName, for: .normal)
                        self.userFullNameButton.setTitleColor(.black, for: .normal)
                    } else {
                        print("No document found")
                    }
                } else {
                    return
                }
            }
        }
    }
    
    @objc func handleDoneButtonLogicForProfileInformationMenu() {
        enterNameField.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmerView.alpha = 0
            self.profileInformationMenu.isHidden = true
            self.view.layoutIfNeeded()
        })
        uploadNameToFirestoreDatabase { success in
            if success {
                self.fetchUserFirstAndLastName()
            }
        }
    }
    
    func uploadNameToFirestoreDatabase(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        guard newFirstName != nil && newLastName != nil else {
            completion(false)
            return
        }
        
        let _: Void = db.collection("users").document(currentUser!).updateData(["firstname": newFirstName!, "lastname": newLastName!]) { error in
            if error != nil {
                completion(false)
                print("Could not update name fields")
            } else {
                completion(true)
            }
        }
    }

    func retrieveDateJoinedFromFirebase(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser!).getDocument { snapshot, error in
            if error == nil && snapshot != nil {
                if let creationDate = snapshot?["creationdate"] as? String {
                    self.dateJoined = creationDate
                    completion(true)
                } else {
                    print("failed")
                    completion(false)
                }
            } else {
                completion(false)
                print("Could not find document")
            }
        }
    }
    
    @objc func handleCancelButtonLogicForProfileInformationMenu() {
        enterNameField.resignFirstResponder()
        enterNameField.text = ""
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmerView.alpha = 0
            self.profileInformationMenu.isHidden = true
            
            if #available(iOS 13.0, *) {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.backgroundColor = UIColor(red: 234/255, green: 236/255, blue: 237/255, alpha: 1)
                self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
            }
            
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == enterNameField {
            if let enteredText = textField.text {
                let separatedWords = enteredText.split(separator: " ")
                if separatedWords.count >= 2 {
                    newFirstName = String(separatedWords[0])
                    newLastName = String(separatedWords[1])
                } else if separatedWords.count == 1 {
                    newFirstName = String(separatedWords[0])
                    newLastName = ""
                } else {
                    newFirstName = nil
                    newLastName = nil
                }
            }
        } else if textField == daysInBetweenShootsTextField {
            if var enteredText = textField.text {
                enteredText = enteredText.removeLetters()
                enteredText = enteredText.replacingOccurrences(of: " ", with: "")
                
                //Check if number seems excessively long
                if let intText = Int(enteredText) {
                    if intText > 30 {
                        //TODO: Change some boolean and maybe provide an alert when done button is clicked
                        daysInBetweenShootsTooLong = true
                    }
                }
                daysInBetweenShootsText = enteredText
            }
        }
    }
    
    func controlMidWindowMenu(viewToControl: UIView) {
        UIView.animate(withDuration: 0.25, animations: {
            self.dimmerView.alpha = 0.6
            viewToControl.isHidden = false
            
            //Change tab bar color to dimmer view color
            if #available(iOS 13.0, *) {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
                self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
            }
            
            self.view.layoutIfNeeded()
        })
    }
}

extension String {
    func removeLetters() -> String {
        // Create a regular expression pattern to match letters
        let pattern = "[a-zA-Z]+"
        
        do {
            // Create a regular expression with the pattern
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            // Replace all matches of the pattern with an empty string
            let range = NSRange(location: 0, length: self.utf16.count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
        } catch {
            // Handle any errors when creating the regular expression
            print("Error creating regular expression: \(error)")
            return self
        }
    }
}
