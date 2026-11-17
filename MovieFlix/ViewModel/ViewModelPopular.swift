//
//  ViewModelPopularMovies.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 31/07/2026.
//

import Foundation
import Combine


@MainActor
class ViewModelPopular: ViewModelProtocol {
        
    @Published private(set) var arrData = [Movie]()
    @Published private(set) var filterData = [Movie]()
    @Published private(set) var isLoad = false
    @Published private(set) var messageError: String?
    
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
    
    func fetchedIfNeeded(_ currentIndex: Int) async {
        
        guard !isSearching, currentIndex >= filterData.count - 5 else {return}
        await fetchNextPage()
        
    }
    
    
    func fetchNextPage() async {
        
        guard !isFetching, currentPage <= totalPages else {return}
        isFetching = true
        isLoad = true
        defer {isFetching = false; isLoad = false}
        messageError = nil
        
        do {
            let response: MovieResponse = try await manager.fetchData(from: .popularMovies(page: currentPage) )
            self.arrData.append(contentsOf: response.results)
            self.filterData = arrData
            self.totalPages = response.total_pages
            currentPage += 1
            
        } catch is CancellationError {
            return
        } catch {
            messageError = "Field to load data from Pupluar \(error.localizedDescription)"
        }
    }
    
    func indexPath(at index: Int) -> Movie {
        return filterData[index]
    }
    
    func filterquery(with query: String) {
        let trimming = query.trimmingCharacters(in: .whitespaces)
        isSearching = !trimming.isEmpty
        filterData = isSearching
        ? arrData.filter{
            $0.title.localizedStandardContains(trimming)} : arrData
    }
    
}
