//
//  Item.swift
//  The Final Journal AI
//
//  Created by Samuel on 12/28/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
