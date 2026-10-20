//
//  FavoriteStore.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 18/10/2026.
//

import UIKit
import CoreData

final class FavoriteStore {
    
    static let shared = FavoriteStore()
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func fetchAll() -> [FavoriteItems] {
        let request = FavoriteMovies.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let result = (try? context.fetch(request)) ?? []
        return result.map {
            FavoriteItems(id: Int($0.id), title: $0.title ?? "",
                          imageURL: $0.image, rating: $0.rating,
                          overView: $0.overView ?? "", cast: $0.cast ?? "",
                          director: $0.director ?? "")
        }
    }
    
    func isFavorite(_ id: Int) -> Bool {
        let request = FavoriteMovies.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", Int64(id))
        request.fetchLimit = 1
        return ((try? context.count(for: request)) ?? 0) > 0
    }
    
    func add(_ id: Int,_ title: String,_ rating: Double,_ image: String?,
             _ overView: String,_ cast: String,_ director: String) {
        
        guard !isFavorite(id) else {return}
        let fav = FavoriteMovies(context: context)
        fav.id = Int64(id)
        fav.title = title
        fav.image = image
        fav.rating = rating
        fav.overView = overView
        fav.cast = cast
        fav.director = director
        fav.date = Date()
        
        appDelegate.saveContext()
    }
    
    func remove(_ id: Int) {
        let request = FavoriteMovies.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", Int64(id))
        (try? context.fetch(request))?.forEach {
            context.delete($0)
        }
        appDelegate.saveContext()
    }
}



// Favorite Data
struct FavoriteItems {
    let id: Int
    let title: String
    let imageURL: String?
    let rating: Double
    let overView: String
    let cast: String
    let director: String
    
    var asMovie: Movie {
        Movie(adult: false, backdroppath: imageURL, id: id, title: title, originallanguage: "", overview: overView, popularity: 0, posterpath: "", releasedate: "", voteaverage: rating, votecount: 0)
    }
}
