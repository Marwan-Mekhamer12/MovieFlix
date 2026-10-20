//
//  FavoriteMovies+CoreDataProperties.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/10/2026.
//
//

import Foundation
import CoreData


extension FavoriteMovies {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteMovies> {
        return NSFetchRequest<FavoriteMovies>(entityName: "FavoriteMovies")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: Int64
    @NSManaged public var image: String?
    @NSManaged public var title: String?
    @NSManaged public var rating: Double
    @NSManaged public var overView: String?
    @NSManaged public var cast: String?
    @NSManaged public var director: String?

}

extension FavoriteMovies : Identifiable {

}
