//
//  DiaryItem.swift
//  MapDiary
//
//  Created by 이주혜 on 2021/12/18.
//

import Foundation
import UIKit
import CoreLocation

class DiaryItem: Equatable{
   
    let id: Int
    var title: String
    var date: Date
    var contents: String
    var image: UIImage
    var imgMetadata: ImageMetadata
    
    init(id: Int, title: String, date: Date, contents: String, image: UIImage, imgMetadata: ImageMetadata) {
        self.id = id
        self.title = title
        self.date = date
        self.contents = contents
        self.image = image
        self.imgMetadata = imgMetadata
    }
    
    func update(title: String, contents: String, image: UIImage, metadata: ImageMetadata) {
        self.title = title
        self.contents = contents
        self.image = image
        self.imgMetadata = metadata
    }
    
    static func == (lhs: DiaryItem, rhs: DiaryItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class ImageMetadata {
    var imageDateTime: Date?
    var location: GPS
    
    init(imageDate: Date?, location: GPS) {
        self.imageDateTime = imageDate
        self.location = location
    }
}

class GPS {
    let latitude: Double // 위도
    let longitude: Double // 경도
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
}
