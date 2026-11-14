//
//  NowPlayingMovies.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 28/10/2026.
//

import UIKit

class NowPlayingMovies: UICollectionViewCell {
    
    @IBOutlet weak var imageURL: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var currentTask: Task<Void, Never>?
    
    func setUP(items: Movie) {
        
        titleLabel?.text = items.title
        imageURL.image = nil
        imageURL.layer.cornerRadius = 18
        currentTask?.cancel()
        
        guard let url = items.backdropURL else {return}
        
        currentTask = Task { [weak self] in
            await self?.loadingImage(url)
        }
        
    }
    
    private func loadingImage(_ urlString: String) async {
        
        if Task.isCancelled {return}
        if let cache = ImagesCache.shared.imagesObject(for: urlString) {
            await MainActor.run { [weak self] in
                self?.imageURL.image = cache
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                ImagesCache.shared.imagesSetObject(image, for: urlString)
                await MainActor.run { [weak self] in
                    self?.imageURL.image = image
                }
                return
            }
        } catch {
            print("Error in NowPlayingMovies Cell: \(error.localizedDescription)")
            return
        }
        
    }
    
    
    
}
