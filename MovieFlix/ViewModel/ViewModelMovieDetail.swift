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
    
    @Published var movieDetails: MovieDetail?
    @Published var hasLoad = false
    @Published var message: String?
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()){
        self.manager = manager
    }
    
    func loadingData(movieId: Int) async {
        hasLoad = true
        message = nil
        
        do {
            let response: MovieDetail = try await manager.fetchData(from: .movieDetails(id: movieId))
            self.movieDetails = response
            self.hasLoad = false
            
        } catch {
            hasLoad = false
            message = "Field to load data from View Model Movie Details: \(error.localizedDescription)"
        }
    }
}
