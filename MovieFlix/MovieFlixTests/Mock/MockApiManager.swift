//
//  MockApiManager.swift
//  MovieFlixTests
//
//  Created by Marwan Mekhamer on 05/11/2026.
//

import Foundation
@testable import MovieFlix

// MARK: - Mock Apimanager

final class MockApiManager: ApiManagerProtocol {

    var result: Result<Any, Error> = .failure(MockError.notConfigured)
    private(set) var fetchCallCount = 0
    private(set) var resultPages = [Int]()

    func fetchData<T: Codable>(from endPoint: TMDBEndpoint) async throws -> T {
        fetchCallCount += 1

        if case .popularMovies(let page) = endPoint {
            resultPages.append(page)
        } else if case .topRatedMovies(let page) = endPoint {
            resultPages.append(page)
        } else if case .nowPlayingMovies(let page) = endPoint {
            resultPages.append(page)
        } else if case .upComingMovies(let page) = endPoint {
            resultPages.append(page)
        }
        
        let value = try result.get()

        guard let cased = value as? T else {
            throw MockError.wrongType
        }

        return cased

    }
}

// MARK: - MockError
enum MockError: Error {
    case notConfigured
    case wrongType
}


