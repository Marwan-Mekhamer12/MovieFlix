//
//  APiErrorHandling.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 31/07/2026.
//

import Foundation


enum ApiErrorHanding: LocalizedError {
    case invalidURL(String)
    case badResponse(Int)
    case invalidDecoded(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid \(url)"
        case .badResponse(let code):
            return "Bad server response \(code)"
        case .invalidDecoded(let error):
            return "Field to decoded data \(error)"
        }
    }
    
}
