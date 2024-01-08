//
//  ImagePopupMenu.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 11/18/23.
//

import Foundation
import UIKit

class ImagePopupMenu: UIViewController {
    
    private let backgroundView = UIView()
    
    private var images: [UIImage] = []
    private var currentImageIndex = 0
    
    private var scrollView = UIScrollView()
    private var contentWidth: CGFloat = 0.0
    
    func configureMenu(imageArr: [UIImage]) {
        backgroundView.frame = view.bounds
        backgroundView.backgroundColor = UIColor(red: 235/255, green: 236/255, blue: 238/255, alpha: 1)
        
        self.images = imageArr
        
        scrollView.frame = view.bounds
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        self.view.addSubview(backgroundView)
        self.backgroundView.addSubview(scrollView)
    }

    func addSwipeCapability() {
        for index in 0..<images.count {
            let swipeImageView = UIImageView(image: images[index])
            let xCoordinate = view.frame.width * CGFloat(index)
            contentWidth += view.frame.width
            
            swipeImageView.contentMode = .scaleAspectFit
            
            scrollView.addSubview(swipeImageView)
            swipeImageView.frame = CGRect(x: xCoordinate, y: 0, width: view.frame.width, height: view.frame.height)
        }
        scrollView.contentSize = CGSize(width: contentWidth, height: view.frame.height)
    }
}
