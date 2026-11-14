//
//  ShowMoreNowPlaying.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 28/10/2026.
//

import UIKit
import Combine

@MainActor
class ShowMoreNowPlaying: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let viewModel = ViewModelNowPlayingMovies()
    private var arrData = [Movie]()
    private var currentTask: Task<Void, Never>?
    private var isLoad = false
    private var cancelLabel = Set<AnyCancellable>()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        started()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !isLoad else {return}
        isLoad = true
        currentTask = Task{ [weak self] in
            await self?.viewModel.loadingData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentTask?.cancel()
    }
    
    private func started() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        binding()
        searchBar()
    }
    
    private func binding() {
        viewModel.$filterData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] arr in
                self?.arrData = arr
                self?.collectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        // show alert
        viewModel.$message
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] error in
                if let error = error {
                    self?.showAlert(error)
                }
            }
            .store(in: &cancelLabel)
        
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
}

// Mark: - CollectionView
extension ShowMoreNowPlaying: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = arrData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showmorenowplaying", for: indexPath) as! NowPlayingMovies
        cell.setUP(items: items)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width * 0.3, height: view.frame.width * 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let items = viewModel.indexPath(at: indexPath.row)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "homeselected") as? HomeSeleted {
            vc.showData = items
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        Task { [weak self] in
            await self?.viewModel.fetchedIfNeeded(indexPath.row)
        }
    }
    
}

// Mark: - Search Controller
extension ShowMoreNowPlaying: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.filterQuery(with: query)
    }
    
    private func searchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        definesPresentationContext = true
    }
    
    
}
