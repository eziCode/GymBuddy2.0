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
import DropDown

class ArchiveVC: UIViewController, ArchiveImageCellDelegate, PhotosVcDelegate {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "RefreshImage"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    var uploadInProgress: Bool = false
    
    var images: [(String, [UIImage])] = []
    var imageReferenceMap: [String: String]? = nil
    
    let menu: DropDown = {
        let menu = DropDown()
        //Option for menu
        menu.dataSource = ["Ascending order", "Descending order"]
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFilterButton()
        configureRefreshButton()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        if !uploadInProgress {
            retrieveImageReferenceMap { [self] success in
                if success {
                    retrieveImagesFromReferences { worked in
                        if worked {
                            
                            self.mainCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    func didFinishPhotoShoot(inProgress: Bool) {
        uploadInProgress = inProgress
    }
    
    func configureRefreshButton() {
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(didTapRefreshButton), for: .touchUpInside)
        
        view.addSubview(refreshButton)
        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 3),
            refreshButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            refreshButton.widthAnchor.constraint(equalToConstant: 60), // Adjust width as needed
            refreshButton.heightAnchor.constraint(equalToConstant: 60) // Adjust height as needed
        ])
    }
    
    @objc func didTapRefreshButton() {
        if !uploadInProgress {
            self.refreshButton.isEnabled = false
            self.images.removeAll()
            self.imageReferenceMap?.removeAll()
            self.mainCollectionView.reloadData()
            
            retrieveImageReferenceMap { [self] success in
                if success {
                    retrieveImagesFromReferences { worked in
                        if worked {
                            DispatchQueue.main.async {
                                self.mainCollectionView.reloadData()
                            }
                        }
                    }
                }
                refreshButton.isEnabled = true
            }
        }
    }

    func configureFilterButton() {
        //Add dropdown menu for either ascending or descending order
        let filterButton = UIButton()
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        filterButton.tintColor = .black
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)

        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 3),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 60), // Adjust width as needed
            filterButton.heightAnchor.constraint(equalToConstant: 60) // Adjust height as needed
        ])
        
        // Set up the menu
        menu.anchorView = filterButton
        menu.dataSource = ["Ascending order", "Descending order"]
        
        menu.selectionAction = { index, title in
            self.filterSort(index: index, title: title)
        }
    }
    
    func filterSort(index: Int, title: String) {
        let dateConverter = DateFormatter()
        dateConverter.dateFormat = "MMMM d, yyyy"
        
        var sortedImagesArray: [(String, [UIImage])] = []
        
        switch (index, title) {
        case(0, "Ascending order"):
            guard images.count > 1 else { break }
            //Filter in ascending order
            let sortedKeys = images.map { $0.0 }.sorted(by: { key1, key2 in
                guard let date1 = dateConverter.date(from: key1),
                      let date2 = dateConverter.date(from: key2) else { return false }
                return date1.compare(date2) == .orderedAscending
            })
            // Create a new array of tuples with the sorted keys and non-optional values
            sortedImagesArray = sortedKeys.compactMap { key in
                guard let imagesArray = images.first(where: { $0.0 == key })?.1 else { return nil }
                return (key, imagesArray)
            }
        case (1, "Descending order"):
            guard images.count > 1 else { break }
            let sortedKeys = images.map { $0.0 }.sorted(by: { key1, key2 in
                guard let date1 = dateConverter.date(from: key1),
                      let date2 = dateConverter.date(from: key2) else { return false }
                return date1.compare(date2) == .orderedDescending
            })
            // Create a new array of tuples with the sorted keys and non-optional values
            sortedImagesArray = sortedKeys.compactMap { key in
                guard let imagesArray = images.first(where: { $0.0 == key })?.1 else { return nil }
                return (key, imagesArray)
            }
        default:
            menu.hide()
            break
        }
        
        images = sortedImagesArray
        
        DispatchQueue.main.async {
            self.mainCollectionView.reloadData()
        }
        menu.hide()
    }
    
    @objc func didTapFilterButton() {
        menu.hide()
        menu.show()
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
                    let tuple = (key, imageArray)
                    images.append(tuple)
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
        imagePopupMenu.configureMenu(imageArr: images.first(where: { $0.0 == key })?.1 ?? [UIImage(named: "DefaultImage")!])
        imagePopupMenu.addSwipeCapability()
        present(imagePopupMenu, animated: true, completion: nil)
    }
    

}

extension ArchiveVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArchiveImageCell", for: indexPath) as! ArchiveImageCell
        do {
            let date = images[indexPath.row].0
            let imagesArray = images[indexPath.row].1
            let firstImage = imagesArray[0]
            let workoutPic = WorkoutPicture(dateTaken: date, leadImage: firstImage)
            cell.setup(with: workoutPic)
            cell.delegate = self
        } catch {
            return cell
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Add different amount of cells per row for different devices
        return CGSize(width: ((190/393)*view.frame.width), height: ((285/852)*view.frame.height))
    }
}
