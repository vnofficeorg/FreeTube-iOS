import Foundation

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case allInstancesFailed
    case noStreamURL
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError(let err): return "Decoding error: \(err.localizedDescription)"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .allInstancesFailed: return "All Invidious instances failed. Try again later."
        case .noStreamURL: return "No playable stream found"
        }
    }
}

// MARK: - Invidious API Client
class InvidiousAPI {
    
    static let shared = InvidiousAPI()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    /// Current active instance URL
    var currentInstanceURL: String {
        get {
            if let saved = UserDefaults.standard.string(forKey: "currentInstance") {
                return saved
            }
            return InvidiousInstance.defaultInstances.first?.url ?? "https://yewtu.be"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentInstance")
        }
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }
    
    // MARK: - Trending Videos
    func fetchTrending(region: String = "US", completion: @escaping (Result<[TrendingVideo], APIError>) -> Void) {
        let urlString = "\(currentInstanceURL)/api/v1/trending?region=\(region)&hl=vi"
        request(urlString: urlString, completion: completion)
    }
    
    // MARK: - Popular Videos
    func fetchPopular(completion: @escaping (Result<[TrendingVideo], APIError>) -> Void) {
        let urlString = "\(currentInstanceURL)/api/v1/popular"
        request(urlString: urlString, completion: completion)
    }
    
    // MARK: - Video Detail (includes related videos + stream URLs)
    func fetchVideoDetail(videoId: String, completion: @escaping (Result<VideoDetail, APIError>) -> Void) {
        let urlString = "\(currentInstanceURL)/api/v1/videos/\(videoId)?hl=vi&local=true"
        request(urlString: urlString, completion: completion)
    }
    
    // MARK: - Search
    func search(query: String, page: Int = 1, completion: @escaping (Result<[SearchResult], APIError>) -> Void) {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.invalidURL))
            return
        }
        let urlString = "\(currentInstanceURL)/api/v1/search?q=\(encoded)&page=\(page)&hl=vi"
        request(urlString: urlString, completion: completion)
    }
    
    // MARK: - Proxy thumbnail URL through instance
    func proxyThumbnailURL(originalURL: String) -> String {
        // Invidious already serves proxied thumbnails via its own domain
        if originalURL.hasPrefix("/") {
            return "\(currentInstanceURL)\(originalURL)"
        }
        return originalURL
    }
    
    // MARK: - Try different instance if current fails
    func tryNextInstance() -> Bool {
        let instances = InvidiousInstance.defaultInstances
        guard let currentIndex = instances.firstIndex(where: { $0.url == currentInstanceURL }) else {
            if let first = instances.first {
                currentInstanceURL = first.url
                return true
            }
            return false
        }
        let nextIndex = instances.index(after: currentIndex)
        if nextIndex < instances.endIndex {
            currentInstanceURL = instances[nextIndex].url
            return true
        }
        return false
    }
    
    // MARK: - Generic Request
    private func request<T: Decodable>(urlString: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.networkError(error)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let decoded = try self.decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch with automatic fallback
    func fetchTrendingWithFallback(completion: @escaping (Result<[TrendingVideo], APIError>) -> Void) {
        fetchTrending { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                // Try next instance
                if self?.tryNextInstance() == true {
                    self?.fetchTrending(completion: completion)
                } else {
                    completion(.failure(.allInstancesFailed))
                }
            }
        }
    }
}
