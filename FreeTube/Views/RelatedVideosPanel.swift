import UIKit

protocol RelatedVideosPanelDelegate: AnyObject {
    func didSelectVideo(videoId: String)
    func didRequestDismissPanel()
}

class RelatedVideosPanel: UIView {
    
    // MARK: - Properties
    weak var delegate: RelatedVideosPanelDelegate?
    private var videos: [RecommendedVideo]
    
    // MARK: - UI Elements
    private let handleBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        v.layer.cornerRadius = 2.5
        return v
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Video liên quan"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✕", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(UIColor(white: 0.6, alpha: 1.0), for: .normal)
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 8, left: 12, bottom: 20, right: 12)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseIdentifier)
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    // MARK: - Init
    init(videos: [RecommendedVideo]) {
        self.videos = videos
        super.init(frame: .zero)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Semi-transparent dark background with blur effect
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.13, alpha: 0.95)
        layer.cornerRadius = 16
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -4)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 10
        
        addSubview(handleBar)
        addSubview(headerLabel)
        addSubview(closeButton)
        addSubview(collectionView)
        
        handleBar.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.addTarget(self, action: #selector(dismissPanel), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            handleBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            headerLabel.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            closeButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Gestures
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        if gesture.state == .ended {
            // If swiped down, dismiss
            if velocity.y > 300 || translation.y > 80 {
                dismissPanel()
            }
        }
    }
    
    @objc private func dismissPanel() {
        delegate?.didRequestDismissPanel()
    }
}

// MARK: - UICollectionViewDataSource
extension RelatedVideosPanel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.reuseIdentifier, for: indexPath) as! VideoCell
        cell.configureRecommended(with: videos[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension RelatedVideosPanel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.item]
        delegate?.didSelectVideo(videoId: video.videoId)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RelatedVideosPanel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        let columns: CGFloat = bounds.width > 600 ? 3 : 2
        let width = (collectionView.bounds.width - totalSpacing * columns) / columns
        let thumbnailHeight = width * 9.0 / 16.0
        let textHeight: CGFloat = 70
        return CGSize(width: width, height: thumbnailHeight + textHeight)
    }
}
