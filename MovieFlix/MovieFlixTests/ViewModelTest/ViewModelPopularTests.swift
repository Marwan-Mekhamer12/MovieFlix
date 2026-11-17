//
//  ViewModelPopularTests.swift
//  MovieFlixTests
//
//  Created by Marwan Mekhamer on 11/11/2026.
//

import XCTest
@testable import MovieFlix

@MainActor
final class ViewModelPopularTests: XCTestCase {
    
    var mock: MockApiManager!
    var sut: ViewModelPopular!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mock = MockApiManager()
        sut = ViewModelPopular(manager: mock)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        mock = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper (Assistant func): Because not writing all Properties in every test_func, we just need id and title.
    private func makeMovieHelper(_ id: Int,_ title: String) -> Movie {
        Movie(adult: false, backdroppath: nil, id: id, title: title,
              originallanguage: "en", overview: "OverView",
              popularity: 1.0, posterpath: nil, releasedate: "1-1-2026",
              voteaverage: 7.5, votecount: 100)
    }
    
    private func makeMovies(_ title: [String]) -> [Movie] {
        title.enumerated().map {makeMovieHelper($0.offset, $0.element)}
    }
    
    private func makeResponse(title: [String], totalPages: Int = 1) -> MovieResponse {
        MovieResponse(page: 1, total_pages: totalPages, results: makeMovies(title))
    }
    
    // MARK: - Start Test
    
    // Success
    func test_loadingData_success_fillingArray() async {
        mock.result = .success(makeResponse(title: ["A", "B"]))
        
        await sut.loadingData()
        
        XCTAssertEqual(sut.arrData.count, 2)
        XCTAssertEqual(sut.filterData.count, 2)
        XCTAssertNil(sut.messageError)
    }
    
    // Failure
    func test_loadingData_filure_messageError() async {
        mock.result = .failure(URLError(.notConnectedToInternet))
        await sut.loadingData()
        
        XCTAssertNotNil(sut.messageError)
        XCTAssertTrue(sut.arrData.isEmpty)
        XCTAssertTrue(sut.filterData.isEmpty)
        
    }
    
    // Pages test
    func test_fetchNextPage_appendsData_andIncrementsPage() async {
        mock.result = .success(makeResponse(title: ["A"], totalPages: 3))
        
        await sut.fetchNextPage()
        await sut.fetchNextPage()
        
        XCTAssertEqual(mock.resultPages, [1, 2])
        XCTAssertEqual(sut.arrData.count, 2)
    }
    
    // Load more if needed test
    func test_loadMore_nearEnd_fetchesNextPage() async {
        let title = (0..<10).map {"M\($0)"}
        mock.result = .success(makeResponse(title: title, totalPages: 2))
        
        await sut.loadingData()
        await sut.loadMoreIfNeeded(9)
        
        XCTAssertEqual(mock.fetchCallCount, 2)
    }
    
    // Filter test
    func test_FilterMovie() async {
        mock.result = .success(makeResponse(title: ["Batman", "Superman",
                                                    "Spiderman", "Ironman"]))
        
        await sut.loadingData()
        sut.filterquery(with: "Bat")
        
        XCTAssertEqual(mock.fetchCallCount, 1)
        XCTAssertEqual(sut.filterData.count, 1)
        XCTAssertEqual(sut.filterData.first?.title, "Batman")
    }
    
}
