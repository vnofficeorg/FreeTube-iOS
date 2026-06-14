import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    private var activeTasks: [String: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "com.freetube.imagecache")
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return
        }
        
        // Proxy through Invidious if needed
        let finalURL = InvidiousAPI.shared.proxyThumbnailURL(originalURL: urlString)
        
        guard let url = URL(string: finalURL) else {
            completion(nil)
            return
        }
        
        // Cancel existing task for same URL
        queue.sync {
            activeTasks[urlString]?.cancel()
        }
        
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // Cache the image
            self.cache.setObject(image, forKey: urlString as NSString)
            
            self.queue.sync {
                self.activeTasks.removeValue(forKey: urlString)
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        queue.sync {
            activeTasks[urlString] = task
        }
        
        task.resume()
    }
    
    func cancelLoad(for urlString: String) {
        queue.sync {
            activeTasks[urlString]?.cancel()
            activeTasks.removeValue(forKey: urlString)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - UIImageView Extension
extension UIImageView {
    private static var urlKey: UInt8 = 0
    
    private var currentURL: String? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? String }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        // Cancel previous load
        if let prev = currentURL {
            ImageCache.shared.cancelLoad(for: prev)
        }
        
        image = placeholder
        
        guard let urlString = urlString else { return }
        currentURL = urlString
        
        ImageCache.shared.loadImage(from: urlString) { [weak self] img in
            guard let self = self, self.currentURL == urlString else { return }
            if let img = img {
                UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.image = img
                }, completion: nil)
            }
        }
    }
}
