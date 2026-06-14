import Foundation

struct HistoryItem: Codable {
    let videoId: String
    let title: String
    let author: String?
    let thumbnailURL: String?
    let duration: Int?
    let watchedAt: Date
}

class HistoryManager {
    static let shared = HistoryManager()
    
    private let key = "watchHistory"
    private let maxItems = 200
    
    private init() {}
    
    var history: [HistoryItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func addToHistory(videoId: String, title: String, author: String?, thumbnailURL: String?, duration: Int?) {
        var items = history
        
        // Remove existing entry for same video
        items.removeAll { $0.videoId == videoId }
        
        // Add to beginning
        let item = HistoryItem(
            videoId: videoId,
            title: title,
            author: author,
            thumbnailURL: thumbnailURL,
            duration: duration,
            watchedAt: Date()
        )
        items.insert(item, at: 0)
        
        // Limit size
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        
        // Save
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
