//
//  UpCamingHomeCell.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/08/2026.
//

import UIKit

class UpCamingHomeCell: UICollectionViewCell {
    
    @IBOutlet weak var urlImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel?
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(items: Movie) {
        
        titleLabel?.text = items.title
        urlImage.image = nil
        urlImage.layer.cornerRadius = 18
        
        guard let url = items.backdropURL else {return}
        
        currentTask = Task { [weak self] in
            await self?.loadingData(url)
        }
    }
    
    private func loadingData(_ urlString: String) async {
        
        if Task.isCancelled {return}
        if let cache = ImagesCache.shared.imagesObject(for: urlString) {
            await MainActor.run { [weak self] in
                self?.urlImage.image = cache
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                ImagesCache.shared.imagesSetObject(image, for: urlString)
                await MainActor.run { [weak self] in
                    self?.urlImage.image = image
                }
            }
            return
            
        } catch {
            print("Error in Up Caming Cell: \(error.localizedDescription)")
            return
        }
        
    }
    
}
