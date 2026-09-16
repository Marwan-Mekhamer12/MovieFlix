//
//  HomePopularCVCell.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 12/08/2026.
//

import UIKit

class HomePopularCVCell: UICollectionViewCell {
    
    @IBOutlet weak var urlImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel?
    
    private var currentTask: Task<Void, Never>?
    
    func setUp(_ items: Movie) {
        urlImg.image = nil
        titleLabel?.text = items.title
        urlImg.layer.cornerRadius = 18
        currentTask?.cancel()
        
        guard let urlString = items.backdropURL else {return}
        
        
        currentTask = Task { [weak self] in
            await self?.loadingData(urlString: urlString)
        }
        
    }
    
    private func loadingData(urlString: String) async {
        
        if Task.isCancelled {return}
        
        if let cache = ImagesCache.shared.imagesObject(for: urlString) {
            await MainActor.run { [weak self] in
                self?.urlImg.image = cache
            }
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled {return}
            if let image = UIImage(data: data) {
                ImagesCache.shared.imagesSetObject(image, for: urlString)
                await MainActor.run {[weak self] in
                    self?.urlImg.image = image
                }
                return
            }
            
            
        } catch {
            print("Error in Popular cell: \(error.localizedDescription)")
            return
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        urlImg.image = nil
        titleLabel?.text = nil
    }
    
}
