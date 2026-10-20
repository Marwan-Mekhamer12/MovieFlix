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
    
    
    @IBOutlet weak var firstViewCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    @IBOutlet weak var topRatedCollectionView: UICollectionView!
    @IBOutlet weak var upComingCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    
    // firstView
    private var arrDataFirstView = [Movie]()
    private var displayfirstView: [Movie] {
        Array(arrDataFirstView.prefix(10))
    }
    
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
    
    // page control
    private var currentIndex = 0
    private var timer: Timer?
    
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
        
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
        timer?.invalidate()
    }
    
    func started() {
        
        firstViewCollectionView.delegate = self
        firstViewCollectionView.dataSource = self
        firstViewCollectionView.isPagingEnabled = true
        pageControl.numberOfPages = 0
        pageControl.currentPage = 0
        
        popularCollectionView.delegate = self
        popularCollectionView.dataSource = self
        
        topRatedCollectionView.delegate = self
        topRatedCollectionView.dataSource = self
        
        upComingCollectionView.delegate = self
        upComingCollectionView.dataSource = self
        
        bindingPoplular() // Popular
        bindingTopRated() // Top Rated
        bindeingUpComing() // Up Coming
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
    private func bindingTopRated() {
        
        // View Model Top Rated
        viewModelTopRated.$arrDataTopRated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] topdata in
                self?.arrDataTopRated = topdata
                self?.arrDataFirstView = topdata
                self?.topRatedCollectionView.reloadData()
                self?.firstViewCollectionView.reloadData()
                self?.currentIndex = 0
                self?.pageControl.numberOfPages = self?.displayfirstView.count ?? 0
                self?.pageControl.currentPage = 0
                self?.startTimer()
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

// Mark: - Collection View Functions
extension Home: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstViewCollectionView{
            return displayfirstView.count
        }else if collectionView == popularCollectionView{
            return disPlayDataPopularMovie.count
        } else if collectionView == topRatedCollectionView {
            return displayDataTopRatedMovie.count
        } else if collectionView == upComingCollectionView {
            return displayUpComing.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == firstViewCollectionView {
            let itemfirstView = displayfirstView[indexPath.row]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "firstview", for: indexPath) as? TopRatedHomeSelected else {return UICollectionViewCell()}
            cell.setUp(itemfirstView)
            return cell
        }
        
        else if collectionView == popularCollectionView {
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
        return collectionView == firstViewCollectionView ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == firstViewCollectionView {
            return collectionView.bounds.size
        }
        return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? CGSize(width: 120, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "homeselected") as? HomeSeleted else {return}
        
        if collectionView == firstViewCollectionView {
            vc.showData = displayfirstView[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
        else if collectionView == popularCollectionView {
            vc.showData = disPlayDataPopularMovie[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
        else if collectionView == topRatedCollectionView {
            vc.showData = displayDataTopRatedMovie[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
        else if collectionView == upComingCollectionView {
            vc.showData = displayUpComing[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}


// Mark: - Page Control

extension Home {
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self,
                                     selector: #selector(nextTimer),
                                     userInfo: nil, repeats: true)
    }
    
    @objc
    private func nextTimer() {
        let count = displayfirstView.count
        if count < 2 { return }
        
        currentIndex = currentIndex + 1
        if currentIndex >= count { currentIndex = 0 }
        
        firstViewCollectionView.scrollToItem(at: IndexPath(item: currentIndex, section: 0),
                                             at: .centeredHorizontally,
                                             animated: true)
        pageControl.currentPage = currentIndex
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView === firstViewCollectionView else { return }
        timer?.invalidate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === firstViewCollectionView, !decelerate else { return }
        syncPage(scrollView)
        startTimer()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === firstViewCollectionView else { return }
        syncPage(scrollView)
        startTimer()
    }
    
    private func syncPage(_ scrollView: UIScrollView) {
        guard scrollView.bounds.width > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        currentIndex = page
        pageControl.currentPage = page
    }
}
