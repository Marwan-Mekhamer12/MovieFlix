//
//  ViewController.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 31/07/2026.
//

// Api Key: 264a0a68c3b6f9c46619b41fa7be1394

import UIKit
import Combine


@MainActor
class Home: UIViewController {
    
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var topRatedCollectionView: UICollectionView!
    @IBOutlet weak var upComingCollectionView: UICollectionView!
    
    
    // Popular
    private var arrDataPopularMovie = [Movie]()
    private var disPlayDataPopularMovie: [Movie] {
        Array(arrDataPopularMovie.prefix(7))
    }
    
    // Top Rated
    private var arrDataTopRated = [Movie]()
    private var displayDataTopRatedMovie: [Movie] {
        Array(arrDataTopRated.prefix(7))
    }
    
    // Up Caming
    private var arrDataUpComing = [Movie]()
    private var displayUpComing: [Movie] {
        Array(arrDataUpComing.prefix(7))
    }
    
    private let viewModelPopular = ViewModelPopularMovies()  // Popular
    private let viewModelTopRated = ViewModelTopRated()  // Top Rated
    private let viewModelUpComing = ViewModelUpComing() // Up Coming
    private var cancelLabel = Set<AnyCancellable>()  // Cancel Label
    private var currentTask: Task<Void, Never>?  // Current Task
    private var hasLoadData = false  // has load data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        started()
        
        //        Task {
        //            let response: MovieResponse = try await ApiManager.shared.fetchData(from: .popularMovies(page: 1))
        //            print("\(response.results.first?.title ?? "None! Marwan")")
        //        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !hasLoadData else {return}
        hasLoadData = true
        currentTask = Task { [weak self] in
            await self?.viewModelPopular.loadingData()
            await self?.viewModelTopRated.loadingData()
            await self?.viewModelUpComing.loadingData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentTask?.cancel()
    }
    
    func started() {
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        
        topRatedCollectionView.delegate = self
        topRatedCollectionView.dataSource = self
        
        upComingCollectionView.delegate = self
        upComingCollectionView.dataSource = self
        
        bindingPoplular() // Popular
        bindingTopTated() // Top Rated
        bindeingUpComing()
    }
    
    // Bindeing For Popular CollectionView
    private func bindingPoplular() {
        
        // View Model Popular
        viewModelPopular.$arrData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] popData in
                self?.arrDataPopularMovie = popData
                self?.popularCollectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        // show Alert Popular
        viewModelPopular.$messageError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error)
                }
            }
            .store(in: &cancelLabel)
    }
    
    // Binding For Top Rated CollectionView
    private func bindingTopTated() {
        
        // View Model Top Rated
        viewModelTopRated.$arrDataTopRated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] topdata in
                self?.arrDataTopRated = topdata
                self?.topRatedCollectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        // Show Alert Top Rated
        viewModelTopRated.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error)
                }
            }
            .store(in: &cancelLabel)
    }
    
    // Binding For Up Coming CollectionView
    private func bindeingUpComing() {
        
        // View Model Up Coming
        viewModelUpComing.$arrData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] arrdata in
                self?.arrDataUpComing = arrdata
                self?.upComingCollectionView.reloadData()
            }
            .store(in: &cancelLabel)
        
        
        // Show Alert Up Coming
        viewModelUpComing.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error)
                }
            }
            .store(in: &cancelLabel)
    }
    
    // Show Alert
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    // Action for show all Popular Data
    @IBAction func morePopular(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showmorepopular") as? ShowMorePopular {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Action for show all Top Rated Data
    @IBAction func moreTopRated(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showmoretoprated") as? ShowMoreTopRated {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // Action for show all Up Coming Data
    @IBAction func moreUpComing(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showmoreupcoming") as? ShowMoreUpComing {
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}

// Collection View Functions
extension Home: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == popularCollectionView{
            return disPlayDataPopularMovie.count
        } else if collectionView == topRatedCollectionView {
            return displayDataTopRatedMovie.count
        } else if collectionView == upComingCollectionView {
            return displayUpComing.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == popularCollectionView {
            let itemsPop = disPlayDataPopularMovie[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popluarcell", for: indexPath) as? HomePopularCVCell else {return UICollectionViewCell()}
            cell.setUp(itemsPop)
            return cell
        }
        
        else if collectionView == topRatedCollectionView {
            let itemsTopRated = displayDataTopRatedMovie[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topratedcell", for: indexPath) as? TopRatedHomeSelected else {return UICollectionViewCell()}
            cell.setUp(itemsTopRated)
            return cell
        }
        
        else if collectionView == upComingCollectionView {
            let itemsUpComing = displayUpComing[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcominghomecell", for: indexPath) as? UpCamingHomeCell else {return UICollectionViewCell()}
            cell.setUp(items: itemsUpComing)
            return cell
        }
        return UICollectionViewCell()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "homeselected") as? HomeSeleted else {return}
        
        if collectionView == popularCollectionView {
            vc.showData = disPlayDataPopularMovie[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == topRatedCollectionView {
            vc.showData = displayDataTopRatedMovie[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        } else if collectionView == upComingCollectionView {
            vc.showData = displayUpComing[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
