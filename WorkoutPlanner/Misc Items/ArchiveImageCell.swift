//
//  ArchiveImageCell.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 10/21/23.
//

import UIKit

protocol ArchiveImageCellDelegate: AnyObject {
    func didTapArchiveImageViewOpenMenu(key: String)
}

class ArchiveImageCell: UICollectionViewCell {
    
    @IBOutlet weak var archiveImageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    func setup(with workoutPicture: WorkoutPicture) {
        archiveImageView.isUserInteractionEnabled = true
        archiveImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapArchiveImageView)))
        archiveImageView.image = workoutPicture.leadImage
        dateLabel.text = workoutPicture.dateTaken
        archiveImageView.layer.cornerRadius = 50
        archiveImageView.contentMode = .scaleAspectFit
    }
    
    weak var delegate: ArchiveImageCellDelegate?
    
    @objc func didTapArchiveImageView() {
        self.delegate?.didTapArchiveImageViewOpenMenu(key: dateLabel.text!)
    }
    
}
