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


class ViewModelUpComing: ViewModelUpComingProtocol {
    
    @Published var arrData = [Movie]()
    @Published var filterData = [Movie]()
    @Published var isLoading = false
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
        arrData = []
        await fetchNextPage()
        
    }
    
    func FetchMoreIfNeeded(_ currentIndex: Int) async {
        guard !isFetching, currentIndex >= filterData.count - 5 else {return}
        await fetchNextPage()
        
    }
    
    func fetchNextPage() async {
        guard !isSearching, currentPage <= totalPages else {return}
        isFetching = true
        defer {isFetching = false}
        isLoading = true
        message = nil
        
        do {
            
            let response: MovieResponse = try await manager.fetchData(from: .upComingMovies(page: currentPage))
            arrData.append(contentsOf: response.results)
            filterData = arrData
            totalPages = response.total_pages
            currentPage += 1
            self.isLoading = false
            
        } catch is CancellationError {
            isLoading = false
            
        } catch {
            isLoading = false
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
