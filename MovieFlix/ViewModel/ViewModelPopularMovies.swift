//
//  ViewModelPopularMovies.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 31/07/2026.
//




import Foundation
import Combine

protocol ViewModelPopularMoviesProtocol {
    
    func loadingData() async
    
}

@MainActor
class ViewModelPopularMovies: ViewModelPopularMoviesProtocol {
    
    @Published var arrData = [Movie]()
    @Published var filterData = [Movie]()
    @Published var isLoad = false
    @Published var messageError: String?
    
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()) {
        self.manager = manager
    }
    
    func loadingData() async {
        isLoad = true
        messageError = nil
        
        do {
            
            let response: MovieResponse = try await manager.fetchData(from: .popularMovies(page: 1) )
            self.arrData = response.results.map {$0.self}
            self.filterData = arrData
            self.isLoad = false
        } catch {
            isLoad = false
            messageError = "Field to load data from Pupluar \(error.localizedDescription)"
        }
    }
    
    func indexPath(at index: Int) -> Movie {
        return filterData[index]
    }
    
    func filterquery(with query: String) {
        let trimming = query.trimmingCharacters(in: .whitespaces)
        if trimming.isEmpty {
            filterData = arrData
        } else {
            filterData = arrData.filter { $0.title.localizedCaseInsensitiveContains(trimming)}
        }
    }
    
}
