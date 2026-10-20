//
//  ViewModelTopRated.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 17/08/2026.
//

import Foundation
import Combine

protocol ViewModelTopRatedProtocol {
    func loadingData() async
}

@MainActor
class ViewModelTopRated: ViewModelTopRatedProtocol{
    
    @Published var arrDataTopRated = [Movie]()
    @Published var filterData = [Movie]()
    @Published var isLoad = false
    @Published var message: String?
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()) {
        self.manager = manager
    }

    func loadingData() async {
        isLoad = true
        message = nil
        
        do {
            let response: MovieResponse = try await manager.fetchData(from: .topRatedMovies(page: 1))
            self.arrDataTopRated = response.results.map {$0.self}
            self.filterData = arrDataTopRated
            isLoad = false
        } catch {
            isLoad = false
            message = "Field to load image from View Model Top Rated: \(error.localizedDescription)"
        }
    }
    
    func indexPath(at index: Int) -> Movie {
        return filterData[index]
    }
    
    func filterQuery(with query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            filterData = arrDataTopRated
        } else {
            filterData = arrDataTopRated.filter {$0.title.localizedCaseInsensitiveContains(trimmed)}
        }
    }
}
