//
//  imagesCache.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 13/08/2026.
//

import Foundation
import UIKit

final class ImagesCache {
    
    static let shared = ImagesCache()
    private let cache = NSCache<NSString, UIImage>()
    private init(){}
    
    func imagesObject(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func imagesSetObject(_ image: UIImage,for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    
}
