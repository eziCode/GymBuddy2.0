//
//  PhotosVC.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/2/23.
//

import UIKit
import AVFoundation
import FirebaseFirestore
import Firebase
import FirebaseStorage
import Vision

protocol PhotosVcDelegate {
    func didFinishPhotoShoot(inProgress: Bool)
}

class PhotosVC: UIViewController {
    
    var delegate: PhotosVcDelegate?
    
    var images = [UIImage]()
    
    var validImagesDict: [Int: Bool] = [0: true, 1: true, 2: true]
    
    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var takePhotoImageView: UIImageView!
    
    var mostRecentDateOfWorkoutPictures: String?
    var desiredElapsedTime: String?
    
    var isDev: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkDeveloperMode { [self] success in
            if success {
                if isDev! {
                    //Allow camera access
                    presentUserOptionToTakePicture()
                } else {
                    checkIfItIsPictureTime()
                }
            } else {
                checkIfItIsPictureTime()
            }
        }
    }
    
    func checkDeveloperMode(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser!).getDocument { snapshot, error in
            if error == nil && snapshot != nil {
                if let devBool = snapshot?["dev"] as? String {
                    self.isDev = Bool(devBool)
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
    
    func checkIfItIsPictureTime() {
        pullPictureDateFromFirebase { success in
            //Finding most recent date of pictures
            if success && self.mostRecentDateOfWorkoutPictures != nil {
                //Finding user-set time in between photo shoots
                self.pullDesiredElapsedTime { worked in
                    //Checking for success
                    if worked && self.desiredElapsedTime != nil {
                        if self.hasElapsedTimePassed(since: self.mostRecentDateOfWorkoutPictures!, time: Int(self.desiredElapsedTime!)!) {
                            //Present user with option to take picture
                            self.presentUserOptionToTakePicture()
                        } else {
                            //Do not let user take picture
                            self.blockUserFromTakingPhoto()
                        }
                    }
                }
            } else if success && self.mostRecentDateOfWorkoutPictures == nil {
                //Present user with option to take picture
                self.presentUserOptionToTakePicture()
            } else {
                //Do not let user take picture
                self.blockUserFromTakingPhoto()
            }
        }
    }
    
    func pullDesiredElapsedTime(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser!).getDocument { snapshot, error in
            if error == nil && snapshot != nil {
                if let minElapsedTime = snapshot?["elapsedTimeBeforeNextPictureSession"] as? String {
                    self.desiredElapsedTime = minElapsedTime
                    completion(true)
                } else {
                    print("failed")
                    completion(false)
                }
            } else {
                print("Could not find document")
                completion(false)
            }
        }
    }
    
    func blockUserFromTakingPhoto() {
        takePhotoImageView.isUserInteractionEnabled = false
        takePhotoImageView.image = UIImage(named: "notPictureTimeImage")
        takePhotoImageView.layer.borderColor = CGColor(red: 255/255, green: 0, blue: 0, alpha: 1)
        takePhotoImageView.layer.borderWidth = 2
        takePhotoImageView.layer.cornerRadius = 5
    }
    
    func presentUserOptionToTakePicture() {
        takePhotoImageView.isUserInteractionEnabled = true
        takePhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTakePhotoImageView)))
        takePhotoImageView.layer.borderColor = CGColor(red: 0, green: 255/255, blue: 0, alpha: 1)
        takePhotoImageView.layer.borderWidth = 2
        takePhotoImageView.layer.cornerRadius = 5
    }
    
    //Capture session
    var session: AVCaptureSession?
    //Photo output
    let output = AVCapturePhotoOutput()
    //Video preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    private var countdownLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 120, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                DispatchQueue.main.async {
                    self.tabBarController?.tabBar.isHidden = true
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        session.startRunning()
                    }
                    
                    self.session = session
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc func didTapTakePhotoImageView() {
        self.configureCamera()
        self.setUpPhoto()
    }
    
    func configureCamera() {
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(countdownLabel)
        checkCameraPermissions()
    }
    
    
    func setUpPhoto() {
        //takePhotoImageView.removeFromSuperview()
        previewLayer.frame = view.bounds
        countdownLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width/3, height: view.frame.height/5)
        countdownLabel.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        didTapTakePhoto()
    }
    
    private var countdownTimer: Timer?
    private var countdown: Int = 3
    
    var posePhotoImageView = UIImageView()
    
    func showPoseAnimation(poseName: String, completion: @escaping () -> Void) {
        countdownLabel.removeFromSuperview()
        posePhotoImageView = UIImageView(image: UIImage(named: poseName))
        posePhotoImageView.frame = UIScreen.main.bounds
        view.addSubview(posePhotoImageView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [self] in
            // Execute the completion closure after a delay of 2 seconds (adjust the time as needed)
            self.posePhotoImageView.removeFromSuperview()
            view.addSubview(countdownLabel)
            completion()
        }
    }
    
    @objc private func didTapTakePhoto() {
        if images.count == 0 {
            showPoseAnimation(poseName: "FrontDoubleBicep") { [self] in
                countdownLabel.text = "\(countdown)"
                countdownLabel.isHidden = false
                countdownTimer?.invalidate()
                countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
                countdown = 3
            }
        } else if images.count == 1 {
            showPoseAnimation(poseName: "FrontLatSpread") { [self] in
                countdownLabel.text = "\(countdown)"
                countdownLabel.isHidden = false
                countdownTimer?.invalidate()
                countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
                countdown = 4
            }
        } else if images.count == 2 {
            showPoseAnimation(poseName: "BackBicepPose") { [self] in
                countdownLabel.text = "\(countdown)"
                countdownLabel.isHidden = false
                countdownTimer?.invalidate()
                countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
                countdown = 4
            }
        }
        
    }
    
    @objc func updateCountdown() {
        countdown -= 1
        countdownLabel.text = "\(countdown)"
        
        if countdown <= 0 {
            countdownTimer?.invalidate()
            takePhoto()
        }
    }
    
    func takePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    func uploadWorkoutPicturesToFirestoreDatabase() {
        self.delegate?.didFinishPhotoShoot(inProgress: true)
        var imageCount = 0
        let currentUser = Auth.auth().currentUser?.uid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, YYYY"
        let formattedDate = dateFormatter.string(from: Date())
        let storageRef = Storage.storage().reference()
        let refPath = "workoutPictures/\(currentUser!)/\(formattedDate)"
        let db = Firestore.firestore()
        
        
        let docRef = db.collection("users").document(currentUser!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var existingData = document.data() ?? [:]

                if var existingDictionary = existingData["imageReferences"] as? [String: Any] {
                    // If the dictionary exists, you can merge new data into it or modify it
                    existingDictionary[formattedDate] = refPath // Example of adding new data

                    // Update the existing dictionary in the document data
                    existingData["imageReferences"] = existingDictionary
                } else {
                    // If the dictionary doesn't exist, create a new one
                    existingData["imageReferences"] = [formattedDate: refPath]
                }

                // Update the Firestore document with the modified or new dictionary
                db.collection("users").document(currentUser!).updateData(existingData) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully updated")
                    }
                }
            } else {
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        
        for image in images {
            imageCount += 1
            let imageData = image.jpegData(compressionQuality: 0.8)
            
            guard imageData != nil else {
                return
            }
            
            let path = "workoutPictures/\(currentUser!)/\(formattedDate)/Image\(imageCount).jpg"
            
            let fileRef = storageRef.child(path)
            
            _ = fileRef.putData(imageData!, metadata: nil) { metadata, error in
                if error != nil && metadata == nil {
                    print(error ?? "error arose")
                }
            }
        }
        self.delegate?.didFinishPhotoShoot(inProgress: false)
    }
    
    func updateRecentDateOfWorkoutPictures() {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, YYYY"
        let formattedDate = dateFormatter.string(from: Date())
        
        let _: Void = db.collection("users").document(currentUser!).updateData(["mostRecentDateOfWorkoutPictures": formattedDate]) { error in
            if error != nil {
                print("Could not update name fields")
            }
        }
    }
    
    func pullPictureDateFromFirebase(completion: @escaping (Bool) -> Void) {
        let currentUser = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        
        db.collection("users").document(currentUser!).getDocument { snapshot, error in
            if error == nil && snapshot != nil {
                if let recentWorkoutPics = snapshot?["mostRecentDateOfWorkoutPictures"] as? String {
                    self.mostRecentDateOfWorkoutPictures = recentWorkoutPics
                    completion(true)
                } else {
                    print("failed")
                    completion(true)
                }
            } else {
                print("Could not find document")
                completion(false)
            }
        }
    }

    func hasElapsedTimePassed(since dateString: String, time: Int) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        if let date = dateFormatter.date(from: dateString) {
            let calendar = Calendar.current
            let currentDate = Date()
            
            if let difference = calendar.dateComponents([.day], from: date, to: currentDate).day, difference >= time {
                return true
            } else {
                return false
            }
        } else {
            return false // Return false if date parsing fails
        }
    }
}

extension PhotosVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        
        let image = UIImage(data: data)
        images.append(image!)
        
        if images.count < 3 {
            //Maybe present animation here later
            didTapTakePhoto()
        } else {
            session?.stopRunning()
            session = nil
            
            
            //Use vision to find coordinates of key body parts and check if they are in the correct position
            //TODO: Image 2 and 3 process algorithm needs testing
            for i in 0...2 {
                images[i].detectBodyParts { observations, error in
                    if (error != nil) || (observations?.count == 0) {
                        print("Error occured")
                        print("Observations: \(String(describing: observations))")
                        //self.validImagesDict = self.validImagesDict.mapValues { _ in false }
                    } else if let observations = observations {
                        let keyPointLocations = try? observations[0].recognizedPoints(forGroupKey: .all)
                        //Check what image is being analyzed
                        
                        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
                            .rightWrist,
                            .rightElbow,
                            .rightEar,
                            .leftWrist,
                            .leftElbow,
                            .leftEar
                        ]
                        
                        let rightWristLocation = keyPointLocations?[jointNames[0].rawValue]?.location
                        let rightElbowLocation = keyPointLocations?[jointNames[1].rawValue]?.location
                        let rightEarLocation = keyPointLocations?[jointNames[2].rawValue]?.location
                        let leftWristLocation = keyPointLocations?[jointNames[3].rawValue]?.location
                        let leftElbowLocation = keyPointLocations?[jointNames[4].rawValue]?.location
                        let leftEarLocation = keyPointLocations?[jointNames[5].rawValue]?.location
                        
                        if i == 0 {
                            if (rightWristLocation?.y ?? 1 < rightElbowLocation?.y ?? 0) || (leftWristLocation?.y ?? 1 < leftElbowLocation?.y ?? 0) {
                                self.validImagesDict[i] = false
                            }
                            
                        } else if i == 1 {
                            if (rightWristLocation?.y ?? 0 > rightElbowLocation?.y ?? 1) || (leftWristLocation?.y ?? 0 > leftElbowLocation?.y ?? 1) {
                                self.validImagesDict[i] = false
                            }
  
                        } else if i == 2 {
                            if (rightWristLocation?.y ?? 1 < rightElbowLocation?.y ?? 0) || (leftWristLocation?.y ?? 1 < leftElbowLocation?.y ?? 0) {
                                self.validImagesDict[i] = false
                            }
                        }
                    }
                }
            }
            
            if validImagesDict.allSatisfy({ $0.value == true}) {
                previewLayer.isHidden = true
                countdownLabel.isHidden = true
                takePhotoImageView.image = UIImage(named: "notPictureTimeImage")
                takePhotoImageView.layer.borderColor = CGColor(red: 255/255, green: 0, blue: 0, alpha: 1)
                takePhotoImageView.layer.borderWidth = 2
                takePhotoImageView.layer.cornerRadius = 5
                takePhotoImageView.isUserInteractionEnabled = false
                backgroundView.backgroundColor = UIColor(red: 235/255, green: 236/255, blue: 238/255, alpha: 1)
                previewLayer.removeFromSuperlayer()
                tabBarController?.tabBar.isHidden = false
                uploadWorkoutPicturesToFirestoreDatabase()
                updateRecentDateOfWorkoutPictures()
            } else {
                //TODO: Close out of window and show a popup menu that says error and prompts retake
                previewLayer.isHidden = true
                countdownLabel.isHidden = true
                takePhotoImageView.image = UIImage(named: "notPictureTimeImage")
                takePhotoImageView.layer.borderColor = CGColor(red: 255/255, green: 0, blue: 0, alpha: 1)
                takePhotoImageView.layer.borderWidth = 2
                takePhotoImageView.layer.cornerRadius = 5
                takePhotoImageView.isUserInteractionEnabled = false
                backgroundView.backgroundColor = UIColor(red: 235/255, green: 236/255, blue: 238/255, alpha: 1)
                previewLayer.removeFromSuperlayer()
                tabBarController?.tabBar.isHidden = false
                
                //TODO: Needs testing
                let imageErrorIndex = validImagesDict.firstIndex(where: { $0.value == false }).map { validImagesDict.distance(from: validImagesDict.startIndex, to: $0) + 1 }
                let alertController = UIAlertController(title: "Incorrect Position: Image \(String(describing: imageErrorIndex))", message: "Please retake photos", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                alertController.addAction(dismissAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        
    }
}

extension UIImage {
    func detectBodyParts(completion: @escaping ([VNHumanBodyPoseObservation]?, Error?) -> Void) {
        guard let ciImage = CIImage(image: self) else {
            completion(nil, NSError(domain: "UIImageExtensionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create CIImage from UIImage."]))
            return
        }

        let request = VNDetectHumanBodyPoseRequest()

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        do {
            try handler.perform([request])
            if let observations = request.results {
                completion(observations, nil)
            } else {
                completion(nil, NSError(domain: "UIImageExtensionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get body pose observations."]))
            }
        } catch {
            completion(nil, error)
        }
    }
}
