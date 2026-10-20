//
//  Library.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 13/08/2026.
//

import UIKit
import Combine

class Library: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var NotDataYetImage: UIImageView!
    @IBOutlet weak var NotDataYetLabel: UILabel!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var favData = [FavoriteItems]()
    private let viewModel = ViewModelLibrary()
    private var currentTask: Task<Void, Never>?
    private var cancelLabel = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        startUp()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.load()
    }
    
    private func startUp() {
        tableView.delegate = self
        tableView.dataSource = self
        
        binding()
        searchBar()
        
    }
    
    func binding() {
        viewModel.$filterData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self = self else {return}
                let isEmpty = item.isEmpty
                self.tableView.isHidden = isEmpty
                self.NotDataYetLabel.isHidden = !isEmpty
                self.NotDataYetImage.isHidden = !isEmpty
                self.tableView.reloadData()
            }
            .store(in: &cancelLabel)
    }
    
    
}

extension Library: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let items = viewModel.filterData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "favImg", for: indexPath) as! FavoriteTableViewCell
        cell.setUp(items)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        favData.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, code in
            self.viewModel.remove(at: indexPath.row)
            code(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        
        let items = viewModel.filterData[indexPath.row]
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "homeselected") as? HomeSeleted {
            vc.showData = items.asMovie
            vc.saveCast = items.cast
            vc.saveDirector = items.director
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
}


// Mark: - UISearch Controller

extension Library: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.filterQuery(with: query)
    }
    
    private func searchBar() {
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search..."
        definesPresentationContext = true
    }
    
}
