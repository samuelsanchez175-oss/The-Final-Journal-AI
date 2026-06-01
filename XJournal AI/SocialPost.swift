import Foundation
import SwiftData

@Model
final class SocialPost {
    var id: UUID
    var title: String
    var caption: String
    var images: [String] // Array of image names/paths (for carousel)
    var author: String
    var createdDate: Date
    var category: String? // Optional category (e.g., "Microphone Setup", "Sound Cards", "Logic Pro", "ProTools", "First Time Setup")
    var order: Int // Display order for posts (admin-controlled)
    var isAdminCurated: Bool // Flag to distinguish admin posts (default: true for Phase 1)
    
    init(
        id: UUID = UUID(),
        title: String,
        caption: String,
        images: [String] = [],
        author: String = "The Final Journal AI",
        createdDate: Date = Date(),
        category: String? = nil,
        order: Int = 0,
        isAdminCurated: Bool = true
    ) {
        self.id = id
        self.title = title
        self.caption = caption
        self.images = images
        self.author = author
        self.createdDate = createdDate
        self.category = category
        self.order = order
        self.isAdminCurated = isAdminCurated
    }
}
