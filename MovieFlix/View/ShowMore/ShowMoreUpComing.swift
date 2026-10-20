//
//  ShowMoreUpComing.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 20/08/2026.
//

import UIKit
import Combine

@MainActor
class ShowMoreUpComing: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let viewModel = ViewModelUpComing()
    private var arrData = [Movie]()
    private var currentTask: Task<Void, Never>?
    private var hasLoad = false
    private var cancelLabel = Set<AnyCancellable>()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        started()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !hasLoad else {return}
        hasLoad = true
        currentTask = Task { [weak self] in
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
        bindingAllUpComing()
        searchBar()
        
        
    }
    
    private func bindingAllUpComing() {
        viewModel.$filterData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alldata in
                self?.arrData = alldata
                self?.collectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        
        viewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(error)
                }
                return
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

extension ShowMoreUpComing: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = arrData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingmorecell", for: indexPath) as! UpCamingHomeCell
        cell.setUp(items: items)
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
}

// Mark: - SearchController

extension ShowMoreUpComing: UISearchResultsUpdating {
    
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
