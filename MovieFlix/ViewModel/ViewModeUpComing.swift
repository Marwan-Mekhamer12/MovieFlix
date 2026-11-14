//
//  ViewModeUpComing.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/08/2026.
//

import Foundation
import Combine

protocol ViewModelUpComingProtocol {
    func loadingData() async
    func FetchMoreIfNeeded(_ currentIndex: Int) async
    func fetchNextPage() async
}

@MainActor
class ViewModelUpComing: ViewModelUpComingProtocol {
    
    @Published private(set) var arrData = [Movie]()
    @Published private(set) var filterData = [Movie]()
    @Published private(set) var isLoading = false
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
        arrData = []
        filterData = []
        await fetchNextPage()
        
    }
    
    func FetchMoreIfNeeded(_ currentIndex: Int) async {
        guard !isSearching, currentIndex >= filterData.count - 5 else {return}
        await fetchNextPage()
        
    }
    
    func fetchNextPage() async {
        guard !isFetching, currentPage <= totalPages else {return}
        isFetching = true
        isLoading = true
        defer {isFetching = false; isLoading = false}
        message = nil
        
        do {
            
            let response: MovieResponse = try await manager.fetchData(from: .upComingMovies(page: currentPage))
            arrData.append(contentsOf: response.results)
            filterData = arrData
            totalPages = response.total_pages
            currentPage += 1
            
            
        } catch is CancellationError {
            return
        } catch {
            message = "Field to Load Data from View Model UpComing: \(error.localizedDescription)"
        }
    }
    
    
    func indexPath(at index: Int) -> Movie {
        return filterData[index]
    }
    
    func filterQuery(with query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        isSearching = !trimmed.isEmpty
        filterData = isSearching
        ? arrData.filter {$0.title.localizedStandardContains(trimmed)} : arrData
    }
}
