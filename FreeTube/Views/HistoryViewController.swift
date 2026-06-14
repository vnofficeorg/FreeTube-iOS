import UIKit

class HistoryViewController: UIViewController {
    
    private var historyItems: [HistoryItem] = []
    
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
        return cv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Chưa có lịch sử xem"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lịch sử"
        view.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.1, alpha: 1.0)
        
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // Clear history button
        let clearButton = UIBarButtonItem(title: "Xóa", style: .plain, target: self, action: #selector(clearHistory))
        clearButton.tintColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        navigationItem.rightBarButtonItem = clearButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        historyItems = HistoryManager.shared.history
        collectionView.reloadData()
        emptyLabel.isHidden = !historyItems.isEmpty
    }
    
    @objc private func clearHistory() {
        let alert = UIAlertController(title: "Xóa lịch sử", message: "Bạn có chắc muốn xóa toàn bộ lịch sử xem?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            HistoryManager.shared.clearHistory()
            self?.historyItems = []
            self?.collectionView.reloadData()
            self?.emptyLabel.isHidden = false
        })
        present(alert, animated: true)
    }
}

extension HistoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as! VideoCell
        cell.configureHistory(with: historyItems[indexPath.item])
        return cell
    }
}

extension HistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = historyItems[indexPath.item]
        let playerVC = PlayerViewController(videoId: item.videoId)
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
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
