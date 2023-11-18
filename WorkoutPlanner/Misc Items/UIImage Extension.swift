//
//  UIImage Extension.swift
//  WorkoutPlanner
//
//  Created by Ezra Akresh on 8/6/23.
//

import Foundation
import UIKit

extension UIImage {
    func circularCrop(radius: CGFloat) -> UIImage? {
            // Calculate the square size of the circle to be cropped
            _ = radius * 2
            let sideLength = min(size.width, size.height)
            let newSize = CGSize(width: sideLength, height: sideLength)
            
            // Calculate the cropping origin
            let x = (size.width - sideLength) / 2
            let y = (size.height - sideLength) / 2
            let cropRect = CGRect(x: x, y: y, width: sideLength, height: sideLength)
            
            // Crop the image
            if let cgImage = cgImage?.cropping(to: cropRect) {
                let croppedImage = UIImage(cgImage: cgImage)
                
                // Create a circular mask
                UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
                let context = UIGraphicsGetCurrentContext()!
                context.addEllipse(in: CGRect(origin: .zero, size: newSize))
                context.closePath()
                context.clip()
                croppedImage.draw(in: CGRect(origin: .zero, size: newSize))
                let circularImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return circularImage
            }
            
            return nil
        }
    
    func fixOrientation() -> UIImage{
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}

