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
}


class ViewModelUpComing: ViewModelUpComingProtocol {
    
    @Published var arrData = [Movie]()
    @Published var isLoading = false
    @Published var message: String?
    
    let manager: ApiManagerProtocol
    init(manager: ApiManagerProtocol = ApiManager()) {
        self.manager = manager
    }

    func loadingData() async {
        isLoading = true
        message = nil
        
        do {
            let response: MovieResponse = try await manager.fetchData(from: .upComingMovies(page: 1))
            self.arrData = response.results.map {$0.self}
            isLoading = false
        } catch {
            isLoading = false
            message = "Field to load data from View Model Up Coming: \(error.localizedDescription)"
        }
    }
}
