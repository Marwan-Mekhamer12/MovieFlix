//
//  ViewModelTopRatedTests.swift
//  MovieFlixTests
//
//  Created by Marwan Mekhamer on 14/11/2026.
//

import XCTest
@testable import MovieFlix

@MainActor
final class ViewModelTopRatedTests: XCTestCase {
    
    var mock: MockApiManager!
    var sut: ViewModelTopRated!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        mock = MockApiManager()
        sut = ViewModelTopRated(manager: mock)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mock = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper
    
    private func makeMoviesHelp(_ id: Int,_ title: String) -> Movie {
        Movie(adult: false, backdroppath: nil, id: id, title: title,
              originallanguage: "en", overview: "OverView", popularity: 1,
              posterpath: nil, releasedate: "1-1-2026", voteaverage: 7.5, votecount: 100)
    }
    
    private func makeMovies(_ title: [String]) -> [Movie] {
        title.enumerated().map {makeMoviesHelp($0.offset, $0.element)}
    }
    
    private func makeResponse(_ title: [String],_ totalPages: Int = 1) -> MovieResponse {
        MovieResponse(page: 1, total_pages: totalPages, results: makeMovies(title))
    }
    
    // MARK: - TopRated Test
    
    // Success
    func test_loadingData_Success_ArrayCount() async {
        mock.result = .success(makeResponse(["A", "B", "C"]))
        await sut.loadingData()
        XCTAssertEqual(sut.arrDataTopRated.count, 3)
        XCTAssertEqual(sut.filterData.count, 3)
        XCTAssertNil(sut.message)
    }
    
    // Fail
    func test_loadingData_Failure_ArrayCount() async {
        mock.result = .failure(URLError(.notConnectedToInternet))
        await sut.loadingData()
        XCTAssertNotEqual(sut.arrDataTopRated.count, 1)
        XCTAssertTrue(sut.arrDataTopRated.isEmpty)
        XCTAssertNotNil(sut.message)
    }
    
    // Request pages test
    func test_fetchNextPage_appendsData_andIncrementsPage() async {
        mock.result = .success(makeResponse(["A"], 3))
        
        await sut.fetchNextPage()
        await sut.fetchNextPage()
        await sut.fetchNextPage()
        
        XCTAssertEqual(mock.resultPages, [1, 2, 3])
        XCTAssertEqual(sut.arrDataTopRated.count, 3)
    }
    
    // Load more if needed test
    func test_loadMore_nearEnd_fetchesNextPage() async {
        let title = (0..<10).map {"M\($0)"}
        mock.result = .success(makeResponse(title, 2))
        
        await sut.loadingData()
        await sut.fetchMoreIfNeeded(9)
        
        XCTAssertEqual(mock.fetchCallCount, 2)
    }
    
    // Filter test
    func test_FilterMovie() async {
        mock.result = .success(makeResponse(["Superman", "Batman", "Hulk"]))
        
        await sut.loadingData()
        sut.filterQuery(with: "Hu")
        
        XCTAssertEqual(mock.fetchCallCount, 1)
        XCTAssertEqual(sut.filterData.count, 1)
        XCTAssertEqual(sut.filterData.first?.title, "Hulk")
    }
}
