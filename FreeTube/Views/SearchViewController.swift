import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    private var results: [SearchResult] = []
    private var searchTimer: Timer?
    private var currentQuery: String = ""
    private var currentPage: Int = 1
    private var isLoading = false
    
    // MARK: - UI Elements
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Tìm kiếm video..."
        sb.barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        sb.searchBarStyle = .minimal
        
        // Style text field
        if let textField = sb.value(forKey: "searchField") as? UITextField {
            textField.textColor = .white
            textField.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
            textField.attributedPlaceholder = NSAttributedString(
                string: "Tìm kiếm video...",
                attributes: [.foregroundColor: UIColor(white: 0.4, alpha: 1.0)]
            )
        }
        return sb
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 12, right: 12)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        cv.delegate = self
        cv.dataSource = self
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Nhập từ khóa để tìm video"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Tìm kiếm"
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        
        searchBar.delegate = self
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - Search
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            results = []
            collectionView.reloadData()
            emptyLabel.isHidden = false
            emptyLabel.text = "Nhập từ khóa để tìm video"
            return
        }
        
        isLoading = true
        emptyLabel.isHidden = true
        activityIndicator.startAnimating()
        currentQuery = query
        currentPage = 1
        
        InvidiousAPI.shared.search(query: query, page: 1) { [weak self] result in
            guard let self = self, self.currentQuery == query else { return }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let searchResults):
                self.results = searchResults.filter { $0.type == "video" }
                self.collectionView.reloadData()
                if self.results.isEmpty {
                    self.emptyLabel.text = "Không tìm thấy kết quả"
                    self.emptyLabel.isHidden = false
                }
            case .failure(let error):
                self.emptyLabel.text = "Lỗi: \(error.localizedDescription)"
                self.emptyLabel.isHidden = false
            }
        }
    }
    
    private func loadMoreResults() {
        guard !isLoading, !currentQuery.isEmpty else { return }
        isLoading = true
        currentPage += 1
        
        InvidiousAPI.shared.search(query: currentQuery, page: currentPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            if case .success(let searchResults) = result {
                let videoResults = searchResults.filter { $0.type == "video" }
                self.results.append(contentsOf: videoResults)
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            self?.performSearch(query: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            performSearch(query: text)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as! VideoCell
        cell.configureSearch(with: results[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let result = results[indexPath.item]
        guard let videoId = result.videoId else { return }
        let playerVC = PlayerViewController(videoId: videoId)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
    // Load more when scrolling near bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > contentHeight - height * 2 {
            loadMoreResults()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        let columns: CGFloat = view.frame.width > 600 ? 2 : 1
        let width = (collectionView.bounds.width - totalSpacing * columns) / columns
        let thumbnailHeight = width * 9.0 / 16.0
        let textHeight: CGFloat = 75
        return CGSize(width: width, height: thumbnailHeight + textHeight)
    }
}
