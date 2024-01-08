//
//  UserIconTableViewCell.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 7/29/23.
//

import UIKit

class ImageIconTableViewCell: UITableViewCell {

    @IBOutlet weak var userIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        // Initialization code
        userIcon.contentMode = .scaleAspectFit
        //Set the scaling of userIcon
        userIcon.translatesAutoresizingMaskIntoConstraints = false
        let iconSize = ((128/852) * self.frame.height)
        NSLayoutConstraint.activate([
            userIcon.heightAnchor.constraint(equalToConstant: iconSize),
            userIcon.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: ((245/393)*self.frame.width)),
            userIcon.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: ((20/393)*self.frame.width)),
            userIcon.widthAnchor.constraint(equalTo: userIcon.heightAnchor)
        ])
    }

}
