//
//  ViewModelMovieDetail.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/08/2026.
//

import Foundation
import Combine

protocol ViewModelMovieDetailProtocol {
    func loadingData(movieId: Int) async
}

@MainActor
class ViewModelMovieDetail: ViewModelMovieDetailProtocol {
    
    @Published private(set) var movieDetails: MovieDetail?
    @Published private(set) var hasLoad = false
    @Published private(set) var message: String?
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()){
        self.manager = manager
    }
    
    func loadingData(movieId: Int) async {
        hasLoad = true
        defer{hasLoad = false}
        message = nil
        
        do {
            let response: MovieDetail = try await manager.fetchData(from: .movieDetails(id: movieId))
            self.movieDetails = response
            
        } catch {
            message = "Field to load data from View Model Movie Details: \(error.localizedDescription)"
        }
    }
}
