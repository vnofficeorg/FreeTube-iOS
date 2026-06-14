import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    // MARK: - Properties
    private let videoId: String
    private var videoDetail: VideoDetail?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var relatedPanel: RelatedVideosPanel?
    private var isPanelShowing = false
    private var isControlsVisible = true
    private var controlsTimer: Timer?
    
    // MARK: - UI Elements
    private let playerContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.hidesWhenStopped = true
        return ai
    }()
    
    // Custom controls overlay
    private let controlsOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return v
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("✕", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    private let playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("⏸", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 40)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(white: 0.7, alpha: 1.0)
        return label
    }()
    
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        slider.maximumTrackTintColor = UIColor(white: 0.3, alpha: 1.0)
        slider.thumbTintColor = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)
        return slider
    }()
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.text = "0:00"
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.text = "0:00"
        return label
    }()
    
    // Swipe hint
    private let swipeHintView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        v.layer.cornerRadius = 2.5
        return v
    }()
    
    private let swipeHintLabel: UILabel = {
        let label = UILabel()
        label.text = "↑ Vuốt lên để xem video liên quan"
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(white: 0.6, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()
    
    private var timeObserver: Any?
    
    // MARK: - Init
    init(videoId: String) {
        self.videoId = videoId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        loadVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        // Player container
        view.addSubview(playerContainerView)
        playerContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // Loading indicator
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        // Controls overlay
        view.addSubview(controlsOverlay)
        controlsOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlsOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            controlsOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // Close button
        controlsOverlay.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: controlsOverlay.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: controlsOverlay.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        // Title
        controlsOverlay.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: controlsOverlay.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: controlsOverlay.trailingAnchor, constant: -16),
        ])
        
        // Author
        controlsOverlay.addSubview(authorLabel)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
        
        // Play/Pause
        controlsOverlay.addSubview(playPauseButton)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: controlsOverlay.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsOverlay.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 70),
            playPauseButton.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        // Progress slider
        controlsOverlay.addSubview(progressSlider)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        
        // Time labels
        controlsOverlay.addSubview(currentTimeLabel)
        controlsOverlay.addSubview(durationLabel)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: controlsOverlay.leadingAnchor, constant: 16),
            currentTimeLabel.bottomAnchor.constraint(equalTo: controlsOverlay.bottomAnchor, constant: -50),
            
            durationLabel.trailingAnchor.constraint(equalTo: controlsOverlay.trailingAnchor, constant: -16),
            durationLabel.bottomAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor),
            
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 8),
            progressSlider.trailingAnchor.constraint(equalTo: durationLabel.leadingAnchor, constant: -8),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor),
        ])
        
        // Swipe hint
        controlsOverlay.addSubview(swipeHintView)
        controlsOverlay.addSubview(swipeHintLabel)
        swipeHintView.translatesAutoresizingMaskIntoConstraints = false
        swipeHintLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            swipeHintView.centerXAnchor.constraint(equalTo: controlsOverlay.centerXAnchor),
            swipeHintView.bottomAnchor.constraint(equalTo: controlsOverlay.bottomAnchor, constant: -16),
            swipeHintView.widthAnchor.constraint(equalToConstant: 40),
            swipeHintView.heightAnchor.constraint(equalToConstant: 5),
            
            swipeHintLabel.centerXAnchor.constraint(equalTo: controlsOverlay.centerXAnchor),
            swipeHintLabel.bottomAnchor.constraint(equalTo: swipeHintView.topAnchor, constant: -4),
        ])
        
        // Start auto-hide timer
        resetControlsTimer()
    }
    
    // MARK: - Gestures
    private func setupGestures() {
        // Tap to toggle controls
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        // Pan (swipe) gesture for related videos
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        tapGesture.require(toFail: panGesture)
    }
    
    @objc private func handleTap() {
        toggleControls()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // Only respond to upward swipe from bottom portion of screen
            let touchPoint = gesture.location(in: view)
            if touchPoint.y > view.bounds.height * 0.5 && translation.y < -30 {
                // Start showing panel preview
                if relatedPanel == nil {
                    createRelatedPanel()
                }
            }
            
        case .ended:
            // If swiped up fast enough or far enough, show panel
            if velocity.y < -300 || translation.y < -100 {
                showRelatedPanel()
            }
            
        default:
            break
        }
    }
    
    // MARK: - Related Videos Panel
    private func createRelatedPanel() {
        guard relatedPanel == nil, let videos = videoDetail?.recommendedVideos, !videos.isEmpty else { return }
        
        let panel = RelatedVideosPanel(videos: videos)
        panel.delegate = self
        panel.frame = CGRect(
            x: 0,
            y: view.bounds.height,
            width: view.bounds.width,
            height: view.bounds.height * 0.65
        )
        view.addSubview(panel)
        relatedPanel = panel
    }
    
    private func showRelatedPanel() {
        if relatedPanel == nil {
            createRelatedPanel()
        }
        
        guard let panel = relatedPanel else { return }
        isPanelShowing = true
        
        // Hide controls
        controlsOverlay.isHidden = true
        
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            panel.frame.origin.y = self.view.bounds.height * 0.35
        })
    }
    
    func hideRelatedPanel() {
        guard let panel = relatedPanel else { return }
        isPanelShowing = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            panel.frame.origin.y = self.view.bounds.height
        }) { _ in
            panel.removeFromSuperview()
            self.relatedPanel = nil
            self.controlsOverlay.isHidden = false
        }
    }
    
    // MARK: - Controls
    private func toggleControls() {
        if isPanelShowing {
            hideRelatedPanel()
            return
        }
        
        isControlsVisible.toggle()
        
        UIView.animate(withDuration: 0.25) {
            self.controlsOverlay.alpha = self.isControlsVisible ? 1.0 : 0.0
        }
        
        if isControlsVisible {
            resetControlsTimer()
        }
    }
    
    private func resetControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
            guard let self = self, self.isControlsVisible, self.player?.rate != 0 else { return }
            self.isControlsVisible = false
            UIView.animate(withDuration: 0.3) {
                self.controlsOverlay.alpha = 0.0
            }
        }
    }
    
    // MARK: - Player Controls Actions
    @objc private func closeTapped() {
        player?.pause()
        dismiss(animated: true)
    }
    
    @objc private func playPauseTapped() {
        guard let player = player else { return }
        if player.rate == 0 {
            player.play()
            playPauseButton.setTitle("⏸", for: .normal)
        } else {
            player.pause()
            playPauseButton.setTitle("▶️", for: .normal)
        }
        resetControlsTimer()
    }
    
    @objc private func sliderValueChanged() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard totalSeconds.isFinite else { return }
        let seekTime = CMTime(seconds: Double(progressSlider.value) * totalSeconds, preferredTimescale: 600)
        currentTimeLabel.text = formatTime(seconds: CMTimeGetSeconds(seekTime))
    }
    
    @objc private func sliderTouchDown() {
        controlsTimer?.invalidate()
    }
    
    @objc private func sliderTouchUp() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        guard totalSeconds.isFinite else { return }
        let seekTime = CMTime(seconds: Double(progressSlider.value) * totalSeconds, preferredTimescale: 600)
        player?.seek(to: seekTime)
        resetControlsTimer()
    }
    
    // MARK: - Load Video
    private func loadVideo() {
        activityIndicator.startAnimating()
        
        InvidiousAPI.shared.fetchVideoDetail(videoId: videoId) { [weak self] result in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success(let detail):
                self.videoDetail = detail
                self.titleLabel.text = detail.title
                self.authorLabel.text = detail.author ?? ""
                self.startPlayback(detail: detail)
                
                // Save to history
                HistoryManager.shared.addToHistory(
                    videoId: detail.videoId,
                    title: detail.title,
                    author: detail.author,
                    thumbnailURL: detail.bestThumbnailURL,
                    duration: detail.lengthSeconds
                )
                
            case .failure(let error):
                self.showError(error.localizedDescription)
            }
        }
    }
    
    private func startPlayback(detail: VideoDetail) {
        // Try HLS first (best for iOS), then format streams
        var streamURLString: String?
        
        if let hls = detail.hlsStreamURL {
            streamURLString = hls
        } else if let stream = detail.bestStreamURL {
            streamURLString = stream
        }
        
        // If URL starts with /, prepend instance URL
        if let urlStr = streamURLString, urlStr.hasPrefix("/") {
            streamURLString = "\(InvidiousAPI.shared.currentInstanceURL)\(urlStr)"
        }
        
        guard let urlString = streamURLString, let url = URL(string: urlString) else {
            showError("Không tìm thấy stream video")
            return
        }
        
        // Setup AVPlayer
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.frame = playerContainerView.bounds
        playerContainerView.layer.addSublayer(layer)
        playerLayer = layer
        
        player?.play()
        playPauseButton.setTitle("⏸", for: .normal)
        
        // Update duration label
        if let seconds = detail.lengthSeconds {
            durationLabel.text = formatTime(seconds: Double(seconds))
        }
        
        // Observe playback progress
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self, let duration = self.player?.currentItem?.duration else { return }
            let currentSeconds = CMTimeGetSeconds(time)
            let totalSeconds = CMTimeGetSeconds(duration)
            
            guard currentSeconds.isFinite, totalSeconds.isFinite, totalSeconds > 0 else { return }
            
            if !self.progressSlider.isTracking {
                self.progressSlider.value = Float(currentSeconds / totalSeconds)
                self.currentTimeLabel.text = self.formatTime(seconds: currentSeconds)
            }
        }
        
        // Observe end of video
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    @objc private func playerDidFinish() {
        playPauseButton.setTitle("▶️", for: .normal)
        // Auto-show related videos
        showRelatedPanel()
    }
    
    // MARK: - Helpers
    private func formatTime(seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Lỗi", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Thử instance khác", style: .default) { [weak self] _ in
            _ = InvidiousAPI.shared.tryNextInstance()
            self?.loadVideo()
        })
        present(alert, animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension PlayerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - RelatedVideosPanelDelegate
extension PlayerViewController: RelatedVideosPanelDelegate {
    func didSelectVideo(videoId: String) {
        // Clean up current player
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        playerLayer?.removeFromSuperlayer()
        player = nil
        
        // Hide panel
        hideRelatedPanel()
        
        // Reset UI
        progressSlider.value = 0
        currentTimeLabel.text = "0:00"
        
        // Load new video
        // Update videoId is not possible since it's let, so we dismiss and present new
        let newPlayer = PlayerViewController(videoId: videoId)
        newPlayer.modalPresentationStyle = .fullScreen
        
        // Present from parent
        if let presenting = self.presentingViewController {
            dismiss(animated: false) {
                presenting.present(newPlayer, animated: true)
            }
        }
    }
    
    func didRequestDismissPanel() {
        hideRelatedPanel()
    }
}
