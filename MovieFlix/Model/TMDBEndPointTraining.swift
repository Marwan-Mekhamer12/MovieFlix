//
//  TMDBEndPointTraining.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 02/11/2026.
//

import Foundation
import Combine

enum TMDBEndPointTraining {
    
    case popular(page: Int)
    case topRated(page: Int)
    case nowPlaying(page: Int)
    case upComing(page: Int)
    case moDetails(id: Int)
    
    
    var path: String {
        switch self {
        case .popular:
            return "/movie/popular"
        case .nowPlaying:
            return "/movie/nowPlaying"
        case .topRated:
            return "/movie/topRated"
        case .upComing:
            return "/movie/upComing"
        case .moDetails(let id):
            return "/movie/\(id)"
        }
    }
    
    var queryItem: [URLQueryItem] {
        switch self {
        case .popular(let page),
                .upComing(let page),
                .topRated(let page),
                .nowPlaying(let page):
            return [URLQueryItem(name: "page", value: "\(page)")]
        case .moDetails:
            return [URLQueryItem(name: "appd", value: "creadits")]
        }
    }
}

enum ErrorApiTrainig: LocalizedError {
    case invalidURL(String)
    case badResponse(Int)
    case invalidDecode(String)
    case notNetwork(String)
    
    var errorDescription: String?{
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidDecode:
            return "Invalid Decoded"
        case .badResponse:
            return "Bad Response"
        case .notNetwork:
            return "forget NetWork"
        }
    }
}

protocol ApiManagerProtocolTraining {
    func fetData<T: Codable>(from endPoint: TMDBEndPointTraining) async throws -> T
}

final class APiManagerTraining: ApiManagerProtocolTraining {
    
    static let shared = APiManagerTraining()
    private let base = "https://api.movieapi.org/3"
    private let apiKey = "safas564e564s5dg4sdgfdf214"
    
    func fetData<T: Codable>(from endPoint: TMDBEndPointTraining) async throws -> T {
        var components = URLComponents(string: base + endPoint.path)!
        components.queryItems = endPoint.queryItem + [
            URLQueryItem(name: "Api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        guard let url = components.url else {
            throw ErrorApiTrainig.invalidURL(base + endPoint.path)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                throw ErrorApiTrainig.badResponse(-1)
            }
            guard (200...299).contains(httpURLResponse.statusCode) else {
                throw ErrorApiTrainig.badResponse(httpURLResponse.statusCode)
            }
            
            do {
                let decode = try JSONDecoder().decode(T.self, from: data)
                return decode
            } catch {
                throw ErrorApiTrainig.invalidDecode("\(error)")
            }
        }
    }
}

protocol VMProtocolTraining {
    func loadD() async
    func loadIfNeed(_ currentIndex: Int) async
    func loadMore() async
}

final class VMTraining: VMProtocolTraining {
    
    @Published private(set) var aData = [Movie]()
    @Published private(set) var filData = [Movie]()
    @Published private(set) var isLoad = false
    @Published private(set) var messageError: String?
    
    // MARK: - Infinite Scroll
    private var currentPage = 0
    private var totalPages = 0
    private var isFetch = false
    private var isSearching = false
    
    let manager: APiManagerTraining
    init(manager: APiManagerTraining = APiManagerTraining()) {
        self.manager = manager
    }
    
    func loadD() async {
        currentPage = 1
        totalPages = 1
        aData = []
        filData = []
        await loadMore()
    }
    
    func loadIfNeed(_ currentIndex: Int) async {
        guard !isSearching, currentIndex >= filData.count - 5 else {return}
        await loadMore()
    }
    
    func loadMore() async {
        guard !isFetch, currentPage <= totalPages else {return}
        isFetch = true
        isLoad = true
        defer{isFetch = false; isLoad = false}
        messageError = nil
        
        do {
            let response: MovieResponse = try await manager.fetData(from: .popular(page: currentPage))
            aData.append(contentsOf: response.results)
            filData = aData
            totalPages = response.total_pages
            currentPage += 1
        } catch is CancellationError {
            return
        } catch {
            messageError = "Error in ViewModel Popular"
        }
        
    }
    
    private func indexpath(at index: Int) -> Movie {
        return filData[index]
    }
    
    private func filterMovie(with query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        isSearching = !trimmed.isEmpty
        filData = isSearching
        ? aData.filter {$0.title.localizedStandardContains(trimmed)} : aData
    }
}
