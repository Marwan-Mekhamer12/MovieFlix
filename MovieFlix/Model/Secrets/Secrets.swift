//
//  Secrets.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 02/11/2026.
//

import Foundation

enum Secrets {
    static var tmdbAPIKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["TMDB_API_KEY"] as? String
        else {
            fatalError("Secrets.plist مش موجود أو TMDB_API_KEY ناقص")
        }
        return key
    }
}
