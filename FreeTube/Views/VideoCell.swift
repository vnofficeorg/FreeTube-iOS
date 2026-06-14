import UIKit

class VideoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "VideoCell"
    
    // MARK: - UI Elements
    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        iv.layer.cornerRadius = 8
        return iv
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        label.textAlignment = .center
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.numberOfLines = 1
        return label
    }()
    
    private let viewsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(white: 0.5, alpha: 1.0)
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(durationLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(viewsLabel)
        
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        viewsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 9.0/16.0),
            
            durationLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: -6),
            durationLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -6),
            durationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 35),
            durationLabel.heightAnchor.constraint(equalToConstant: 18),
            
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            viewsLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            viewsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            viewsLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    // MARK: - Configure with Trending Video
    func configure(with video: TrendingVideo) {
        titleLabel.text = video.title
        authorLabel.text = video.author ?? ""
        durationLabel.text = " \(video.formattedDuration) "
        viewsLabel.text = "\(video.formattedViewCount) • \(video.publishedText ?? "")"
        thumbnailImageView.loadImage(from: video.bestThumbnailURL)
    }
    
    // MARK: - Configure with Search Result
    func configureSearch(with result: SearchResult) {
        titleLabel.text = result.title ?? ""
        authorLabel.text = result.author ?? ""
        durationLabel.text = " \(result.formattedDuration) "
        viewsLabel.text = result.publishedText ?? ""
        thumbnailImageView.loadImage(from: result.bestThumbnailURL)
    }
    
    // MARK: - Configure with Recommended Video
    func configureRecommended(with video: RecommendedVideo) {
        titleLabel.text = video.title
        authorLabel.text = video.author ?? ""
        
        if let seconds = video.lengthSeconds {
            let mins = seconds / 60
            let secs = seconds % 60
            durationLabel.text = " \(String(format: "%d:%02d", mins, secs)) "
        } else {
            durationLabel.text = ""
        }
        
        viewsLabel.text = video.viewCountText ?? ""
        
        let thumbURL = video.videoThumbnails?.first(where: { $0.quality == "medium" })?.url
            ?? video.videoThumbnails?.first?.url
        thumbnailImageView.loadImage(from: thumbURL)
    }
    
    // MARK: - Configure with History Item
    func configureHistory(with item: HistoryItem) {
        titleLabel.text = item.title
        authorLabel.text = item.author ?? ""
        
        if let seconds = item.duration {
            let mins = seconds / 60
            let secs = seconds % 60
            durationLabel.text = " \(String(format: "%d:%02d", mins, secs)) "
        } else {
            durationLabel.text = ""
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        viewsLabel.text = formatter.string(for: item.watchedAt) ?? ""
        
        thumbnailImageView.loadImage(from: item.thumbnailURL)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        durationLabel.text = nil
        viewsLabel.text = nil
    }
}
