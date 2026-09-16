//
//  TopRatedHomeSelected.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 17/08/2026.
//

import UIKit

class TopRatedHomeSelected: UICollectionViewCell {
    
    @IBOutlet weak var urlImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel?
    
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(_ items: Movie) {
        
        titleLabel?.text = items.title
        
        urlImage.image = nil
        urlImage.layer.cornerRadius = 18
        currentTask?.cancel()
        
        guard let url = items.backdropURL else {return}
        
        currentTask = Task { [weak self] in
            await self?.LoadingImage(url)
        }
    }
    
    private func LoadingImage(_ urlString: String) async {
        
        if Task.isCancelled {return}
        if let cache = ImagesCache.shared.imagesObject(for: urlString) {
            await MainActor.run {[weak self] in
                self?.urlImage.image = cache
            }
            return
        }
        guard let url = URL(string: urlString) else {return}
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled {return}
            guard let image = UIImage(data: data) else {return}
            ImagesCache.shared.imagesSetObject(image, for: urlString)
            await MainActor.run { [weak self] in
                self?.urlImage.image = image
            }
            return
            
            
        } catch {
            print("Error in Top Rated Home Selected: \(error.localizedDescription)")
            return
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentTask?.cancel()
        currentTask = nil
        titleLabel?.text = nil
        urlImage.image = nil
        
        
    }
    
    
    
}
