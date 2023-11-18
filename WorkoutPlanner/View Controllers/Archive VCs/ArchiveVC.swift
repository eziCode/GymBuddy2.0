//
//  ArchiveVC.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 6/2/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ArchiveVC: UIViewController, ArchiveImageCellDelegate {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    var images: [String: [UIImage]] = [:]
    var imageReferenceMap: [String: String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFilterButton()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        retrieveImageReferenceMap { [self] success in
            if success {
                retrieveImagesFromReferences { worked in
                    if worked {
                        self.mainCollectionView.reloadData()
                    }
                    //Do something with images (Probably need to move code into data source method)
                }
            }
        }
        
    }

    func configureFilterButton() {
        if images.keys.count == 0 {
            return
        }
        //Add dropdown menu for either ascending or descending order
        
        
        //Look through all collection view cells
        
    }
    
    func retrieveImagesFromReferences(completion: @escaping (Bool) -> Void) {
        if imageReferenceMap == nil {
            return
        }
        let storageRef = Storage.storage().reference()

        var imageIterator = imageReferenceMap!.values.makeIterator()

        func processNextImage() {
            guard let ref = imageIterator.next() else {
                // No more images to process
                completion(true)
                return
            }

            var imageArray: [UIImage] = []

            func handleCompletion() {
                if let key = imageReferenceMap?.first(where: { $0.value == ref })?.key {
                    images[key] = imageArray
                    // Continue with the next image
                    processNextImage()
                }
            }

            func processImage(index: Int) {
                guard index <= 3 else {
                    // All images for this date have been processed
                    handleCompletion()
                    return
                }

                let newRef = "\(ref)/Image\(index).jpg"
                let fileRef = storageRef.child(newRef)
                fileRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    defer {
                        // Continue with the next image in the sequence
                        processImage(index: index + 1)
                    }

                    guard error == nil, let data = data else {
                        print("Error: \(String(describing: error))")
                        completion(false)
                        return
                    }

                    let image = UIImage(data: data)
                    imageArray.append(image!)
                }
            }

            // Start processing the first image for the current date
            processImage(index: 1)
        }

        // Start processing the first date
        processNextImage()
    }
    
    func retrieveImageReferenceMap(completion: @escaping (Bool) -> Void) {
        //I upload picture set -> Save reference to set in map in Firebase (key = Date of picture -> value = Reference to Firestore)
        let db = Firestore.firestore()
        let currentUser = Auth.auth().currentUser?.uid
        let docRef = db.collection("users").document(currentUser!)
        
        docRef.getDocument { [self] snapshot, error in
            if error == nil && snapshot != nil {
                if let data = snapshot?.data() {
                    if let map = data["imageReferences"] as? [String: String] {
                        imageReferenceMap = map
                    }
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func didTapArchiveImageViewOpenMenu(key: String) {
        //Configure menu
        let imagePopupMenu = ImagePopupMenu()
        imagePopupMenu.configureMenu(imageArr: images[key] ?? [UIImage(named: "DefaultImage")!])
        imagePopupMenu.addSwipeCapability()
        present(imagePopupMenu, animated: true, completion: nil)
    }
    

}

extension ArchiveVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArchiveImageCell", for: indexPath) as! ArchiveImageCell
        
        let date = Array(images.keys)[indexPath.row]
        let imagesArray = images[date]
        guard let firstImage = (imagesArray?[0] ?? UIImage(named: "DefaultImage")) else { return cell }
        let workoutPic = WorkoutPicture(dateTaken: date, leadImage: firstImage)
        cell.setup(with: workoutPic)
        cell.delegate = self
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Add different amount of cells per row for different devices
        return CGSize(width: ((190/393)*view.frame.width), height: ((285/852)*view.frame.height))
    }
}
