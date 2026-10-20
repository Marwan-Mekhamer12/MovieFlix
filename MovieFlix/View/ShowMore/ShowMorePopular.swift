//
//  ShowMorePopular.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 13/08/2026.
//

import UIKit
import Combine

@MainActor
class ShowMorePopular: UIViewController {
    
    @IBOutlet weak var showMorePopularCollectionView: UICollectionView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var arrData = [Movie]()
    private var currentTask: Task<Void, Never>?
    private var viewModel = ViewModelPopularMovies()
    private var cancelLabel = Set<AnyCancellable>()
    private var hasLoading = false
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        started()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !hasLoading else {return}
        hasLoading = true
        currentTask = Task { [weak self] in
            await self?.viewModel.loadingData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentTask?.cancel()
    }
    
    private func started() {
        showMorePopularCollectionView.delegate = self
        showMorePopularCollectionView.dataSource = self
        bindingShowMorePopular()
        searrchBar()
        
    }
    
    private func bindingShowMorePopular() {
        
        viewModel.$filterData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.arrData = data
                self?.showMorePopularCollectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        
        viewModel.$messageError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error{
                    self?.showAlert(error)
                }
            }
            .store(in: &cancelLabel)
        
    }
    
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
}

// Mark: - Collection View

extension ShowMorePopular: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = arrData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "showallpopularcell", for: indexPath) as! HomePopularCVCell
        cell.setUp(items)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.3, height: self.view.frame.width * 0.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let items = viewModel.indexPath(at: indexPath.row)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "homeselected") as? HomeSeleted {
            vc.showData = items
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

// Mark: - Search Controller

extension ShowMorePopular: UISearchResultsUpdating {
    
     func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.filterquery(with: query)
    }
    
    private func searrchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        definesPresentationContext = true
    }
}
