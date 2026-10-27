//
//  APIData.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 31/07/2026.
//

 // https://api.themoviedb.org/3/movie/popular?api_key=264a0a68c3b6f9c46619b41fa7be1394&language=en-US&page=1

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let total_pages: Int
    let results: [Movie]
    
    enum CondingKeys: String, CodingKey {
        case page, results
        case totalpages = "total_pages"
    }
}

struct Movie: Codable {
    let adult: Bool
    let backdroppath: String?
    let id: Int
    let title: String
    let originallanguage: String
    let overview: String
    let popularity: Double
    let posterpath: String?
    let releasedate: String
    let voteaverage: Double
    let votecount: Int

    enum CodingKeys: String, CodingKey {
        case id, adult, title, overview, popularity
        case posterpath = "poster_path"
        case backdroppath = "backdrop_path"
        case originallanguage = "original_language"
        case voteaverage = "vote_average"
        case releasedate = "release_date"
        case votecount = "vote_count"
    }
    
    // MARK: - Full image URLs
        private static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
        
        var backdropURL: String? {
            guard let backdroppath else { return nil }
            return Movie.imageBaseURL + backdroppath
        }
        
        var posterURL: String? {
            guard let posterpath else { return nil }
            return Movie.imageBaseURL + posterpath
        }
}


// MARK: - Movie Detail (Full Data with append_to_response)
struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterpath: String?
    let backdroppath: String?
    let voteaverage: Double
    let votecount: Int
    let releasedate: String
    let runtime: Int?
    let genres: [Genre]
    let credits: Credits
    let videos: VideosResponse
    let recommendations: MovieResponse

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, credits, videos, recommendations
        case posterpath = "poster_path"
        case backdroppath = "backdrop_path"
        case voteaverage = "vote_average"
        case votecount = "vote_count"
        case releasedate = "release_date"
    }

    private static let imageBaseURL = "https://image.tmdb.org/t/p/w500"

    var posterURL: String? {
        guard let posterpath else { return nil }
        return MovieDetail.imageBaseURL + posterpath
    }

    var backdropURL: String? {
        guard let backdroppath else { return nil }
        return MovieDetail.imageBaseURL + backdroppath
    }

    // اسهل تريلر يوتيوب متاح
    var trailer: VideoItem? {
        videos.results.first { $0.site == "YouTube" && $0.type == "Trailer" }
    }

    // المخرج
    var director: CrewMember? {
        credits.crew.first { $0.job == "Director" }
    }
}

struct Genre: Codable {
    let id: Int
    let name: String
}

struct Credits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Codable {
    let id: Int
    let name: String
    let character: String
    let profilepath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilepath = "profile_path"
    }

    private static let imageBaseURL = "https://image.tmdb.org/t/p/w200"

    var profileURL: String? {
        guard let profilepath else { return nil }
        return CastMember.imageBaseURL + profilepath
    }
}

struct CrewMember: Codable {
    let id: Int
    let name: String
    let job: String
    let department: String
}

struct VideosResponse: Codable {
    let results: [VideoItem]
}

struct VideoItem: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String

    var youtubeURL: String? {
        guard site == "YouTube" else { return nil }
        return "https://www.youtube.com/watch?v=\(key)"
    }

    var youtubeEmbedURL: String? {
        guard site == "YouTube" else { return nil }
        return "https://www.youtube.com/embed/\(key)"
    }
}
