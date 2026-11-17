//
//  ViewModelProtocol.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 16/11/2026.
//

import Foundation

protocol ViewModelProtocol {
    func loadingData() async
    func fetchedIfNeeded(_ currentIndex: Int) async
    func fetchNextPage() async
}
