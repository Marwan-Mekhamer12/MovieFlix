////
////  ApiRequest.swift
////  MovieFlix
////
////  Created by Marwan Mekhamer on 31/07/2026.
////
//
// https://api.themoviedb.org/3/movie/popular?api_key=264a0a68c3b6f9c46619b41fa7be1394&language=en-US&page=1
//
import Foundation
//
//
enum TMDBEndpoint {
    case popularMovies(page: Int)
    case topRatedMovies(page: Int)
    case upComingMovies(page: Int)
    case nowPlayingMovies(page: Int)
    case movieDetails(id: Int)  // ✅ New One
    
    var path: String {
        switch self {
        case .popularMovies:
            return "/movie/popular"
        case .topRatedMovies:
            return "/movie/top_rated"
        case .upComingMovies:
            return "/movie/upcoming"
        case .nowPlayingMovies:
            return "/movie/now_playing"
        case .movieDetails(let id):  // ✅ New One
            return "/movie/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .popularMovies(let page),
                .topRatedMovies(let page),
                .upComingMovies(let page),
                .nowPlayingMovies(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .movieDetails: // ✅ New One
            return [URLQueryItem(name: "append_to_response", value: "credits,videos,recommendations")]
        }
    }
    
}

