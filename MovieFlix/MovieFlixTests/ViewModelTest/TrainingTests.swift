//
//  TrainingTests.swift
//  MovieFlixTests
//
//  Created by Marwan Mekhamer on 14/11/2026.
//

import XCTest
@testable import MovieFlix

@MainActor
final class TrainingTests: XCTestCase {
    
    var mock: MockApiManager!
    var sut: ViewModelPopular!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mock = MockApiManager()
        sut = ViewModelPopular(manager: mock)
    }
    
    override func tearDownWithError() throws {
        mock = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper
    func makeMoviesHelper(_ id: Int,_ title: String) -> Movie {
        Movie(adult: false, backdroppath: nil, id: id,
              title: title, originallanguage: "en",
              overview: "OverView", popularity: 1,
              posterpath: nil, releasedate: "16-11-2026",
              voteaverage: 7.5, votecount: 100)
    }
    
    func makeMovie(title: [String]) -> [Movie] {
        title.enumerated().map {makeMoviesHelper($0.offset, $0.element)}
    }
    
    func makeResponses(title: [String], totalPages: Int = 1) -> MovieResponse {
        MovieResponse(page: 1, total_pages: totalPages, results: makeMovie(title: title))
    }
    
    
}
