//
//  LibraryCell.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 13/08/2026.
//

import UIKit

final class AllPopularCell: UICollectionViewCell {
    
    @IBOutlet weak var urlImage: UIImageView!
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(_ items: Movie) {
        urlImage.image = nil
        urlImage.layer.cornerRadius = 18
        currentTask?.cancel()
        
        guard let urlString = items.backdropURL else {return}
        
        currentTask = Task { [weak self] in
            await self?.loadingData(urlString: urlString)
        }
        
        
    }
    
    private func loadingData(urlString: String) async {
        
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
            if let image = UIImage(data: data) {
                ImagesCache.shared.imagesSetObject(image, for: urlString)
                await MainActor.run { [weak self] in
                    self?.urlImage.image = image
                }
                return
            }
            
        } catch {
            print("Error in All Popluar cell: \(error.localizedDescription)")
            return
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentTask?.cancel()
        currentTask = nil
        urlImage.image = nil
    }
    
    
}
