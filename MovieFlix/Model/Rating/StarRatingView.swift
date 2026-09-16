//
//  StarRatingView.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 15/08/2026.
//

import UIKit

@IBDesignable
final class StarRatingView: UIView {
    
    
    @IBOutlet var starImageViews: [UIImageView]!
    
    
    func setRating(_ rate: Double) {
        
        let ratingOutOfFive = rate / 2.0
        
        for (index, imageView) in starImageViews.enumerated() {
            let starPosition = Double(index + 1)
            
            if ratingOutOfFive >= starPosition {
                imageView.image = UIImage(systemName: "star.fill")
            } else if ratingOutOfFive >= starPosition - 0.5 {
                imageView.image = UIImage(systemName: "star.leadinghalf.filled")
            } else {
                imageView.image = UIImage(systemName: "star")
            }
            
            imageView.tintColor = .systemYellow
        }
    }
    
}

