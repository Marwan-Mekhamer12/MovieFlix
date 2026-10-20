//
//  StarsRatingViewFavorite.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/10/2026.
//

import UIKit

final class StarsRatingViewFavorite: UIView {
    
    
    @IBOutlet var startsRatingViewFavorite: [UIImageView]!
    
    func setRating(_ rate: Double) {
        
        let ratingOutOfFive = rate / 2.0
        
        for (index, imageView) in startsRatingViewFavorite.enumerated() {
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
