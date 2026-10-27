//
//  Traing.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/10/2026.
//

import Foundation
import UIKit
import CoreData

final class Traing {
    
    static let shared = Traing()
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    func fetchAll() -> [ItemsFav] {
        let request = FavoriteMovies.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let result = (try? context.fetch(request)) ?? []
        return result.map {
            ItemsFav(id: Int($0.id), title: $0.title ?? "",
                     image: $0.image, rating: $0.rating,
                     overView: $0.overView ?? "", cast: $0.cast ?? "",
                     director: $0.director ?? "")
        }
    }
    
    func isFav(id: Int) -> Bool {
        let requrst = FavoriteMovies.fetchRequest()
        requrst.predicate = NSPredicate(format: "id == %lld", Int64(id))
        requrst.fetchLimit = 1
        return ((try? context.count(for: requrst)) ?? 0) > 0
    }
    
    func add(_ id: Int,_ title: String,_ image: String?,_ rating: Double,
             _ overView: String,_ cast: String,_ director: String) {
        
        guard !isFav(id: id) else {return}
        let fav = FavoriteMovies(context: context)
        fav.id = Int64(id)
        fav.title = title
        fav.image = image
        fav.rating = rating
        fav.overView = overView
        fav.cast = cast
        fav.director = director
        
        appDelegate.saveContext()
    }
    
    func remove(id: Int) {
        let request = FavoriteMovies.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", Int64(id))
        (try? context.fetch(request))?.forEach {
            context.delete($0)
        }
        appDelegate.saveContext()
    }
    
}

struct ItemsFav {
    let id: Int
    let title: String
    let image: String?
    let rating: Double
    let overView: String
    let cast: String
    let director: String
}
