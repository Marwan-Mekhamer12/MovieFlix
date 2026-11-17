//
//  MovieParsingTests.swift
//  MovieFlixTests
//
//  Created by Marwan Mekhamer on 16/11/2026.
//

import XCTest
@testable import MovieFlix

final class MovieParsingTests: XCTestCase {
    
    // MARK: - Helper
    
    private func decodedData<T: Decodable>(_ json: String) throws -> T {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // MARK: - Movie test
    
    func test_decodeMovie_mapsAllFieldsCorrectly() throws {
        let json = """
        {
        "adult": false,
        "backdrop_path": "/backdrop.jpg",
        "id": 27500,
        "title": "Spiderman",
        "original_language": "en",
        "overview": "A boy has a power",
        "popularity": 85.5,
        "poster_path": "/poster.jpg",
        "release_date": "15-7-2026",
        "vote_average": 8.5,
        "vote_count": 35000
        }
        """
        
        let movie: Movie = try decodedData(json)
        
        XCTAssertFalse(movie.adult)
        XCTAssertEqual(movie.backdroppath, "/backdrop.jpg")
        XCTAssertEqual(movie.id, 27500)
        XCTAssertEqual(movie.title, "Spiderman")
        XCTAssertEqual(movie.originallanguage, "en")
        XCTAssertEqual(movie.overview, "A boy has a power")
        XCTAssertEqual(movie.popularity, 85.5)
        XCTAssertEqual(movie.posterpath, "/poster.jpg")
        XCTAssertEqual(movie.releasedate, "15-7-2026")
        XCTAssertEqual(movie.voteaverage, 8.5)
        XCTAssertEqual(movie.votecount, 35000)
    }
    
    func test_movieDecoded_withNilImages() throws {
        let json = """
        {
        "adult": false,
        "backdrop_path": null,
        "id": 1,
        "title": "Spiderman",
        "original_language": "en",
        "overview": "A boy has a power",
        "popularity": 85.5,
        "poster_path": null,
        "release_date": "15-7-2026",
        "vote_average": 8.5,
        "vote_count": 35000
        }
        """
        
        let movie: Movie = try decodedData(json)
        
        XCTAssertNil(movie.backdroppath)
        XCTAssertNil(movie.posterpath)
        
    }
    
    func test_decodeMovie_missingRequiredField_throws() {
        let json = """
        { "adult": false, "id": 1 }
        """
        XCTAssertThrowsError(try decodedData(json) as Movie)
    }
    
    // MARK: - MovieResponse
    
    func test_decodeMovieResponse_mapsPagesAndResults() throws {
        let json = """
           {
             "page": 2,
             "total_pages": 50,
             "results": [
               {
                 "adult": false, "backdrop_path": null, "id": 1, "title": "A",
                 "original_language": "en", "overview": "", "popularity": 1.0,
                 "poster_path": null, "release_date": "2026-01-01",
                 "vote_average": 5.0, "vote_count": 0
               }
             ]
           }
           """
        
        let response: MovieResponse = try decodedData(json)
        
        XCTAssertEqual(response.page, 2)
        XCTAssertEqual(response.total_pages, 50)
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results.first?.title, "A")
    }
}
