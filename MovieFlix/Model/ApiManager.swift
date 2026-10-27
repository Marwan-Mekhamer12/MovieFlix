//
//  ApiManager.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 31/07/2026.
//

import Foundation


protocol ApiManagerProtocol {
    func fetchData<T: Codable>(from endPoint: TMDBEndpoint) async throws -> T
    
}

final class ApiManager: ApiManagerProtocol {
    
    static let shared = ApiManager()
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let api_Keys = "264a0a68c3b6f9c46619b41fa7be1394"
    
    
    
    func fetchData<T: Codable>(from endPoint: TMDBEndpoint) async throws -> T {
        
        var components = URLComponents(string: baseURL + endPoint.path)!
        components.queryItems = endPoint.queryItems + [
        URLQueryItem(name: "api_key", value: api_Keys),
        URLQueryItem(name: "language", value: "en-US")
        ]
        
        guard let url = components.url else {
            throw ApiErrorHanding.invalidURL(baseURL + endPoint.path)
        }
        
        print("🔍 Requesting URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiErrorHanding.badResponse(-1)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw ApiErrorHanding.badResponse(httpResponse.statusCode)
            }
            
            do {
                let decode = try JSONDecoder().decode(T.self, from: data)
                return decode
            } catch {
                throw ApiErrorHanding.invalidDecoded("\(error)")
            }
            
        }
        
    }
    
}
