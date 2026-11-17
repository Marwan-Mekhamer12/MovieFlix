//
//  ViewModelTopRated.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 17/08/2026.
//

import Foundation
import Combine


@MainActor
class ViewModelTopRated: ViewModelProtocol{
    
    @Published private(set) var arrDataTopRated = [Movie]()
    @Published private(set) var filterData = [Movie]()
    @Published private(set) var isLoad = false
    @Published private(set) var message: String?
    
    // Infinite Scroll
    private(set) var currentPage = 1
    private(set) var totalPages = 1
    private(set) var isFetching = false
    private(set) var isSearching = false
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()) {
        self.manager = manager
    }
    
    func loadingData() async {
        currentPage = 1
        totalPages = 1
        isSearching = false
        arrDataTopRated = []
        filterData = []
        await fetchNextPage()
        
    }
    
    func fetchedIfNeeded(_ currentIndex: Int) async {
        guard !isSearching, currentIndex >= filterData.count - 5 else {return}
        await fetchNextPage()
        
    }
    
    func fetchNextPage() async {
        guard !isFetching, currentPage <= totalPages else {return}
        isFetching = true
        isLoad = true
        defer {isFetching = false; isLoad = false}
        message = nil
        
        do {
            let response: MovieResponse = try await manager.fetchData(from: .topRatedMovies(page: currentPage))
            self.arrDataTopRated.append(contentsOf: response.results)
            self.filterData = arrDataTopRated
            self.totalPages = response.total_pages
            self.currentPage += 1
            
        } catch is CancellationError{
            return
        } catch {
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
