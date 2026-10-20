//
//  ViewModelLibrary.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 18/10/2026.
//

import Foundation
import Combine

@MainActor
protocol ViewModelLibraryProtocol {
    func load()
    func filterQuery(with text: String)
    func remove(at index: Int)
    
}


class ViewModelLibrary: ViewModelLibraryProtocol {
    
    @Published private var arrData = [FavoriteItems]()
    @Published private(set) var filterData = [FavoriteItems]()
    private var query = ""
    
    func load() {
        arrData = FavoriteStore.shared.fetchAll()
        filterQuery(with: query)
    }
    
    func filterQuery(with text: String) {
        query = text.trimmingCharacters(in: .whitespaces)
        filterData = query.isEmpty
        ? arrData : arrData.filter {$0.title.localizedStandardContains(query)}
    }
    
    func remove(at index: Int) {
        let item = filterData[index]
        FavoriteStore.shared.remove(item.id)
        load()
    }
    
}
