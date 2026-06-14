import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private var videos: [TrendingVideo] = []
    private var isLoading = false
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        cv.delegate = self
        cv.dataSource = self
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let retryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Thử lại", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        btn.layer.cornerRadius = 8
        btn.isHidden = true
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTrending()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "FreeTube"
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        
        // Collection view
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // Pull to refresh
        refreshControl.tintColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        
        // Loading indicator
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // Error label
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
        
        // Retry button
        view.addSubview(retryButton)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        // Instance info in nav bar
        let instanceButton = UIBarButtonItem(title: "🔗", style: .plain, target: self, action: #selector(showInstanceInfo))
        navigationItem.rightBarButtonItem = instanceButton
    }
    
    // MARK: - Data Loading
    private func loadTrending() {
        guard !isLoading else { return }
        isLoading = true
        
        errorLabel.isHidden = true
        retryButton.isHidden = true
        
        if videos.isEmpty {
            activityIndicator.startAnimating()
        }
        
        InvidiousAPI.shared.fetchTrendingWithFallback { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let videos):
                self.videos = videos
                self.collectionView.reloadData()
                self.errorLabel.isHidden = true
                self.retryButton.isHidden = true
            case .failure(let error):
                if self.videos.isEmpty {
                    self.errorLabel.text = "Không thể tải video\n\(error.localizedDescription)"
                    self.errorLabel.isHidden = false
                    self.retryButton.isHidden = false
                }
            }
        }
    }
    
    @objc private func refreshData() {
        loadTrending()
    }
    
    @objc private func retryTapped() {
        // Try next instance then reload
        _ = InvidiousAPI.shared.tryNextInstance()
        loadTrending()
    }
    
    @objc private func showInstanceInfo() {
        let alert = UIAlertController(
            title: "Instance hiện tại",
            message: InvidiousAPI.shared.currentInstanceURL,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as! VideoCell
        cell.configure(with: videos[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.item]
        let playerVC = PlayerViewController(videoId: video.videoId)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        
        // 2 columns on iPad, 1 on iPhone
        let columns: CGFloat = view.frame.width > 600 ? 2 : 1
        let width = (collectionView.bounds.width - totalSpacing * columns) / columns
        let thumbnailHeight = width * 9.0 / 16.0
        let textHeight: CGFloat = 75
        return CGSize(width: width, height: thumbnailHeight + textHeight)
    }
}
