//
//  ViewModelUpComingTest.swift
//  MovieFlixTests
//
//  Created by Marwan Mekhamer on 14/11/2026.
//

import XCTest
@testable import MovieFlix

@MainActor
final class ViewModelUpComingTest: XCTestCase {
    
    var mock: MockApiManager!
    var sut: ViewModelUpComing!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        mock = MockApiManager()
        sut = ViewModelUpComing(manager: mock)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mock = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper
    
    private func makeMoviesHelp(_ id: Int,_ title: String) -> Movie {
        Movie(adult: false, backdroppath: nil, id: id,
              title: title, originallanguage: "en",
              overview: "OverView", popularity: 1,
              posterpath: nil, releasedate: "1-1-2026",
              voteaverage: 7.5, votecount: 100)
    }
    
    private func makeMovies(_ title: [String]) -> [Movie] {
        title.enumerated().map {makeMoviesHelp($0.offset, $0.element)}
    }
    
    private func makeResponse(_ title: [String],_ totalPages: Int = 1) -> MovieResponse {
        MovieResponse(page: 1, total_pages: totalPages, results: makeMovies(title))
    }
    
    // MARK: - UpComing test
    
    // Success
    func test_loadingData_Success_ArrayCount() async {
        mock.result = .success(makeResponse(["A", "B", "C", "D"]))
        await sut.loadingData()
        XCTAssertEqual(sut.arrData.count, 4)
        XCTAssertEqual(sut.filterData.count, 4)
        XCTAssertNil(sut.message)
        XCTAssertFalse(sut.arrData.isEmpty)
    }
    
    // Fail
    func test_loadingData_Failure_ArrayCount() async {
        mock.result = .failure(URLError(.notConnectedToInternet))
        await sut.loadingData()
        XCTAssertTrue(sut.arrData.isEmpty)
        XCTAssertTrue(sut.filterData.isEmpty)
        XCTAssertNotNil(sut.message)
    }
    
    // Pages test
    func test_fetchNextPage_appendsData_andIncrementsPage() async {
        mock.result = .success(makeResponse(["A"], 10))
        
        await sut.fetchNextPage()
        await sut.fetchNextPage()
        await sut.loadingData()
        
        XCTAssertNotEqual(mock.resultPages, [1, 2, 3])
        XCTAssertEqual(mock.resultPages, [1, 2, 1])
        XCTAssertEqual(mock.fetchCallCount, 3)
    }
    
    // Load more if needed test
    func test_loadMore_nearEnd_fetchesNextPage() async {
        let title = (0..<20).map {"M\($0)"}
        mock.result = .success(makeResponse(title, 10))
        
        await sut.FetchMoreIfNeeded(1)
        
        XCTAssertEqual(mock.fetchCallCount, 1)
        XCTAssertNotEqual(mock.fetchCallCount, 2)
        XCTAssertEqual(sut.arrData.count, 20)
    }
    
    // Filter test
    func test_FilterMovies() async {
        mock.result = .success(makeResponse(["Spiderman", "Batman"]))
        
        await sut.loadingData()
        sut.filterQuery(with: "man")
        
        XCTAssertEqual(mock.fetchCallCount, 1)
        XCTAssertEqual(sut.filterData.count, 2)
        XCTAssertEqual(sut.filterData.first?.title, "Spiderman")
    }
    
}
