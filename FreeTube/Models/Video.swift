import Foundation

// MARK: - Video Thumbnail
struct VideoThumbnail: Codable {
    let quality: String
    let url: String
    let width: Int
    let height: Int
}

// MARK: - Adaptive Format (Video/Audio streams)
struct AdaptiveFormat: Codable {
    let url: String?
    let itag: String?
    let type: String?
    let quality: String?
    let container: String?
    let encoding: String?
    let qualityLabel: String?
    let resolution: String?
    
    // Audio specific
    let audioQuality: String?
    let audioSampleRate: Int?
    let audioChannels: Int?
}

// MARK: - Format Info (combined streams)
struct FormatStream: Codable {
    let url: String?
    let itag: String?
    let type: String?
    let quality: String?
    let container: String?
    let qualityLabel: String?
    let resolution: String?
}

// MARK: - Recommended Video (from video detail response)
struct RecommendedVideo: Codable {
    let videoId: String
    let title: String
    let videoThumbnails: [VideoThumbnail]?
    let author: String?
    let authorId: String?
    let lengthSeconds: Int?
    let viewCountText: String?
    let viewCount: Int?
}

// MARK: - Video Detail (full response from /api/v1/videos/:id)
struct VideoDetail: Codable {
    let videoId: String
    let title: String
    let videoThumbnails: [VideoThumbnail]?
    let description: String?
    let descriptionHtml: String?
    let published: Int?
    let publishedText: String?
    let keywords: [String]?
    let viewCount: Int?
    let likeCount: Int?
    let dislikeCount: Int?
    let paid: Bool?
    let premium: Bool?
    let isFamilyFriendly: Bool?
    let allowedRegions: [String]?
    let genre: String?
    let author: String?
    let authorId: String?
    let authorThumbnails: [VideoThumbnail]?
    let subCountText: String?
    let lengthSeconds: Int?
    let allowRatings: Bool?
    let rating: Double?
    let isListed: Bool?
    let hlsUrl: String?
    let adaptiveFormats: [AdaptiveFormat]?
    let formatStreams: [FormatStream]?
    let recommendedVideos: [RecommendedVideo]?
    
    /// Get the best thumbnail URL
    var bestThumbnailURL: String? {
        // Prefer medium quality for performance on iPad Air 1
        let preferred = ["medium", "high", "sddefault", "default"]
        for q in preferred {
            if let thumb = videoThumbnails?.first(where: { $0.quality == q }) {
                return thumb.url
            }
        }
        return videoThumbnails?.first?.url
    }
    
    /// Get best playable video URL (combined audio+video stream)
    var bestStreamURL: String? {
        // Prefer format streams (combined audio+video) for simplicity
        // Sort by quality: prefer 720p for iPad Air 1 performance
        let preferredQualities = ["720p", "480p", "360p", "1080p"]
        for q in preferredQualities {
            if let stream = formatStreams?.first(where: { $0.qualityLabel == q }) {
                return stream.url
            }
        }
        return formatStreams?.first?.url
    }
    
    /// Get HLS URL if available (best for iOS)
    var hlsStreamURL: String? {
        return hlsUrl
    }
    
    /// Formatted view count
    var formattedViewCount: String {
        guard let count = viewCount else { return "" }
        if count >= 1_000_000 {
            return String(format: "%.1fM views", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK views", Double(count) / 1_000)
        }
        return "\(count) views"
    }
    
    /// Formatted duration
    var formattedDuration: String {
        guard let seconds = lengthSeconds else { return "" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Trending Video (from /api/v1/trending)
struct TrendingVideo: Codable {
    let videoId: String
    let title: String
    let videoThumbnails: [VideoThumbnail]?
    let author: String?
    let authorId: String?
    let lengthSeconds: Int?
    let viewCount: Int?
    let publishedText: String?
    let description: String?
    
    var bestThumbnailURL: String? {
        let preferred = ["medium", "high", "sddefault", "default"]
        for q in preferred {
            if let thumb = videoThumbnails?.first(where: { $0.quality == q }) {
                return thumb.url
            }
        }
        return videoThumbnails?.first?.url
    }
    
    var formattedDuration: String {
        guard let seconds = lengthSeconds else { return "" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
    
    var formattedViewCount: String {
        guard let count = viewCount else { return "" }
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.1fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

// MARK: - Search Result
struct SearchResult: Codable {
    let type: String  // "video", "channel", "playlist"
    let videoId: String?
    let title: String?
    let videoThumbnails: [VideoThumbnail]?
    let author: String?
    let authorId: String?
    let lengthSeconds: Int?
    let viewCount: Int?
    let publishedText: String?
    let description: String?
    
    var bestThumbnailURL: String? {
        let preferred = ["medium", "high", "sddefault", "default"]
        for q in preferred {
            if let thumb = videoThumbnails?.first(where: { $0.quality == q }) {
                return thumb.url
            }
        }
        return videoThumbnails?.first?.url
    }
    
    var formattedDuration: String {
        guard let seconds = lengthSeconds else { return "" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        }
        return String(format: "%d:%02d", minutes, secs)
    }
}

// MARK: - Invidious Instance
struct InvidiousInstance: Codable {
    let name: String
    let url: String
    let region: String?
    
    static let defaultInstances: [InvidiousInstance] = [
        InvidiousInstance(name: "yewtu.be", url: "https://yewtu.be", region: "NL"),
        InvidiousInstance(name: "vid.puffyan.us", url: "https://vid.puffyan.us", region: "US"),
        InvidiousInstance(name: "invidious.snopyta.org", url: "https://invidious.snopyta.org", region: "FI"),
        InvidiousInstance(name: "invidious.kavin.rocks", url: "https://invidious.kavin.rocks", region: "IN"),
        InvidiousInstance(name: "inv.riverside.rocks", url: "https://inv.riverside.rocks", region: "US"),
        InvidiousInstance(name: "invidious.namazso.eu", url: "https://invidious.namazso.eu", region: "HU"),
        InvidiousInstance(name: "invidious.privacyredirect.com", url: "https://invidious.privacyredirect.com", region: "FI"),
    ]
}
