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
    func loadMoreIfNeeded(_ currentIndex: Int) async
    func fetchNextPage() async
}

@MainActor
class ViewModelPopular: ViewModelPopularMoviesProtocol {
    
    @Published var arrData = [Movie]()
    @Published var filterData = [Movie]()
    @Published var isLoad = false
    @Published var messageError: String?
    
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
    
    func loadMoreIfNeeded(_ currentIndex: Int) async {
        
        guard !isSearching, currentIndex >= filterData.count - 5 else {return}
        await fetchNextPage()
        
    }
    
    
    func fetchNextPage() async {
        
        guard !isFetching, currentPage <= totalPages else {return}
        isFetching = true
        defer {isFetching = false}
        isLoad = true
        messageError = nil
        
        do {
            
            let response: MovieResponse = try await manager.fetchData(from: .popularMovies(page: currentPage) )
            self.arrData.append(contentsOf: response.results)
            self.filterData = arrData
            self.totalPages = response.total_pages
            currentPage += 1
            
            self.isLoad = false
        } catch is CancellationError {
            isLoad = false
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
        isSearching = !trimming.isEmpty
        filterData = isSearching
        ? arrData.filter{
            $0.title.localizedStandardContains(trimming)} : arrData
    }
    
}
