//
//  LifeEvent.swift
//  LifeScore
//
//  Created by Roman Yefimets on 3/20/24.
//

import Foundation
import SwiftData

@Model
final class LifeEvent {
    var title: String
    var timestamp: Date
    var score: Double
    
    init(title: String = "", timestamp: Date = .now, score: Double = 0.0) {
        self.title = title
        self.timestamp = timestamp
        self.score = score
    }
}
