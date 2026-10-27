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
    func fetchMoreIfNeeded(_ currentIndex: Int) async
    func fetchNextPage() async
}

@MainActor
class ViewModelTopRated: ViewModelTopRatedProtocol{
    
    @Published var arrDataTopRated = [Movie]()
    @Published var filterData = [Movie]()
    @Published var isLoad = false
    @Published var message: String?
    
    // Infinite Scroll
    private var currentPage = 1
    private var totalPages = 1
    private var isFetching = false
    private var isSearching = false
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()) {
        self.manager = manager
    }
    
    func loadingData() async {
        currentPage = 1
        totalPages = 1
        arrDataTopRated = []
        await fetchNextPage()
        
    }
    
    func fetchMoreIfNeeded(_ currentIndex: Int) async {
        guard !isSearching, currentIndex >= filterData.count - 5 else {return}
        await fetchNextPage()
        
    }
    
    func fetchNextPage() async {
        guard !isFetching, currentPage <= totalPages else {return}
        isFetching = true
        defer {isFetching = false}
        isLoad = true
        message = nil
        do {
            let response: MovieResponse = try await manager.fetchData(from: .topRatedMovies(page: currentPage))
            self.arrDataTopRated.append(contentsOf: response.results)
            self.filterData = arrDataTopRated
            self.totalPages = response.total_pages
            self.currentPage += 1
            isLoad = false
        } catch is CancellationError{
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
        isSearching = !trimmed.isEmpty
        filterData = isSearching
        ? arrDataTopRated.filter { $0.title.localizedStandardContains(trimmed)} : arrDataTopRated
    }
}
