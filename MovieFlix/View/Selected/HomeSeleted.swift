//
//  HomeSeleted.swift
//  MovieFlix
//
//  Created by Marwan Mekhamer on 15/08/2026.
//

import UIKit
import Combine
import SafariServices

@MainActor
class HomeSeleted: UIViewController {
    
    @IBOutlet weak var moviePosterImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startRatingView: StarRatingView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moreBtnDes: UIButton!
    @IBOutlet weak var TrailerShapeBtn: UIButton!
    @IBOutlet weak var directorNameLabel: UILabel!
    @IBOutlet weak var castNamesLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
    var saveCast: String?
    var saveDirector: String?
    
    private let viewModelDetails = ViewModelMovieDetail()
    private var arrData: MovieDetail?
    private var currentTask: Task<Void, Never>?
    private var cancelLabel = Set<AnyCancellable>()
    private var isDescriptionExpanded = false
    private var hasLoadData = false
    
    private var likeButton: UIBarButtonItem!
    
    var showData: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        started()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !hasLoadData else {return}
        hasLoadData = true
        currentTask = Task { [weak self] in
            if let movieID = self?.showData?.id {
                await self?.viewModelDetails.loadingData(movieId: movieID)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentTask?.cancel()
    }
    
    private func started() {
        
        bindeingMovieDetail()
        titleLabel.text = showData?.title
        descriptionLabel.text = showData?.overview
        descriptionLabel.numberOfLines = 2
        moreBtnDes.setTitle("see more", for: .normal)
        TrailerShapeBtn.layer.cornerRadius = 18
        tabBarFavoriteButton()
        
        if let cast = saveCast, !cast.isEmpty { castNamesLabel.text = cast }
        if let director = saveDirector, !director.isEmpty { directorNameLabel.text = director }
        
        currentTask = Task { [weak self] in
            await self?.loadImages()
        }
        
        startRatingView.setRating(showData?.voteaverage ?? 0)
        
    }
    
    private func tabBarFavoriteButton() {
        likeButton = UIBarButtonItem(image: UIImage(systemName: "heart"),
                                  style: .done, target: self,
                                  action: #selector(favoriteButton))
        likeButton.tintColor = .red
        navigationItem.rightBarButtonItem = likeButton
        updateHeartIcon()
    }
    
    @objc
    private func favoriteButton() {
        guard let movie = showData else { return }

        if FavoriteStore.shared.isFavorite(movie.id) {
            FavoriteStore.shared.remove(movie.id)
        } else {
            
            let cast = arrData?.credits.cast.prefix(15).map {$0.name}.joined(separator: ", ") ?? ""
            let director = arrData?.director?.name ?? ""
            
            FavoriteStore.shared.add(movie.id, movie.title, movie.voteaverage,
                                     movie.backdroppath, movie.overview, cast, director)
        }
        updateHeartIcon()
    }

    private func updateHeartIcon() {
        let liked = FavoriteStore.shared.isFavorite(showData?.id ?? 0)
        likeButton.image = UIImage(systemName: liked ? "heart.fill" : "heart")
    }
    
    private func bindeingMovieDetail() { // ✅ جديد - نادِها جوه started()
        viewModelDetails.$movieDetails
            .receive(on: DispatchQueue.main)
            .sink { detail in
                guard let detail else { return }
                self.arrData = detail
                self.directorNameLabel.text = detail.director?.name
                
                let castNames = detail.credits.cast.prefix(15).map {$0.name}
                self.castNamesLabel.text = castNames.isEmpty ? "N/A" : castNames.joined(separator: ", ")
                
                let genres = detail.genres.map {$0.name}
                self.genresLabel.text = genres.isEmpty ? "N/A G" : genres.joined(separator: ", ")
                
                print("Director: \(detail.director?.name ?? "N/A")")
                print("Cast count: \(detail.credits.cast.count)")
                print("Trailer: \(detail.trailer?.youtubeURL ?? "No trailer")")
                
            }
            .store(in: &cancelLabel)
        
        
        viewModelDetails.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.showAlert(message: error)
                }
            }
            .store(in: &cancelLabel)
    }
    
    
    private func loadImages() async {
        
        if Task.isCancelled {return}
        
        guard let imageURL = showData?.backdropURL, let url = URL(string: imageURL) else {return}
        if let cached = ImagesCache.shared.imagesObject(for: url.absoluteString) {
            moviePosterImg.image = cached
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled {return}
            if let image = UIImage(data: data) {
                ImagesCache.shared.imagesSetObject(image, for: url.absoluteString)
                self.moviePosterImg.image = image
            }
            
        } catch {
            print("Error from Home Selected VC to load Image: \(error.localizedDescription)")
            return
        }
        
    }
    
    @IBAction func pressedMoreDes(_ sender: UIButton) {
        
      
        isDescriptionExpanded.toggle()
        descriptionLabel.numberOfLines = isDescriptionExpanded ? 0 : 2
        descriptionLabel.invalidateIntrinsicContentSize()
        let title = isDescriptionExpanded ? "hide" : "show more"
        moreBtnDes.setTitle(title, for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func ThrillerButtonAction(_ sender: UIButton) {
        
        showAlertTrailer()
        
    }
    
    private func showAlertTrailer() {
        let alert = UIAlertController(title: "Open Video", message: "Are you sure you want open this link?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _ in
            guard let link = self?.arrData?.trailer?.youtubeURL, let url = URL(string: link) else {
                self?.showAlert(message: "Trailer not available yet.")
                return
            }
            let safarei = SFSafariViewController(url: url)
            self?.present(safarei, animated: true)
        }))
        present(alert, animated: true)
    }
    
    
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    
}

