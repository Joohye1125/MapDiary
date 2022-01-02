//
//  DiaryItem.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/18.
//

import Foundation
import UIKit
import CoreLocation

struct DiaryItem: Equatable{
   
    let id: Int
    var title: String
    var date: Date
    var contents: String
    var image: UIImage
    var imgMetadata: ImageMetadata
    
    mutating func update(title: String, contents: String, image: UIImage, metadata: ImageMetadata) {
        self.title = title
        self.contents = contents
        self.image = image
        self.imgMetadata = metadata
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ImageMetadata {
    var imageDateTime: Date?
    var location: GPS
}

struct GPS {
    let latitude: Double // 위도
    let longitude: Double // 경도
}
