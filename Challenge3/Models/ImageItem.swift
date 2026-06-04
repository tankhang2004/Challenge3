//
//  ImageItem.swift
//  Challenge3
//
//  Created by Johnny Khang on 03/06/26.
//

import Foundation
import SwiftData

@Model
final class ImageItem {
    var filename: String
    var createdAt: Date

    init(filename: String, createdAt: Date = .now) {
        self.filename = filename
        self.createdAt = createdAt
    }
}
