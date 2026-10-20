//
//  FavoriteTableViewCell.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 18/10/2026.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgFav: UIImageView!
    @IBOutlet weak var titleFav: UILabel!
    
    @IBOutlet weak var ratingView: StarsRatingViewFavorite!
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(_ items: FavoriteItems) {
        
        imgFav.image = nil
        titleFav.text = items.title
        ratingView.setRating(items.rating)
        imgFav.layer.cornerRadius = 18
        currentTask?.cancel()
        
        guard let urlString = items.asMovie.backdropURL else {return}
        
        currentTask = Task { [weak self] in
            await self?.loadingData(urlString)
        }
    }
    
    private func loadingData(_ urlString: String) async {
        
        if Task.isCancelled {return}
        
        if let cache = ImagesCache.shared.imagesObject(for: urlString) {
            await MainActor.run { [weak self] in
                self?.imgFav.image = cache
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled {return}
            if let image = UIImage(data: data) {
                ImagesCache.shared.imagesSetObject(image, for: urlString)
                await MainActor.run { [weak self] in
                    self?.imgFav.image = image
                }
                return
            }
            
        } catch {
            print("Error to load image from Favorite TableView Cell: \(error.localizedDescription)")
            return
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        imgFav.image = nil
        titleFav.text = nil
        
    }
    
    
}

