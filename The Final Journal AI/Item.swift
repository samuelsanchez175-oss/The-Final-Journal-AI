import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var title: String
    var body: String

    init(timestamp: Date, title: String = "", body: String = "") {
        self.timestamp = timestamp
        self.title = title
        self.body = body
    }
}